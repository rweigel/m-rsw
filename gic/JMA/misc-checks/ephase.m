
%clear;
%load('../mat/main_options-1-v1-o0.mat','GE');

if 0
ftEx = fft(GE.In(:,1,d));
ftEy = fft(GE.In(:,2,d));
aEx = atan2(imag(ftEx),real(ftEx));
aEy = atan2(imag(ftEy),real(ftEy));
semilogx(aEx-aEy)
end

d = 1; % Day
sf = (180/pi);

SE = smoothFT(GE.In(:,:,d));
SG = smoothFT(GE.Out(:,2,d));

% Phase of E on day d as a function of period
aEx = sf*atan2(imag(SE(:,1)),real(SE(:,1)));
aEy = sf*atan2(imag(SE(:,2)),real(SE(:,2)));
aG  = sf*atan2(imag(SG),real(SG));

figure(1);clf;
    semilogx(1./GE.fe,aEx,'r','LineWidth',2);
    grid on;hold on;
    semilogx(1./GE.fe,aEx,'g','LineWidth',1);
    semilogx(1./GE.fe,aG,'k','LineWidth',2);
    xlabel('Period [s]');
    ylabel('Phase [degrees]');
    title(sprintf('Day %d/35',d));
    legend('\angle $E_x$','\angle $E_y$','\angle $GIC$');

orient tall;    
print -dpdf ephase.pdf
