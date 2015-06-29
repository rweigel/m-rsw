% Compare two methods for estimating transfer function and impulse
% response between output u and input y.

% Time Domain Method: Directly estimate impulse response by solving for
% H = {h0, h1, ...} in
% ym(n)   = h0 + u(n-1)*h(1) + u(n-2)*h(2) + ...
% ym(n+1) = h0 + u(n-0)*h(1) + u(n-1)*h(2) + ...
% The transfer function is estimated as DFT of H.

% Frequency domain method: Compute DFT coefficients U(f) and Y(f)
% for u(t) and y(t).
% Transfer function estimate is H(f) = Y(f)/U(f).
% Impulse response is computed from inverse DFT of H(f).

% Note that in the following, only 50 coefficients are calculated in
% time domain method.  To make a more direct comparison, the frequency
% domain method estimates should be averaged so that the resolution in the
% frequency domain of H for both methods is the same.

clear;
writeimgs = 1; % Write png and eps files of plots.

N = 1e4; % Number of points in u and y.

% Compute IRF for dy/dt + y/tau = delta(0) with ICs of x_0 = 0 an
% dx_0/dt = 0 using forward Euler.
tau = 10;
dt = 1;
gamma = (1-dt/tau);
for i = 1:10*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end

if (1)
x = 1e5*[0.0679    0.0312    0.0022    0.0002    0.0056    3.8345];
x = 1e5*[0.0659    0.0027    0.0317    0.0002   -5.4597    0.0052];
a = x(1:end/2);
ta = x(end/2+1:end);
t = 5*[1:400]';
h = zeros(length(t),1);

for i = 1:length(a)
    h = h + a(i)*exp(-(t)/ta(i));
end
h = h/max(h);
end
hf = h/max(h);
Z2 = fft(h);
Z2 = Z2(2:end/2+1);
pZ2 = (180/pi)*atan2(imag(Z2),real(Z2));
clf;plot(pZ2);

% Create an input signal
u = randn(N,1);

% Create an output y that has a known relationship to input u via
% impulse response function H(t) (that is approximation of continous):
% y(n) = 0*u(n-0) + h(1)*u(n-1) + h(2)*u(n-2) + ... h(N)*u(n-N)
h = [0;h]; % For 0*u(n-0) term.
y = filter(h,1,u);

% Add some noise
%y = y + 0.01*max(abs(y))*randn(N,1);

% Remove non-steady-state part of input and output
y  = y(length(h)+1:end);
u  = u(length(h)+1:end);

Na = 0;         % The number of acausal coefficients
Nc = length(h); % The number of causal coefficients
Ts = 0;         % How much to shift input wrt to output

% T is the output, X is the input.
% Each row of X contains time delayed values of u
[T,X] = time_delay(y,u,(Nc-1),Ts,Na,'pad');

% Compute model by solving for H = {h0,h1,...} in overdetermined set
% of equations
% ym(n)   = h0 + u(n-1)*h(1) + u(n-2)*h(2) + ...
% ym(n+1) = h0 + u(n-0)*h(1) + u(n-1)*h(2) + ...
% ...
% If any row above contains a NaN, it is omitted from the computation.
% basic_linear() solves for H in Ym = X*H using H = Ym\U.
% A column of ones is added to X = X(u) for h0.
LIN = basic_linear(X,T);

% Impulse response function using basic_linear() (last element is h0; expectation
% value is <y>)
hbl  = LIN.Weights(1:end-1);
hbl  = [0;hbl]; % First term in LIN.Weights corresponds to u(n-1) term.

% Predicted output using model coefficients H = LIN.Weights
% First length(LIN.Weights)-1 values of yp are set to NaN to make
% yp same length as y.
yp = basic_linear(X,LIN.Weights,'predict');

figure(1);clf
    subplot('position',[0.1 0.55 0.8 0.44])
        grid on;hold on;    
        plot(y(1)+10,'k','LineWidth',3);
        plot(u(1),'g','LineWidth',3);
        plot(u-5,'g');
        plot(y+5,'k');

        lh = legend(' Output',' Input');
        set(lh,'FontSize',18);
        set(lh,'Interpreter','Latex');
        axis([0 length(u) -15 15]);
        set(gca,'FontSize',14);
        set(gca,'YTickLabel',''); 
        set(gca,'XTickLabel','');
    subplot('position',[0.1 0.1 0.8 0.44])
        hold on;grid on;
        % Plot nothing with large LineWidth to make line in legend
        % larger than that in plot.
        plot(NaN,'k','LineWidth',2);
        plot(NaN,'b','LineWidth',2);
        plot(NaN,'y','LineWidth',2);

        % Plot y, yp and error.
        plot(y,'k','LineWidth',2)
        plot(yp,'b');grid on;
        plot(y-yp,'y','LineWidth',2);

        lh = legend(' Output',' Predicted Output',' Error');
        xlabel('Time','FontSize',14);

        set(lh,'Interpreter','Latex');
        set(gca,'FontSize',14);
        set(gca,'YTickLabel','');
        if (writeimgs)
            print('-depsc','./figures/transfer_function_demo_timeseries.eps');
            print('-dpng','-r600','./figures/transfer_function_demo_timeseries.png');
            fprintf('Wrote ./figures/transfer_function_demo_timeseries.{eps,png}\n');
        end
figure(2);clf;
    hold on;grid on;
    plot(NaN,'k','LineWidth',5);
    plot(NaN,'b','LineWidth',2,'Marker','square');
    plot(NaN,'m','LineWidth',2);

    plot([0 tau*5],[0 0],'Color',[0.5 0.5 0.5]);
    plot(exp(-(t(1:end))/tau)/exp(-t(1)/tau),'m','LineWidth',6);
    plot(h(2:end),'k','LineWidth',5);
    plot(hbl(2:end),'b','LineWidth',1,'Marker','square');

    title('Time Domain Estimate of Impulse Response');
    lh = legend(' Actual Response to $\delta(t)$',' Predicted Response to $\delta(t)$',' $\dot{x}(t)+x(t)/\tau_c = \delta (t)$','Location','North');
    xlabel('Time Since Impulse','FontSize',14);
 
    set(lh,'Interpreter','Latex');
    set(lh,'FontSize',18);
    set(lh,'Box','off');
    axis([0 tau*5 -0.1 1.1]);
    if (writeimgs)
        print('-depsc','./figures/transfer_function_demo_IRF.eps');
        print('-dpng','-r600','./figures/transfer_function_demo_IRF.png');
        fprintf('Wrote ./figures/transfer_function_demo_IRF.{eps,png}\n')
    end

%%%%%%%%%%%%%

% Compute transfer function of H computed using time domain method.
haib = fft(hbl);
I    = haib.*conj(haib);
f    = [0:length(h)/2-1]/length(h);
phi  = (180/pi)*atan2(imag(haib(2:end)),real(haib(2:end))); 

% Estimate transfer function in frequency domain.
yaib = fft(y);
uaib = fft(u);
Rf   = yaib./uaib;
If   = Rf.*conj(Rf);
phif = (180/pi)*atan2(imag(Rf(2:end)),real(Rf(2:end))); 
ff   = [0:length(Rf)/2-1]/length(Rf);
hf   = ifft(Rf);

figure(3);clf;grid on;hold on;
    plot(ff(2:end),If(2:length(ff)),'k')
    plot(f(2:end),I(2:length(f)),'LineWidth',2,'Marker','.','MarkerSize',20);
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method');
    title('Transfer Function Magnitude Estimate');
    if (writeimgs)
        print('-depsc','./figures/transfer_function_demo_Magnitude.eps');
        print('-dpng','-r600','./figures/transfer_function_demo_Magnitude.png');
        fprintf('Wrote ./figures/transfer_function_demo_Magnitude.{eps,png}\n')

    end
figure(4);clf;grid on;hold on;
    plot(ff(2:end),phif(2:length(ff)),'k')
    plot(f(2:end),phi(1:length(f)-1),'LineWidth',3,'Marker','.','MarkerSize',20);
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method','Location','North');
    set(gca,'YLim',[-180 180]);
    title('Transfer Function Phase Estimate [degrees]');
    if (writeimgs)
        print('-depsc','./figures/transfer_function_demo_Phase.eps');
        print('-dpng','-r600','./figures/transfer_function_demo_Phase.png');    
        fprintf('Wrote ./figures/transfer_function_demo_Phase.{eps,png}\n')
    end
figure(5);clf;grid on;hold on;
    plot(hf(2:length(h)+1),'k','LineWidth',5);
    plot(hbl(2:end),'LineWidth',2,'Marker','.','MarkerSize',10);
    legend(' Frequency Domain Method',' Time Domain Method');
    xlabel('Time Since Impulse');
    title('Impulse Response Estimate');
    if (writeimgs)
        print('-depsc','./figures/transfer_function_demo_IRF2.eps');
        print('-dpng','-r600','./figures/transfer_function_demo_IRF2.png'); 
        fprintf('Wrote ./figures/transfer_function_demo_IRF2.{eps,png}\n')
    end

% Visual inspection to verify phase estimateby passing sin wave though h.

% At f = 1/20, frequency domain method gives 80.6 degrees while

t = [1:length(y)/10-1]';
y20 = sin(2*pi*t/20);    
y2  = filter(hbl,1,y20);

figure(7);clf;hold on;grid on;
    plot(t,y2,'r','LineWidth',3,'Marker','.','MarkerSize',20);
    plot(t,y20,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    legend('Output','Input');

% Visual inspection: ((289.5-285)/20)*360 = 81 degrees