if length(long) == 0
  titlestr = sprintf('%s %s',agent,upper(short));
else
  titlestr = sprintf('%s (%s)',long,upper(short));
end
  
labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
cs      = ['r','g','b','r','g','b','m','k'];
xlab    = ['Days since ',datestr(dn(1),29)];
t       = [0:size(B,1)-1]'/86400;

% Create figure windows first so focus is only taken away once at start.
% See help figurex;
%set(0, 'DefaultFigureVisible', 'off');
for i = 1:7
  figure(i);
end
%set(0, 'DefaultFigureVisible', 'on');

figurex(1);clf;
    for i = 1:3
        plot(t,B(:,i),cs(i));
        hold on;grid on;
    end
    title(titlestr)
    xlabel(xlab)
    ylabel('[nT]');
    legend('B_x','B_y','B_z')
    fignames{2} = [short,'_B_timeseries'];

figurex(2);clf;
    for i = 1:3
        plot(t,dB(:,i),cs(i+3));hold on;grid on;
    end
    title(titlestr)
    xlabel(xlab)
    ylabel('[nT/s]');
    legend('dB_x/dt','dB_y/dt','dB_z/dt')
    fignames{1} = [short,'_dBdt_timeseries'];

figurex(3);clf;
    for i = 1:2
        plot(t,E(:,i),cs(i+6));
        hold on;grid on;
    end
    title(titlestr)
    xlabel(xlab)
    ylabel('[mV/km]');
    legend('E_x','E_y')
    fignames{3} = [short,'_E_timeseries'];

Ip = [1,2,7,8]; % Elements to plot
% Elements 1 and 2 are Bx, By.
% Elements 7 and 8 are Ex, Ey.
figurex(4);clf
    for i = 1:length(Ip)
        loglog(f,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',1);
        hold on;grid on;
    end
    %loglog(fc',pP(:,Ip),'.','MarkerSize',10)
    xlabel('f [Hz]');
    legend(labels(Ip),'Location','NorthEast');
    title(titlestr);
    %vertline(fe);
    yl = ylabel('$I$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{4} = [short,'_All_periodogram'];

figurex(5);clf
    for i = 1:length(Ip)
        loglog(1./f,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',1);
        hold on;grid on;
    end
    xlabel('T [s]');
    legend(labels(Ip),'Location','NorthWest');
    title(titlestr);
    %vertline(fe);
    yl = ylabel('$I$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{5} = [short,'_All_periodogram_vs_T'];

figurex(6);clf
    for i = 1:length(Ip)
        loglog(fA,pA(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip),'Location','NorthEast');
    title(titlestr);
    yl = ylabel('$\overline{I}$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{6} = [short,'_All_periodogram_ave'];

figurex(7);clf
    for i = 1:length(Ip)
        loglog(1./fA,pA(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('T [s]');    
    legend(labels(Ip),'Location','NorthWest');
    title(titlestr);
    yl = ylabel('$\overline{I}$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{7} = [short,'_All_periodogram_ave_vs_T'];

if (writeimgs)
  for i = [1:7]
    figurex(i);
    fname = sprintf('data/%s/%s/figures/mainPlot_%s',lower(agent),short,fignames{i});
    fprintf('mainPlot: Saving %s.{pdf,png}\n',fname);
    print([fname,'.png'],'-dpng');
    print([fname,'.pdf'],'-dpdf');
  end
end

if (0)

figurex(8);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(titlestr);
    ylabel('Average periodogram magnitude');
    fignames{8} = [short,'_All_periodogram_ave2'];

figurex(9);clf
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(titlestr);
    ylabel('Average periodogram magnitude');
    fignames{9} = [short,'_All_periodogram_ave2_vs_T'];

% Spectrograms
for i = 1:size(X,2)
    figurex(7);clf
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