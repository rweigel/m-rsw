clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');
addpath('./misc');

writeimgs = 1;

s = dbstack;
nm = s(1).name;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib Under Wire (SANSA)';
short = 'obibdm';
start = '06-Jul-2013 11:03:00';

long  = 'Obib 100m Over from Wire (SANSA)';
short = 'obibmt';
start = '06-Jul-2013 14:15:00';
%Is = [3*86400:5*86400-1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Kentland Farm, Blacksburg, VA (EarthScope)';
short = 'MBB05';
agent = 'IRIS';
start = '05-Aug-2008 00:00:00';
%Is = [3*86400:5*86400-1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Arlington Heights, WA, USA (EarthScope)';
short = 'WAB05';
agent = 'IRIS';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tit   = sprintf('%s (%s)',long,upper(short));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
xlab    = ['Days since ',start];
cs      = ['r','g','b','r','g','b','m','k'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read data
[B,dB,E,start] = mainPrepare(short, agent);

t   = [0:size(B,1)-1]'/86400;
dno = datenum(start);
dn  = dno + t;

%mainZ

X = [B,dB,E];

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;

% Averaged periodograms
for i = 1:size(X,2)
    tmp = reshape(X(:,i),86400,size(X,1)/86400);
    % Remove any days with one or more NaNs.
    I = find(sum(isnan(tmp)) == 0); 
    fprintf('%s: Removed %d days in %s because of NaNs.\n',...
        nm,size(tmp,2)-length(I),labels{i})
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
        plot(t,B(:,i),cs(i));
        hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel(xlab)
    ylabel('nT')
    legend('B_x','B_y','B_z')
    fignames{2} = [short,'_B_timeseries'];

figure(2);clf;
    for i = 1:3
        plot(t,dB(:,i),cs(i+3));hold on;grid on;
    end
    set(gca,'XLim',[0,t(end)])
    title(tit)
    xlabel(xlab)
    ylabel('nT/s')
    legend('dB_x/dt','dB_y/dt','dB_z/dt')
    fignames{1} = [short,'_dBdt_timeseries'];

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
    fignames{3} = [short,'_E_timeseries'];

Ip = [1,2,7,8]; % Elements to plot
% Elements 1 and 2 are Bx, By.
% Elements 7 and 8 are Ex, Ey.
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
    ylabel('Raw periodogram magnitude');
    fignames{4} = [short,'_All_periodogram'];

figure(5);clf
    for i = 1:length(Ip)
        loglog(1./f(2:end),pX(2:N/2+1,Ip(i)),cs(Ip(i)),'LineWidth',1);
        hold on;grid on;
    end
    %loglog(fc',pP(:,Ip),'.','MarkerSize',10)
    xlabel('T [s]');
    legend(labels(Ip),'Location','NorthEast');
    title(tit);
    %vertline(fe);
    ylabel('Raw periodogram magnitude');
    fignames{5} = [short,'_All_periodogram_vs_T'];

figure(6);clf
    for i = 1:length(Ip)
        loglog(fA(2:end),pA(2:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    fignames{6} = [short,'_All_periodogram_ave'];

figure(7);clf
    for i = 1:length(Ip)
        loglog(1./fA(2:end),pA(2:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('T [s]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    fignames{7} = [short,'_All_periodogram_ave_vs_T'];

figure(8);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    fignames{8} = [short,'_All_periodogram_ave2'];

figure(9);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(tit);
    ylabel('Average periodogram magnitude');
    fignames{9} = [short,'_All_periodogram_ave2_vs_T'];

for i = 1:length(fignames)
    figure(1);
    plotcmds(fignames{i},writeimgs)
end

if (0)
    % Spectrograms
    for i = 1:size(X,2)
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
end