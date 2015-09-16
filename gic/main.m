clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');
addpath('./misc');

writeimgs = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib Under Wire';
short = 'obibdm';

long  = 'Obib 100m Over from Wire';
short = 'obibmt';

start = '06-Jul-2013 14:15:00';
tit   = sprintf('%s MT (%s)',long,upper(short));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Kakioka';
short = 'kak';

long  = 'Memambetsu';
short = 'mmb';

start = '2006-12-01 00:00:00';
tit   = sprintf('%s Magnetic Observatory (%s)',long,upper(short));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
xlab    = ['Days since ',start];
cs      = ['r','g','b','r','g','b','m','k'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read data
[B,dB,E] = mainPrepare(short,lower(long));

dB = dB(14*86400:16*86400,:);
B = B(14*86400:16*86400,:);
E = E(14*86400:16*86400,:);

t = [0:size(B,1)-1]'/86400;
dno = datenum(start);
dn = dno + t;

X = [B,dB,E];    
dE = diff(E);
dE(end+1,:) = dE(end,:);

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;

if (0)
Nc = 350;
Na = 350;
Ts = 0;
[T,Xxy] = time_delay(E(:,2),B(:,1),(Nc-1),Ts,Na,'pad');
LINxy = basic_linear(Xxy,T)
break
% Time domain
[ZBL,feBL,HBL,tBL] = transferfnTD(dB,E,Nc);
end
[ZR,feR] = transferfnFD(dB,E,'rectangular');
HR       = Z2H(feR,ZR,f);
HR       = fftshift(HR,1);
NR       = (size(HR,1)-1)/2;
tR       = [-NR:NR]';

%EpR      = Hpredict(tR,HR,B);
%EpR2     = Zpredict(feR,ZR,B);

% Transfer Function Phase
PxyR  = (180/pi)*atan2(imag(ZR),real(ZR));

figure(1);clf
    loglog(feR,abs(ZR(:,2)))

figure(2);clf
    plot(feR,PxyR(:,2))

figure(3);clf;grid on;hold on;
    plot(tR,HR(:,2))

break

ZRi      = Zinterp(feR,ZR,fh);
ZxyRi = ZRi(:,2);
PxyRi = (180/pi)*atan2(imag(ZxyRi),real(ZxyRi));


% Averaged periodograms
for i = 1:size(X,2)
    tmp = reshape(X(:,i),86400,size(X,1)/86400);
    % Remove any days with one or more NaNs.
    I = find(sum(isnan(tmp)) == 0); 
    fprintf('Removed %d days in %s because of NaNs.\n',...
        size(tmp,2)-length(I),labels{i})
    % Each cell element in p contains abs(FT) for one day.
    p{i}     = fft(tmp(:,I));  
    nA{i}    = length(I);         % Number that are averaged.
    pA(:,i)  = mean(abs(p{i}),2); % Average of each cell element.
    pA2(:,i) = abs(mean(p{i},2)); % Alternative method of averaging.
 end
NA = size(pA,1);
fA = [0:NA/2]'/NA;

figure(1);clf;
    for i = 1:3
        plot(t,dB(:,i),cs(i+3));hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel(xlab)
    ylabel('nT/s')
    legend('dB_x/dt','dB_y/dt','dB_z/dt')
    plotcmds([short,'_dBdt_timeseries'],writeimgs)

figure(2);clf;
    for i = 1:3
        plot(t,B(:,i),cs(i));
        hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel(xlab)
    ylabel('nT')
    legend('B_x','B_y','B_z')
    plotcmds([short,'_B_timeseries'],writeimgs)

figure(3);clf;
    for i = 1:2
        plot(t,E(:,i),cs(i+6));
        hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel(xlab)
    ylabel('mV/m')
    legend('E_x','E_y')
    plotcmds([short,'_E_timeseries'],writeimgs)

Ip = [1,2,7,8];
figure(4);clf
    for i = 1:length(Ip)
        loglog(f(2:end),pX(2:N/2+1,Ip(i)),cs(Ip(i)),'LineWidth',1);
        hold on;grid on;
    end
    %loglog(fc',pP(:,Ip),'.','MarkerSize',10)
    xlabel('f [Hz]');
    legend(labels(Ip),'Location','NorthEast');
    title(tit);
    %vertline(fe);
    ylabel('Periodogram magnitude');
    plotcmds([short,'_All_periodogram'],writeimgs)

figure(5);clf
    for i = 1:length(Ip)
        loglog(fA,pA(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    plotcmds([short,'_All_periodogram_ave'],writeimgs)

figure(6);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    plotcmds([short,'_All_periodogram_ave2'],writeimgs)

break
for i=1:size(X,2)
    figure(7);clf
        [T,P,aib,left,d_o] = spectrogram(X(:,i)',86400);
        I = find(T <= 86400/4);
        T = T(I)/86400;
        P = P(I,:);
        aib = aib(I,:);
        left = left(I,:);
        [ah,ch] = spectrogram_plot(X(:,i)',T,P,aib,d_o,left);

        axes(ah(1))
        ylabel([labels{i},' [nT]'])
        set(gca,'YAxisLocation','right')
        set(get(gca,'YLabel'),'Rotation',0)

        axes(ah(2))
        ylabel('Period [days]')

        axes(ah(3))
        ylabel('Period [days]')

        set(gca,'XTickLabel',[0:2:31])
        set(gca,'XTick',[1:86400*2:86400*31])
        
        %xlabel('Days since 12/01/2006 00:00:00.0')
        plotcmds(sprintf('%s_%s_spectrogram.png',short,labels2{i}),writeimgs)
end