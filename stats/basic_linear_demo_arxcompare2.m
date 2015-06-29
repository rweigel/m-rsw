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
% Impulse response if inverse DFT of H(f).

% Note that in the following, only 50 coefficients are calculated in
% time domain.  To make a more direct comparison, the frequency domain
% estimates should be averaged so that the resolution in the frequency
% domain for both methods is the same.

clear;
addpath('../time');

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

% Create an input signal
u = randn(N,1);

% Create an output that has a known relationship to input u via known
% impulse response function h:
% y(n) = 0*u(n) + h(1)*u(n-1) + h(2)*u(n-2) + ... h(N)*u(n-N)
y = filter([0;h],1,u);

% Add some noise
% y = y + 0.01*max(abs(y))*randn(N,1);

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
        print('-depsc','basic_linear_demo_arxcompare2_IRFtimeseries.eps');
        print('-dpng','-r600','basic_linear_demo_arxcompare2_IRF_timeseries.png');

figure(2);clf;
    hold on;grid on;
    plot(NaN,'k','LineWidth',5);
    plot(NaN,'b','LineWidth',2,'Marker','square');
    plot(NaN,'m','LineWidth',2);

    plot([0 tau*5],[0 0],'Color',[0.5 0.5 0.5]);
    plot(exp(-(t(2:end))/tau)/exp(-t(2)/tau),'m','LineWidth',6);
    plot([h],'k','LineWidth',5);
    plot([hbl],'b','LineWidth',1,'Marker','square');

    lh = legend(' Actual Response to $\delta(t)$',' Predicted Response $\delta(t)$',' $\dot{x}(t)+x(t)/\tau_c = \delta (t)$','Location','North');
    xlabel('Time Since Impulse','FontSize',14);
 
    set(lh,'Interpreter','Latex');
    set(lh,'FontSize',18);
    set(lh,'Box','off');
    axis([0 tau*5 -0.1 1.1]);
    print('-depsc','basic_linear_demo_arxcompare2_IRF.eps');
    print('-dpng','-r600','basic_linear_demo_arxcompare2_IRF.png');

%%%%%%%%%%%%%

% Raw periodogram of h
% [I,f,a,b,a0] = periodogramraw(h,'fast');
% phi = atan2(b,a); % Phase (phase is lag is relative to sin(2*pi*f*t))
haib = fft(h);
I    = haib.*conj(haib);
f    = [0:length(h)/2-1]/length(h);
% Phase (phase is lag is relative to sin(2*pi*f*t))
phi = -(180/pi)*atan2(imag(haib),real(haib)); 


% Estimate transfer function in frequency domain.
yaib = fft(y);
uaib = fft(u);

R0   = yaib./uaib;
phi0 = -(180/pi)*atan2(imag(R0),real(R0));
I0   = R0.*conj(R0);
f0   = [0:length(y)/2-1]/length(y);
h0   = ifft(R0);

figure(3);clf;grid on;hold on;
    plot(f0(2:9900/2),I0(2:9900/2),'k')
    plot(f(2:end),I(2:end/2),'LineWidth',2,'Marker','.','MarkerSize',20);
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method');
    title('Transfer Function Magnitude Estimate');
figure(4);clf;grid on;hold on;
    plot(f0(2:9900/2),phi0(2:9900/2),'k')
    plot(f(2:end),phi,'LineWidth',3,'Marker','.','MarkerSize',20);
    xlabel('f');
    legend('Frequency Domain Method','Time Domain Method','Location','South');
    set(gca,'YLim',[-180 180]);
    title('Transfer Function Phase Estimate [degrees]');
figure(5);clf;grid on;hold on;
    plot(h0(2:length(h)+1),'k','LineWidth',4);
    plot(h,'LineWidth',2,'Marker','.','MarkerSize',10);
    legend('Frequency Domain Method','Time Domain Method');
    xlabel('Time Since Impulse');
    title('Impulse Response Estimate');
    
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
