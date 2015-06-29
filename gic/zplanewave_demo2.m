% Relationship between Ex and By or dBy/dt for infinite half-plane:
%
% Ex(t)  = sum_w cos(w*t)
% By(t)  = sum_w sqrt(1/w)*cos(w*t - pi/4)
% dBy/dt = sum_w sqrt(w)*cos(w*t - pi/4)
%
% Create time series of each for f = [1:N/2]/N, with N large.
% Compute transfer function in time and frequency domain.
%
% To make both time series stationary, add a random phase for each w.
% (Time domain approach requires stationarity.)
%
% TODO: Sample every nth point to demonstrate aliasing effects.

clear;
addpath('../stats')
addpath('../time')

base = 'zplanewave_demo2'; % Output files will be named ./figures/base_...

for alpha = [-1/2,1/2]
% alpha = -1/2; % Ex and B_y
% alpha =  1/2; % Ex and dB_y/dt

N  = 10000;
t  = [0:N-1]';
dp = -pi*(alpha+1)/2;
f  = [1:N/2]/N;
dP = [0,-(120/180)*pi,(120/180)*pi];

xt = 0;
yt = 0;
for i = 1:length(f)
    phi(i) = 2*pi*(rand(1)-0.5); % Random phase in [-pi,pi].
    xt     = xt + (1/f(i))               *cos(2*pi*t*f(i)   +phi(i));
    yt     = yt + (1/f(i))*(f(i)^(alpha))*cos(2*pi*t*f(i)+dp+phi(i));    
end

% Subtract off mean (not needed if random phase is used).
xt = xt-mean(xt);
yt = yt-mean(yt);

dt = 1; % Subsampling if dt > 1
yt = yt(1:dt:end);
xt = xt(1:dt:end);
N  = length(yt);
t  = [0:N-1]';
f  = [0:N/2]/N;

% Add some noise.
%xt = xt+max(xt)*0.01*rand(N,1);
%yt = yt+max(yt)*0.01*rand(N,1);

% Time domain estimate of transfer function
Nl    = 400;
[T,X] = time_delay(xt,yt,Nl,0,Nl);
LIN   = basic_linear(X,T)

% Frequency domain estimate of transfer function
xtfft = fft(xt);
ytfft = fft(yt);
R     = xtfft./ytfft;
phi   = (180/pi)*atan2(imag(R),real(R));
hft   = ifft(xtfft./ytfft);
hft   = fftshift(hft);
tft   = [-N/2:1:N/2-1];
hbl   = LIN.Weights(1:end-1);    
tbl   = [-Nl+1:1:Nl];

if (alpha == -0.5)  
    vs = 'Ex_By';
end
if (alpha == +0.5)
    vs = 'Ex_dBydt';
end

figure(1);clf;
    plot(t,t*NaN,'k-','LineWidth',2); % To make legend lines are larger.
    hold on;grid on;
    plot(t,t*NaN,'g-','LineWidth',2);

    plot(t,xt,'k');
    plot(t,yt,'g');
    if (alpha == -0.5)  
        legend('E_x','B_y');
        vs = 'Ex_By';
    end
    if (alpha == +0.5)
        legend('E_x','dB_y/dt');
        vs = 'Ex_dBydt';
    end
    xlabel('t');
    print('-dpng','-r600',sprintf('figures/%s_timeseries_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_timeseries_%s.eps',base,vs));
    fprintf('Wrote figures/%s_timeseries_%s.{png,eps}\n',base,vs)
    
figure(2);clf;
    plot(tbl,hbl,'b','LineWidth',3,'Marker','.','MarkerSize',30);
    hold on;grid on;
    plot(tft,hft,'r','LineWidth',2,'Marker','.','MarkerSize',20);
    set(gca,'XLim',[tbl(1)-5 tbl(end)+5]);
    xlabel('t');
    if (alpha == -0.5)
        title('Response of E_x to B_y = \delta(t)');
    end
    if (alpha == 0.5)
        title('Response of E_x to dB_y/dt = \delta(t)');
    end
    legend('Time domain method','Freq. domain method');
    print('-dpng','-r600',sprintf('figures/%s_irf_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_irf_%s.eps',base,vs));
    fprintf('Wrote figures/%s_irf_%s.{png,eps}\n',base,vs)

figure(3);clf;
    loglog(f(2:N/2),abs(ytfft(2:N/2)),'g','LineWidth',2,'Marker','.','MarkerSize',10);
    hold on;grid on;
    loglog(f(2:N/2),abs(xtfft(2:N/2)),'k','LineWidth',2,'Marker','.','MarkerSize',10);
    loglog(f(2:N/2),abs(R(2:N/2)),'m','LineWidth',2,'Marker','.','MarkerSize',10);
    xlabel('f');
    if (alpha == -0.5)
        legend('E_x','B_y','E_x/B_y');
    end
    if (alpha == +0.5)
        legend('E_x','dB_y/dt','E_x / (dB_y/dt)');
    end
    print('-dpng','-r600',sprintf('figures/%s_dft_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_dft_%s.eps',base,vs));
    fprintf('Wrote figures/%s_dft_%s.{png,eps}\n',base,vs)

end % alpha    
    
