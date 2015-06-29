addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');

pre = 'figures/mainMemambetsu_';

Bx = B(:,1);
Bx = diff(Bx);
Ey = E(:,2);
Ey = Ey(1:end-1);

k = 1;
w = 3600*8;
dw = w;
N = floor(length(Bx)/dw);
Nl = 60*3;
while 1
    a = dw*(k-1)+1;
	b = a+w;
    if (b > length(Bx)) break;end
    I = [a:b];

    [T,X] = time_delay(Bx(I),Ey(I),Nl,0,Nl/2,'pad');

    Itr = [1:round(0.5*length(I))-Nl];
    Ite = [round(0.5*length(I))+Nl:length(I)];
    LIN = basic_linear(X,T,Ite,Itr);
    fprintf('k = %d/%d PE = %.2f, %.2f\n',...
         k,N,1-LIN.ARVtrain,1-LIN.ARVtest);
    W(:,k)  = LIN.Weights;
    PEte(k) = 1-LIN.ARVtest;
    PEtr(k) = 1-LIN.ARVtrain;

    k = k+1;
end

break
[B,E] = prepareMemambetsu();

t = [0:size(B,1)-1]'/86400;
figure(1);clf;
    plot(t,E);hold on;grid on;
    set(gca,'XLim',[0,t(end)])
    title('Memambetsu Magnetic Observatory (MMB)')
    xlabel('Days since 12/01/2006 00:00:00.0')
    ylabel('mV/m')
    legend('E_x','E_y')
    print('-dpng','-r600',...
        sprintf('%s_E_timeseries.png',pre));
    print('-depsc',...
        sprintf('%s_E_timeseries.png',pre));
    fprintf('Wrote %s_E_timeseries.{png,eps}\n',pre)

figure(2);clf;
    plot(t,B);hold on;grid on;
    set(gca,'XLim',[0,t(end)])
    title('Memambetsu Magnetic Observatory (MMB)')
    xlabel('Days since 12/01/2006 00:00:00.0')
    ylabel('nT')
    legend('B_x','B_y','B_z')
    print('-dpng','-r600',...
        sprintf('%s_B_timeseries.png',pre));
    print('-depsc',...
        sprintf('%s_B_timeseries.png',pre));
    fprintf('Wrote %s_B_timeseries.{png,eps}\n',pre)

figure(3);clf
    
    % Interpolate over NaNs
    ti = [1:size(E,1)]';
    for i = 1:2
        Ig = find(~isnan(E(:,i))); % Good points.
        Eg = E(Ig,i);
        tg = ti(Ig);
        Ei(:,i) = interp1(tg,Eg,ti);
    end

    ftB = fft(B);
    ftE = fft(Ei);
    pB = abs(ftB);
    pE = abs(ftE);
    N  = size(pB,1);
    f  = [0:N/2]'/N;

    pB(:,2) = pB(:,2)/10;
    pB(:,3) = pB(:,3)/100;
    pE(:,1) = pE(:,1)/1000;
    pE(:,2) = pE(:,2)/10000;
    loglog(f(2:end),[pB(2:N/2+1,:),pE(2:N/2+1,:)]);
    grid on;
    xlabel('f [Hz]');
    legend('B_x','B_y/10','B_z/10^2','E_x/10^3','E_y/10^4');
    title('Memambetsu Magnetic Observatory (MMB)')
    ylabel('Periodogram magnitude [nT]');
    print('-dpng','-r600',...
        sprintf('%s_All_periodogram.png',pre));
    print('-depsc',...
        sprintf('%s_All_periodogram.png',pre));
    fprintf('Wrote %s_All_periodogram.{png,eps}\n',pre)

X = [B,E];    
labels = {'B_x','B_y','B_z','E_x','E_y'};

figure(4);clf
    for i=1:size(X,2)
        tmp     = reshape(X(:,i),86400,31);
        I       = find(sum(isnan(tmp)) == 0);
        tmp     = tmp(:,I);
        fttmp   = fft(tmp);
        p       = abs(fttmp);
        pA(:,i) = mean(p,2);
    end
    NA = size(fttmp,1);
    fA = [0:NA/2]'/NA;
    loglog(fA,pA(1:NA/2+1,:),'LineWidth',2);
    grid on;
    xlabel('f [Hz]');    
    legend(labels);
    title('Memambetsu Magnetic Observatory (MMB)');
    ylabel('Periodogram magnitude [nT]');
    print('-dpng','-r600',...
        sprintf('%s_All_periodogram_ave.png',pre));
    print('-depsc',...
        sprintf('%s_All_periodogram_ave.png',pre));
    fprintf('Wrote %s_All_periodogram_ave.{png,eps}\n',pre);

for i=1:size(X,2)    
figure(5);clf
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

    print('-dpng','-r600',...
        sprintf('%s_%s_spectrogram.png',pre,labels{i}));
    print('-depsc',...
        sprintf('%s_%s_spectrogram.png',pre,labels{i}));
    fprintf('Wrote %s_%s_spectrogram.{png,eps}\n',pre,labels{i})
end
    