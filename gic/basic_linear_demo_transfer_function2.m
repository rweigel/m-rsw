% Comparison of two approaches to determining transfer function for
% infinite half-plane.
%
% Relationship between Ex and By or dBy/dt for infinite half-plane:
%
% Ex(t)  = sum_w cos(w*t)
% By(t)  = sum_w sqrt(1/w)*cos(w*t - pi/4)
% dBy/dt = sum_w sqrt(w)*cos(w*t - pi/4)
%
% Method:
% Create time series of each for f = [1:N/2]/N, with N large.
% Compute transfer function in time and frequency domain.
%
% To make both time series stationary, add a random phase for each w.
% (Time domain approach requires stationarity.)
%
% Frequency domain approach: Transfer function is ratio in frequency domain.
%
% Time domain approach: Impulse response coefficients are estimated.
% Transfer function is periodogram of impulse response coefficients.
% 800 coefficients are used (400 causal, 400 acausal).

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
Rft   = xtfft./ytfft;
phift = (180/pi)*atan2(imag(Rft),real(Rft));
Nft   = length(xt);
frft  = [0:Nft/2]/Nft;

hft   = ifft(xtfft./ytfft);
hft   = fftshift(hft);
tft   = [-N/2:1:N/2-1];

hbl   = LIN.Weights(1:end-1);    
tbl   = [-Nl+1:1:Nl];
Rbl   = fft(hbl);
phibl = (180/pi)*atan2(imag(Rbl),real(Rbl));
Nbl   = length(hbl);
frbl  = [0:Nbl/2]/Nbl;

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
        lh = legend('$E_x$','$B_y$');
        vs = 'Ex_By';
    end
    if (alpha == +0.5)
        lh = legend('$E_x$','$B_y''$');
        vs = 'Ex_dBydt';
    end
    set(lh,'Interpreter','Latex');

    xlabel('t');
    print('-dpng','-r150',sprintf('figures/%s_timeseries_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_timeseries_%s.eps',base,vs));
    fprintf('Wrote figures/%s_timeseries_%s.{png,eps}\n',base,vs)
    
figure(2);clf;
    loglog(frft(2:Nft/2),abs(ytfft(2:Nft/2)),'k','LineWidth',2,'Marker','.','MarkerSize',10);
    hold on;grid on;
    loglog(frft(2:Nft/2),abs(xtfft(2:Nft/2)),'g','LineWidth',2,'Marker','.','MarkerSize',10);
    %loglog(f(2:N/2),abs(R(2:N/2)),'m','LineWidth',2,'Marker','.','MarkerSize',10);
    xlabel('f');
    if (alpha == -0.5)
        lh = legend('$\|\widetilde{E}_y\|$','$\|\widetilde{B}_y\|$');
    end
    if (alpha == +0.5)
        lh = legend('$\|\widetilde{E}_y\|$','$\|\widetilde{B}_y''\|$');
    end
    set(lh,'Interpreter','Latex');
    print('-dpng','-r150',sprintf('figures/%s_dft_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_dft_%s.eps',base,vs));
    fprintf('Wrote figures/%s_dft_%s.{png,eps}\n',base,vs)

figure(3);clf;
    plot(tbl,hbl,'b','LineWidth',3,'Marker','.','MarkerSize',30);
    hold on;grid on;
    plot(tft,hft,'r','LineWidth',2,'Marker','.','MarkerSize',20);
    set(gca,'XLim',[tbl(1)-5 tbl(end)+5]);
    xlabel('t');
    if (alpha == -0.5)
        th = title('Response of $E_x$ to $B_y = \delta(t)$');
    end
    if (alpha == 0.5)
        th = title('Response of $E_x$ to $B_y'' = \delta(t)$');
    end
    set(th,'Interpreter','Latex');    
    legend('Time domain method','Freq. domain method');
    print('-dpng','-r150',sprintf('figures/%s_irf_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_irf_%s.eps',base,vs));
    fprintf('Wrote figures/%s_irf_%s.{png,eps}\n',base,vs)

figure(4);clf;
    loglog(frbl(2:Nbl/2),abs(Rbl(2:Nbl/2)),'b','Marker','.','MarkerSize',10);
    hold on;grid on;
    loglog(frft(2:Nft/2),abs(Rft(2:Nft/2)),'r','Marker','.','MarkerSize',10);
    hold on;grid on;
    xlabel('f');
    if (alpha == -0.5)
        th = title('$\|\widetilde{E_x}\|/\|\widetilde{B}_y\|$');
    end
    if (alpha == +0.5)
        th = title('$\|\widetilde{E}_x\|/\|\widetilde{B}''_y\|$');
    end
    set(th,'Interpreter','Latex');

    legend('Time domain method','Freq. domain method');
    print('-dpng','-r150',sprintf('figures/%s_transferfn_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_transferfn_%s.eps',base,vs));
    fprintf('Wrote figures/%s_transferfn_%s.{png,eps}\n',base,vs)

figure(5);clf;
    plot(frbl(2:Nbl/2),phibl(2:Nbl/2),'r','Marker','.','MarkerSize',10);
    hold on;grid on;
    plot(frft(2:Nft/2),phift(2:Nft/2),'b','Marker','.','MarkerSize',10);
    xlabel('f');
    if (alpha == -0.5)
        th = title('Phase $\|\widetilde{E_x}\|/\|\widetilde{B}_y\|$');
    end
    if (alpha == +0.5)
        th = title('Phase $\|\widetilde{E}_x\|/\|\widetilde{B}''_y\|$');
    end
    set(th,'Interpreter','Latex');

    legend('Time domain method','Freq. domain method');
    print('-dpng','-r150',sprintf('figures/%s_phase_%s.png',base,vs));
    print('-depsc',sprintf('figures/%s_phase_%s.eps',base,vs));
    fprintf('Wrote figures/%s_phase_%s.{png,eps}\n',base,vs)

end % alpha    
    
