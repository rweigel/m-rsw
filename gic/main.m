clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');

savefigs = 1;
%savefigs = 0;

long  = 'Memambetsu';
short = 'mmb';

long  = 'Kakioka';
short = 'kak';

tit = sprintf('%s Magnetic Observatory (%s)',long,upper(short));

long  = 'Obib Under';
short = 'obibdm';

long = 'Obib Over';
short = 'obibmt';

tit = sprintf('%s MT (%s)',long,upper(short));
xlab = 'Days since 06-Jul-2013 14:15:00';

pre = sprintf('figures/main_%s',short);

labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
cs      = ['r','g','b','r','g','b','m','k'];

[B,dB,E] = mainPrepare(short,lower(long));

t = [0:size(B,1)-1]'/86400;
dno = datenum('06-Jul-2013 14:15:00');
dn = dno + t;

X = [B,dB,E];    
dE = diff(E);
dE(end+1,:) = dE(end,:);

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;

[ZLc,fL] = impedanceLEMI('Pierre/Data/MT/Obib/ObibMT.ide');

ZxyL = ZLc{1,2};
[hL,tL,ZxyLi,PxyLi] = Z2H(fL,ZxyL);

% Frequency Domain
[feP,NeP,IcP] = evalfreq(f);
ftB = ftX(:,1:2);
ftE = ftX(:,7:8);
[tmp,ZxyP,ZyxP] = impedanceFD(f,feP,IcP,NeP,ftB,ftE,'parzen');
[hP,tP,ZxyPi,PxyPi] = Z2H(feP,ZxyP);

NP   = (length(hP)-1)/2;
EyP  = filter(hP,1,B(:,1));
EyP  = EyP(NP+1:end);

% Time Domain
for i = [5:5]
    I = [86400*(i-1)+1:86400*i];
    fprintf('Iteration %d\n',i)
    [Zc,fc,ZxyT,ZyxT,feT,Hc,hxyT,hyxT,Fxy,Fyx] = impedanceTD(dB(I,:),E(I,:),60*20);
end

EyT  = filter(hxyT,1,B(:,1));
EyT  = [repmat(NaN,length(hxyT),1);EyT(length(hxyT)+1:end)];

%[hyxT,tT,ZyxTi,PyxTi] = Z2H(feT,ZyxT);

ExT  = filter(hyxT,1,B(:,2));
ExT  = ExT(length(hyxT)+1:end);

Ey = filter(hxy,1,dB(:,1));
Ex = filter(hyx,1,dB(:,2));

ZTm = abs(ZT);
PT = (180/pi)*atan2(imag(ZT),real(ZT));

% Frequency Domain
[feP,NeP,IcP] = evalfreq(f);
ftB = ftX(:,1:2);
ftE = ftX(:,7:8);
[tmp,Zxy1,Zyx1] = impedance(f,feP,IcP,NeP,ftB,ftE,'parzen');

ZP = [Zxy1',Zyx1'];
ZPm = abs(ZP);
PP = (180/pi)*atan2(imag(ZP),real(ZP));

figure(1);clf
    loglog(feT(2:end,2),ZTm(2:end,1),'LineWidth',2,'MarkerSize',10);
    hold on;
    grid on;

    loglog(feT(2:end,2),ZTm(2:end,2),'LineWidth',2,'MarkerSize',10);

    xlabel('f [Hz]')

    loglog(feP(2:end),100*ZPm(2:end,1),'LineWidth',3,'MarkerSize',10);
    loglog(feP(2:end),100*ZPm(2:end,2),'LineWidth',3,'MarkerSize',10);
    legend(' Z_{xy} TD',' Z_{yx} TD',' Z_{xy} FD',' Z_{yx} FD');
    xlabel('f [Hz]')
    grid on;

figure(2);clf
    plot(feT(2:end,2),PT(2:end,:),'LineWidth',3);
    grid on;hold on;
    plot(feP(2:end),PP(2:end,:),'LineWidth',3);
    legend(' \phi_{xy} TD',' \phi_{yx} TD',' \phi_{xy} FD',' \phi_{yx} FD');
    ylabel('[deg]')
    xlabel('f [Hz]')
    

end

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
    if (savefigs)
        fprintf('Writing %s_dBdt_timeseries.{png,eps}\n',pre)
        print('-dpng','-r150',...
        sprintf('%s_dBdt_timeseries.png',pre));
        print('-depsc',...
            sprintf('%s_dBdt_timeseries.eps',pre));
        fprintf('Wrote %s_dBdt_timeseries.{png,eps}\n',pre)
    end

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
    if (savefigs)
        fprintf('Writing %s_B_timeseries.{png,eps}\n',pre)
        print('-dpng','-r150',...
            sprintf('%s_B_timeseries.png',pre));
        print('-depsc',...
            sprintf('%s_B_timeseries.eps',pre));
        fprintf('Wrote %s_B_timeseries.{png,eps}\n',pre)
    end

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
    if (savefigs)
        fprintf('Writing %s_E_timeseries.{png,eps}\n',pre)    
        print('-dpng','-r150',...
            sprintf('%s_E_timeseries.png',pre));
        print('-depsc',...
            sprintf('%s_E_timeseries.eps',pre));
        fprintf('Wrote %s_E_timeseries.{png,eps}\n',pre)
    end

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
    if (savefigs)
        print('-dpng','-r150',...
            sprintf('%s_All_periodogram.png',pre));
        print('-depsc',...
            sprintf('%s_All_periodogram.eps',pre));
        fprintf('Wrote %s_All_periodogram.{png,eps}\n',pre)
    end

figure(5);clf
    for i = 1:length(Ip)
        loglog(fA,pA(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);

    ylabel('Average periodogram magnitude');
    if (savefigs)
        print('-dpng','-r150',...
            sprintf('%s_All_periodogram_ave.png',pre));
        print('-depsc',...
            sprintf('%s_All_periodogram_ave.eps',pre));
        fprintf('Wrote %s_All_periodogram_ave.{png,eps}\n',pre);
    end

figure(6);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);

    ylabel('Average periodogram magnitude');
    if (savefigs)
        print('-dpng','-r150',...
            sprintf('%s_All_periodogram_ave.png',pre));
        print('-depsc',...
            sprintf('%s_All_periodogram_ave.eps',pre));
        fprintf('Wrote %s_All_periodogram_ave.{png,eps}\n',pre);
    end

figure(7);clf;
    R_Ex_By = pA(1:NA/2+1,7)./pA(1:NA/2+1,2);
    R_Ex_Bx = pA(1:NA/2+1,7)./pA(1:NA/2+1,1);
    R_Ey_Bx = pA(1:NA/2+1,8)./pA(1:NA/2+1,1);
    R_Ey_By = pA(1:NA/2+1,8)./pA(1:NA/2+1,2);
    loglog(fA,R_Ex_By,'r');
    hold on; grid on;
    loglog(fA,R_Ey_Bx,'g');
    loglog(fA,R_Ex_Bx,'b');
    loglog(fA,R_Ey_By,'m');

    legend('|Ex/By|','|Ey/Bx|','|Ex/Bx|','|Ey/By|')


break

figure(1);clf;
    plot(E(:,2)+20);hold on;grid on;
    plot(ExT/1000)
    %plot(EyT/1000)
break

%    legend('Ey Measured','Ey Parzen','Ey Time Domain')


    t = [0:length(Fxy)-1];
    figure(1);clf;
        plot(t/3600,E(I,2),'b');hold on;
        plot(t/3600,Fxy-23,'r');
        xlabel('time [hr]')
        ylabel('mV/m')
        title('Obib MT site')
        legend('Ey (measured)','Ey (modeled)');
        print -dpng a.png 
        plotcmds('a')
    figure(2);clf;
        title('Response of E_y to unit impulse of dB_x/dt at t = 0')
        plot(hxyT,'b','LineWidth',3);hold on;
        lh = legend('h_{xy} mV/nT');

        set(gca,'XLim',[0 600])
        grid on;
        xlabel('time [s]')
        print -dpng b.png 

        %plotcmds('b')
    figure(3);clf
        Z = fft(hxyT);
        f = [0:length(hxyT)/2]/(length(hxyT));
        loglog(f,abs(Z(1:length(f))),'b','LineWidth',3)
        xlabel('f [Hz]')
        grid on
        legend('Z_{xy} (Relating E_y to dB_x/dt)')
        print -dpng c.png 

    break

figure(2);clf;
    %loglog(feT(:,2),abs(ZTc{1,2}),'r','LineWidth',2);hold on;
    %loglog(feT(:,3),abs(ZTc{2,1}),'b','LineWidth',2);grid on;
    %        'Z_{xy} Time Domain','Z_{yx} Time Domain',...
    semilogx(1./fL(2:end),abs(ZLc{1,2}(2:end)),'m','LineWidth',2);hold on;
    semilogx(1./fL(2:end),abs(ZLc{2,1}(2:end)),'k','LineWidth',2);grid on;
    semilogx(1./feP(2:end),100*abs(ZxyP(2:end)),'c','LineWidth',2);hold on;
    semilogx(1./feP(2:end),100*abs(ZyxP(2:end)),'y','LineWidth',2);grid on;
    legend(...
            'Z_{xy} LEMI','Z_{yx} LEMI',...
            'Z_{xy} Frequency Domain','Z_{yx} Frequency Domain')
    %xlabel('f [Hz]')
    xlabel('Period [s]')

figure(1);clf
    plot(HTc{1,2},'r','LineWidth',2);hold on;
    plot(HTc{2,1},'b','LineWidth',2);grid on;
    xlabel('seconds')
    legend('h_{xy} Time Domain','h_{yx} Time Domain')

figure(6);clf
    R_Ex_By = pP(:,7)./pP(:,2);
    R_Ey_Bx = pP(:,8)./pP(:,1);
    loglog(fc,R_Ex_By,'g');
    hold on; grid on;
    loglog(fc,R_Ey_Bx);
    legend('|Ex/By|','|Ey/Bx|')

if (0)
for i=1:size(X,2)    
    figure(5+i);clf;
    loglog(fA,p{i}(1:NA/2+1,:),'LineWidth',2);
    grid on;
    xlabel('f [Hz]');    
    title([labels{i}, ' ', tit]);
    if (savefigs)    
    print('-dpng','-r150',...
        sprintf('%s_%s_periodograms_for_ave.png',pre,labels2{i}));
    print('-depsc',...
        sprintf('%s_%s_spectrograms_for_ave.eps',pre,labels2{i}));
    fprintf('Wrote %s_%s_spectrogram.{png,eps}\n',pre,labels2{i})
    end
end
end

if (0)
for i=1:size(X,2)
    figure(6);clf
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
        
        xlabel('Days since 12/01/2006 00:00:00.0')

        if (savefigs)    
            print('-dpng','-r150',...
                sprintf('%s_%s_spectrogram.png',pre,labels{i}));
            print('-depsc',...
                sprintf('%s_%s_spectrogram.eps',pre,labels{i}));
            fprintf('Wrote %s_%s_spectrogram.{png,eps}\n',pre,labels{i})
        end
    end
end