% Compare two methods for estimating transfer function and impulse
% response between output u and input y.

% Time Domain Method: Directly estimate impulse response by solving for
% H = {h0, h1, ...} in
% ym(n)   = h0 + u(n-1)*h(1) + u(n-2)*h(2) + ...
% ym(n+1) = h0 + u(n-0)*h(1) + u(n-1)*h(2) + ...
% Transfer function is computed from DFT of H.

% Frequency domain method: Compute DFT coefficients U(f) and Y(f)
% for u(t) and y(t).
% Transfer function is H(f) = Y(f)/U(f).
% Impulse response is computed from inverse DFT of H(f).

% Note that in the following, only 50 coefficients are calculated in
% time domain.  To make a more direct comparison, the frequency domain
% estimates should be averaged so that the resolution in the frequency
% domain for both methods is the same.

clear;
addpath('../time');
writeimgs = 0;

N = 1e4;

% Compute IRF for dx/dt + x/tau = delta(0), and IC of x_0 = 0 dx_0/dt = 0
% using forward Euler.
tau = 10;
dt = 1;
gamma = (1-dt/tau);
for i = 1:10*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end

h = [0;h];

% Create an input signal
u = randn(N,1);

% Create an output that has a known relationship to input u via known
% impulse response function h:
% y(n) = 0*u(n) + h(1)*u(n-1) + h(2)*u(n-2) + ... h(N)*u(n-N)
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
% Solve for Ym = X*H -> H = Ym\U 
LIN = basic_linear(X,T);

% Impulse response function using basic_linear() (last element is h0)
hbl = LIN.Weights(1:end-1);
hbl = [0;hbl];

% Predicted output using model coefficients H = LIN.Weights
% First length(LIN.Weights) values of yp are set to NaN
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
        set(gca,'YTickLabel','')
        set(gca,'XTickLabel','')
    subplot('position',[0.1 0.1 0.8 0.44])
        hold on;grid on;
        % Plot nothing with large LineWidth to make line in legend
        % larger than that in plot.
        plot(NaN,'k','LineWidth',2);
        plot(NaN,'b','LineWidth',2);
        plot(NaN,'y','LineWidth',2);

        plot(y,'k','LineWidth',2)
        plot(yp,'b');grid on;
        plot(y-yp,'y','LineWidth',2);

        lh = legend(' Output',' Predicted Output',' Error');
        xlabel('Time','FontSize',14);

        set(lh,'Interpreter','Latex');
        set(gca,'FontSize',14);
        set(gca,'YTickLabel','');
        if (writeimgs)
            print('-depsc','basic_linear_demo_transfer_function_IRFtimeseries.eps');
            print('-dpng','-r600','basic_linear_demo_transfer_function_IRF_timeseries.png');
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
        print('-depsc','basic_linear_demo_transfer_function_IRF.eps');
        print('-dpng','-r600','basic_linear_demo_transfer_function_IRF.png');
    end

%%%%%%%%%%%%%

% Raw periodogram of h
[I,f,a,b,a0] = periodogramraw(h,'fast');
phix = (180/pi)*atan2(b,a); % Phase (phase is lag is relative to sin(2*pi*f*t))

haib = fft(h);
I    = haib.*conj(haib);
f    = [0:length(h)/2-1]/length(h);

N = length(h);
a = real((2/N)*exp(-2*pi*j*[1:N/2]'/N).*haib(2:N/2+1));
b = -imag((2/N)*exp(-2*pi*j*[1:N/2]'/N).*haib(2:N/2+1));
% Phase (phase is lag is relative to sin(2*pi*f*t))
phi = (180/pi)*atan2(b,a); 

%phi = -(180/pi)*atan2(imag(haib),real(haib));

% Estimate transfer function in frequency domain.
yaib = fft(y);
uaib = fft(u);

R0   = yaib./uaib;

N = length(R0);
a = real((2/N)*exp(-2*pi*j*[1:N/2]'/N).*R0(2:N/2+1));
b = -imag((2/N)*exp(-2*pi*j*[1:N/2]'/N).*R0(2:N/2+1));
% Phase (phase is lag is relative to sin(2*pi*f*t))
phi0 = (180/pi)*atan2(b,a); 

%phi0 = -(180/pi)*atan2(imag(R0),real(R0));
% Gives correct answer, but this is not the correct calculation ...
I0   = R0.*conj(R0);
f0   = [0:length(R0)/2-1]/length(R0);
h0   = ifft(R0);

% Raw periodogram of h
[I02,f02,a,b,a0] = periodogramraw([h0(1:length(h0))],'fast');
phi02 = (180/pi)*atan2(b,a); % Phase (phase is lag is relative to sin(2*pi*f*t))

%figure(3);clf;hold on;grid on;
%plot(phi0)
%plot(phi0x,'g');

figure(3);clf;grid on;hold on;
    plot(f0(2:end),I0(2:length(f0)),'k')
    plot(f(2:end),I(2:length(f)),'LineWidth',2,'Marker','.','MarkerSize',20);
    plot(f02(2:end),length(y)/2*I02(2:length(f02)),'g');
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method');
    title('Transfer Function Magnitude Estimate');
    if (writeimgs)
        print('-depsc','basic_linear_demo_transfer_function_Magnitude.eps');
        print('-dpng','-r600','basic_linear_demo_transfer_function_Magnitude.png');
    end
figure(4);clf;grid on;hold on;
    plot(f0(2:end),phi0(2:length(f0)),'k')
    plot(f(2:end),phi(1:length(f)-1),'LineWidth',3,'Marker','.','MarkerSize',20);
    plot(f02(2:end),phi02(1:length(f02)-1),'g')
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method','Location','South');
    set(gca,'YLim',[-180 180]);
    title('Transfer Function Phase Estimate [degrees]');
    if (writeimgs)
        print('-depsc','basic_linear_demo_transfer_function_Phase.eps');
        print('-dpng','-r600','basic_linear_demo_transfer_function_Phase.png');    
    end
figure(5);clf;grid on;hold on;
    plot(h0(2:length(h)+1),'k','LineWidth',4);
    plot(h(2:end),'LineWidth',2,'Marker','.','MarkerSize',10);
    legend('Frequency Domain Method','Time Domain Method');
    xlabel('Time Since Impulse');
    title('Impulse Response Estimate');
    if (writeimgs)
        print('-depsc','basic_linear_demo_transfer_function_IRF2.eps');
        print('-dpng','-r600','basic_linear_demo_transfer_function_IRF2.png');    
    end

% At f = 0.05, phase shift = 99 on Transfer Function Phase Estimate plot.

% Visual inspection to determine proper phase.
t = [0:length(y)/10-1]';
y20 = sin(2*pi*t*0.05);    
y2  = filter(h,1,y20);

figure(6);clf;hold on;grid on;
    plot(t,y2,'r','LineWidth',3,'Marker','.','MarkerSize',20);
    plot(t,y20,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    legend('Output','Input');

% (394.5-390.0)/20*360 = 81
% Difference is 18 degrees, which corresponds to shift of 1 time unit. Why?
% The phase in these plots is wrt a sine wave with zero amplitude at
% the second timestep.

t = [0:length(y)/10-1]';
y20 = sin(2*pi*t*0.009901);    
y2  = filter(h,1,y20);

figure(6);clf;hold on;grid on;
    plot(t,y2,'r','LineWidth',3,'Marker','.','MarkerSize',20);
    plot(t,y20,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    legend('Output','Input');

break
h = zeros(1000,1);
h(2) = 1;
[I,f,a,b,a0] = periodogramraw(h);
phix = (180/pi)*atan2(b,a); % Phase (phase is lag is relative to sin(2*pi*f*t))
plot(f(2:end),phix,'.')
haib = fft(h);

t = [0:length(y)/10-1]';
y20 = sin(2*pi*t*0.25);    
y2  = filter(h,1,y20);
figure(6);clf;hold on;grid on;
    plot(t,y2,'r','LineWidth',3,'Marker','.','MarkerSize',30);
    plot(t,y20,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    legend('Output','Input');


break

% Visual inspection to determine proper phase.
% At f = 1/20, frequency domain method gives ~160 degrees while
% time domain method gives ~110 degrees.
t = [1:length(y)/10-1]';
y20 = sin(2*pi*t*0.5);    
y2  = filter([h0],1,y20);

figure(7);clf;hold on;grid on;
    plot(t,y2,'r','LineWidth',3,'Marker','.','MarkerSize',20);
    plot(t,y20,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    legend('Output','Input');

% Shift is (5.1/20)*360 = 99.

% Verify amplitude and phase estimates
% by passing sin wave though h.
if (0)
    y20 = sin(2*pi*f(2)*t);
    y2  = filter([0;h],1,y20);
    y20 = y20(length(h):end);
    y2  = y2(length(h):end);

    y30 = sin(2*pi*f(3)*t);
    y3  = filter([0;h],1,y30);
    y30 = y30(length(h):end);
    y3  = y3(length(h):end);

    t   = t(length(h):end);

    I20 = find(y20(2:end) > 0 & y20(1:end-1) < 0);    
    I2  = find(y2(2:end)  > 0 & y2(1:end-1) < 0);
    I30 = find(y30(2:end) > 0 & y30(1:end-1) < 0);    
    I3  = find(y3(2:end)  > 0 & y3(1:end-1) < 0);

    (I2(1)-I20(1))*dt*f(2)*360
    (I3(1)-I30(1))*dt*f(3)*360
    max(y3)/max(y2)
    sqrt(I(3)/I(2))
    (180/pi)*phi(1)
    (180/pi)*phi(2)

    figure(5);clf;grid on;hold on;
        plot(t,y20,'k','LineWidth',2);
        plot(t,y2,'k');
        plot(t,y30,'b','LineWidth',2);
        plot(t,y3,'b');    
end
