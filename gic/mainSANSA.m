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
    

break
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
