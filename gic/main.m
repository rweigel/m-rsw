% See http://bobweigel.net/projects/Weigel/Notes/GIC
clear
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');

savefigs = 1;
%savefigs = 0;

long = 'Kakioka';
short = 'kak';

long  = 'Memambetsu';
short = 'mmb';

labels  = {'B_x','B_y','B_z','dB_x/dt','B_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};

pre = sprintf('figures/main_%s',short);
tit = sprintf('%s Magnetic Observatory (%s)',long,upper(short));

[B,dB,E] = prepareData(short,lower(long));

t = [0:size(B,1)-1]'/86400;
figure(1);clf;
    plot(t,E);hold on;grid on;
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel('Days since 12/01/2006 00:00:00.0')
    ylabel('mV/m')
    legend('E_x','E_y')
    if (savefigs)
    fprintf('Writing %s_E_timeseries.{png,eps}\n',pre)    
    print('-dpng','-r300',...
        sprintf('%s_E_timeseries.png',pre));
    print('-depsc',...
        sprintf('%s_E_timeseries.eps',pre));
    fprintf('Wrote %s_E_timeseries.{png,eps}\n',pre)
    end
    
figure(2);clf;
    plot(t,B);hold on;grid on;
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel('Days since 12/01/2006 00:00:00.0')
    ylabel('nT')
    legend('B_x','B_y','B_z')
    if (savefigs)
    fprintf('Writing %s_B_timeseries.{png,eps}\n',pre)
    print('-dpng','-r300',...
        sprintf('%s_B_timeseries.png',pre));
    print('-depsc',...
        sprintf('%s_B_timeseries.eps',pre));
    fprintf('Wrote %s_B_timeseries.{png,eps}\n',pre)
    end

dB(abs(dB)>2) = 0;

figure(3);clf;
    plot(t,dB);hold on;grid on;
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel('Days since 12/01/2006 00:00:00.0')
    ylabel('nT/s')
    legend('dB_x/dt','dB_y/dt','dB_z/dt')
    if (savefigs)
    fprintf('Writing %s_dBdt_timeseries.{png,eps}\n',pre)
    print('-dpng','-r300',...
    sprintf('%s_dBdt_timeseries.png',pre));
    print('-depsc',...
        sprintf('%s_dBdt_timeseries.eps',pre));
    fprintf('Wrote %s_dBdt_timeseries.{png,eps}\n',pre)
    end

X = [B,dB,E];    
figure(4);clf

    ftX = fft(X);
    pX = abs(ftX);
    N  = size(pX,1);
    f  = [0:N/2]'/N;

    loglog(f(2:end),pX(2:N/2+1,:));
    grid on;
    xlabel('f [Hz]');
    legend(labels);
    title(tit)
    ylabel('Periodogram magnitude [nT]');
    if (savefigs)
    print('-dpng','-r300',...
        sprintf('%s_All_periodogram.png',pre));
    print('-depsc',...
        sprintf('%s_All_periodogram.eps',pre));
    fprintf('Wrote %s_All_periodogram.{png,eps}\n',pre)
    end

figure(5);clf
    for i=1:size(X,2)
        tmp     = reshape(X(:,i),86400,31);
        I       = find(sum(isnan(tmp)) == 0);
        tmp     = tmp(:,I);
        fttmp   = fft(tmp);
        p{i}    = abs(fttmp);
        pA(:,i) = mean(p{i},2);
    end
    NA = size(fttmp,1);
    fA = [0:NA/2]'/NA;
    loglog(fA,pA(1:NA/2+1,:),'LineWidth',2);
    grid on;
    xlabel('f [Hz]');    
    legend(labels);
    title(tit);
    ylabel('Periodogram magnitude [nT]');
    if (savefigs)
    print('-dpng','-r300',...
        sprintf('%s_All_periodogram_ave.png',pre));
    print('-depsc',...
        sprintf('%s_All_periodogram_ave.eps',pre));
    fprintf('Wrote %s_All_periodogram_ave.{png,eps}\n',pre);
    end

break

for i=1:size(X,2)    
    figure(5+i);clf;
    loglog(fA,p{i}(1:NA/2+1,:),'LineWidth',2);
    grid on;
    xlabel('f [Hz]');    
    title([labels{i}, ' ', tit]);
    if (savefigs)    
    print('-dpng','-r300',...
        sprintf('%s_%s_periodograms_for_ave.png',pre,labels2{i}));
    print('-depsc',...
        sprintf('%s_%s_spectrograms_for_ave.eps',pre,labels2{i}));
    fprintf('Wrote %s_%s_spectrogram.{png,eps}\n',pre,labels2{i})
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

    print('-dpng','-r300',...
        sprintf('%s_%s_spectrogram.png',pre,labels{i}));
    print('-depsc',...
        sprintf('%s_%s_spectrogram.eps',pre,labels{i}));
    fprintf('Wrote %s_%s_spectrogram.{png,eps}\n',pre,labels{i})
end
end

if (0)
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
end
