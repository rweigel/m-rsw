clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');

savefigs = 1;
savefigs = 0;

long  = 'Memambetsu';
short = 'mmb';

long = 'Kakioka';
short = 'kak';

labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
cs      = ['r','g','b','r','g','b','m','k'];

pre = sprintf('figures/main_%s',short);
tit = sprintf('%s Magnetic Observatory (%s)',long,upper(short));

[B,dB,E] = prepareData(short,lower(long));

B  = B(1:86400*25,:);
dB = dB(1:86400*25,:);
E  = E(1:86400*25,:);

t = [0:size(B,1)-1]'/86400;

for i = 1:size(dB,2)
    I = find(abs(dB(:,i)>2));
    dB(I,i) = 0;
    fprintf('Set %d of %d values of |%s| > 2 to zero.\n',...
        length(I),size(dB,1),labels{i+3});
end

X = [B,dB,E];    

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;

% Evaluation frequencies for frequency domain smoothing
fe(1) = f(end)/2;
Ne(1) = fe(1)/(2*(1/N));
k = 1;
while fe(k) > f(2)
    k = k+1;
    % Evaluation frequencies.
    fe(k) = fe(1)/sqrt(2^(k-1));
    % Number of points to left and right of fe to apply window to.
    Ne(k) = fe(k)/(2*(1/N));     
end
% Omit last value (for which fe > f(2)) and make increasing in freq.
fe = fliplr(fe(1:end-1)); 
Ne = ceil(fliplr(Ne(1:end-1)));
fprintf('Created %d evaluation frequencies.\n',length(fe));

% Smooth in frequency domain with Parzen window.
for i = 1:size(X,2)
    for j = 1:length(fe)
        pw{j}   = parzenwin(2*Ne(j)+1); % Create window.
        pw{j}   = pw{j}/sum(pw{j});     % Normalize window function.
        Ic(j)   = find(f-fe(j) > 0,1);  % Find nearest frequency above eval freq.
        fc(j,1) = f(Ic(j));             % New frequency will be this freq.    
        parts{j,i} = pX(Ic(j)-Ne(j):Ic(j)+Ne(j),i); % Parts to apply window to.
        pP(j,i) = sum(pw{j}.*parts{j,i}); % Apply window for freqency j.
    end
end
for j = 1:length(fe)
    pw{j}   = parzenwin(2*Ne(j)+1); 
    pw{j}   = pw{j}/sum(pw{j});     
    Ic(j)   = find(f-fe(j) > 0,1);
    r = Ic(j)-Ne(j):Ic(j)+Ne(j);  
    BxBx(j) = sum(pw{j}.*ftX(r,1).*conj(ftX(r,1))); 
    ByBx(j) = sum(pw{j}.*ftX(r,2).*conj(ftX(r,1))); 
    ExBx(j) = sum(pw{j}.*ftX(r,7).*conj(ftX(r,1))); 
    EyBx(j) = sum(pw{j}.*ftX(r,8).*conj(ftX(r,1))); 

    ByBy(j) = sum(pw{j}.*ftX(r,2).*conj(ftX(r,2))); 
    ExBy(j) = sum(pw{j}.*ftX(r,7).*conj(ftX(r,2))); 
    EyBy(j) = sum(pw{j}.*ftX(r,8).*conj(ftX(r,2))); 

    ExEx(j) = sum(pw{j}.*ftX(r,7).*conj(ftX(r,7)));
    EyEx(j) = sum(pw{j}.*ftX(r,8).*conj(ftX(r,7)));

    EyEy(j) = sum(pw{j}.*ftX(r,8).*conj(ftX(r,8)));

    BxBy(j) = sum(pw{j}.*ftX(r,1).*conj(ftX(r,2)));

    DET(j) =  BxBx(j)*ByBy(j) - BxBy(j)*ByBx(j);
    Zxx(j) = (ExBx(j)*ByBy(j) - ExBy(j)*ByBx(j))/DET(j);
    Zxy(j) = (ExBy(j)*BxBx(j) - ExBx(j)*BxBy(j))/DET(j);
    Zyx(j) = (EyBx(j)*ByBy(j) - EyBy(j)*ByBx(j))/DET(j);
    Zyy(j) = (EyBy(j)*BxBx(j) - EyBx(j)*BxBy(j))/DET(j);
end
break

% Averaged periodograms
for i = 1:size(X,2)
    tmp     = reshape(X(:,i),86400,size(X,1)/86400);
    % Remove any days with one or more NaNs.
    I       = find(sum(isnan(tmp)) == 0); 
    fprintf('Removed %d days in %s because of NaNs.\n',...
        size(tmp,2)-length(I),labels{i})
    % Each cell element in p contains abs(FT) for one day.
    p{i}    = fft(tmp(:,I));  
    nA{i}   = length(I);         % Number that are averaged.
    pA(:,i) = mean(abs(p{i}),2); % Average of each cell element.
    pA2(:,i) = abs(mean(p{i},2));
 end
NA = size(pA,1);
fA = [0:NA/2]'/NA;

% Ex(f) = Zxx(f)Bx(f) + Zxy(f)By(f)
% For each f, create one equation for each FT over a 1-day window.
% Ey(f) = Zyx(f)Bx(f) + Zyy(f)By(f)

for i = 1:size(p{1},1)
    B = [p{1}(i,:)',p{2}(i,:)'];
    E = [p{7}(i,:)'];
    rZxxZxy(i,:) = real(B)\real(E);
    iZxxZxy(i,:) = imag(B)\imag(E);
    %B = [p{1}(i,:)',p{2}(i,:)'];
    %E = [p{8}(i,:)'];
    %ZyxZyy(i,:) = B\E;
end

Zxx = rZxxZxy(:,1) + j*iZxxZxy(:,1);
Zxy = rZxxZxy(:,2) + j*iZxxZxy(:,2);

figure();clf
loglog(fA,abs(Zxx(1:NA/2+1,1)));hold on;
loglog(fA,abs(Zxy(1:NA/2+1,1)),'r');hold on;
break

phs = (180/pi)*atan2(imag(Zxx),real(Zxx));

pR1 = mean(p{7},2)./mean(p{2},2);
pR1 = mean(pR1,2);

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

figure(1);clf;
    for i = 1:3
        plot(t,dB(:,i),cs(i+3));hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel('Days since 12/01/2006 00:00:00.0')
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
    xlabel('Days since 12/01/2006 00:00:00.0')
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
    xlabel('Days since 12/01/2006 00:00:00.0')
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
    loglog(f(2:end),pX(2:N/2+1,Ip));
    hold on;grid on;
    loglog(fc',pP(:,Ip),'.','MarkerSize',10)
    xlabel('f [Hz]');
    legend(labels(Ip),'Location','EastOutside');
    title(tit);
    vertline(fe);
    ylabel('Periodogram magnitude [nT]');
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

    ylabel('Periodogram magnitude');
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

    ylabel('Periodogram magnitude');
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