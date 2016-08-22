set(0,'DefaultFigureWindowStyle','docked')
fn = fn + 1;
figurex(fn);clf;hold on;grid on;box on;grid minor;
    for i = 1:3
        plot(t,NaN*B(:,i),cs(i),'LineWidth',2);
    end
    for i = 1:3
        plot(t,B(:,i),cs(i));

    end
    title(titlestrs);
    xlabel(xlab)
    ylabel('[nT]','Rotation',0,'HorizontalAlignment','right');
    legend('B_x','B_y','B_z')
    fignames{fn} = [Info.short,'_B_timeseries'];

fn = fn + 1;
figurex(fn);clf;hold on;grid on;hold on;grid on;box on;grid minor;
    shift = 0;
    for i = 1:3
        plot(t,NaN*dB(:,i),cs(i),'LineWidth',2);
	tmpshift = nanstd(dB(:,i));
	if (tmpshift > shift)
	    shift = tmpshift;
	end
    end
    shift = 10*shift;
    for i = 1:3
        plot(t,dB(:,i)-shift*(i-2),cs(i+3));hold on;grid on;
    end
    title(titlestrs)
    xlabel(xlab)
    ylabel('[nT/s]','Rotation',0,'HorizontalAlignment','right');
    legend(...
	sprintf('dB_x/dt+%.1f',shift)',...
	'dB_y/dt',...
	sprintf('dB_x/dt-%.1f',shift)');
    fignames{fn} = [Info.short,'_dBdt_timeseries'];

fn = fn + 1;
figurex(fn);clf;hold on;grid on;box on;grid minor;
    for i = 1:size(E,2)
        plot(t,E(:,i)*NaN,cs(i+6),'LineWidth',2);
    end
    for i = 1:size(E,2)
        plot(t,E(:,i),cs(i+6));
    end
    title(titlestrs)
    xlabel(xlab)
    if strcmp('grassridge',Info.short')
	ylabel('[Amp]');
	legend('GIC')
    else
	ylabel('[mV/km]');
	legend('E_x','E_y')
    end
    fignames{fn} = [Info.short,'_E_timeseries'];

Ip = [1,2,7,8]; % Elements to plot
% Elements 1 and 2 are Bx, By.
% Elements 7 and 8 are Ex, Ey.

fn = fn + 1;
figurex(fn);clf;box on;
    for i = 1:length(Ip)
        loglog(fA,pA(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
	grid on;grid minor;hold on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip),'Location','NorthEast');
    title(titlestrs);
    yl = ylabel('$\overline{I}$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{fn} = [Info.short,'_All_periodogram_ave'];


if (0)
fn = fn + 1;
figurex(fn);clf;
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(titlestrs);
    ylabel('Average periodogram magnitude');
    fignames{fn} = [Info.short,'_All_periodogram_ave2'];
end
    
fn = fn + 1;
figurex(fn);clf;box on;
    for i = 1:length(Ip)
        loglog(1./fA,pA(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
        grid on;hold on;grid minor;
    end
    xlabel('T [s]');    
    legend(labels(Ip),'Location','NorthWest');
    title(titlestrs);
    yl = ylabel('$\overline{I}$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{fn} = [Info.short,'_All_periodogram_ave_vs_T'];

if (0)
fn = fn + 1;
figurex(fn);clf;
    for i = 1:length(Ip)
        loglog(fA,pA2(1:NA/2+1,Ip(i)),cs(Ip(i)),'LineWidth',2);
        hold on;grid on;
    end
    xlabel('f [Hz]');    
    legend(labels(Ip));
    title(titlestrs);
    ylabel('Average periodogram magnitude');
    fignames{fn} = [short,'_All_periodogram_ave2_vs_T'];
end

fn = fn + 1;
figurex(fn);clf;
    for i = 1:length(Ip)
        loglog(fX,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
	grid on;hold on;
    end
    for i = 1:length(Ip)
        loglog(fX,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',1);
    end
    %loglog(fc',pP(:,Ip),'.','MarkerSize',10)
    xlabel('f [Hz]');
    legend(labels(Ip),'Location','NorthEast');
    title(titlestrs);
    %vertline(fe);
    yl = ylabel('$I$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{fn} = [Info.short,'_All_periodogram'];

fn = fn + 1;
figurex(fn);clf;
    for i = 1:length(Ip)
        loglog(1./fX,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',2);
	grid on;hold on;
    end
    for i = 1:length(Ip)
        loglog(1./fX,pX(:,Ip(i)),cs(Ip(i)),'LineWidth',1);
    end
    xlabel('T [s]');
    legend(labels(Ip),'Location','NorthWest');
    title(titlestrs);
    %vertline(fe);
    yl = ylabel('$I$',...
	   'Rotation',0,...
	   'Interpreter','Latex',...
	   'HorizontalAlignment','Right');
    fignames{fn} = [Info.short,'_All_periodogram_vs_T'];


if (0) % Need to figure out why these won't save
% Spectrograms
X = [B,dB,E];
for i = 1:size(X,2)
    fn = fn + 1;
    figurex(fn);clf
        fignames{fn} = [short,'_spectrogram_',labels{i}];    
        [T,P,aib,left,d_o] = spectrogram(X(:,i)',86400);
        I = find(T <= 86400/4);
        T = T(I)/86400;
        P = P(I,:);
        aib = aib(I,:);
        left = left(I,:);
        [ah,ch] = spectrogram_plot(X(:,i)',T,P,aib,d_o,left);

	axes(ah(1))
        legend([labels{i},' [nT]'])

        axes(ah(2))
        ylabel('Period [days]')

        axes(ah(3))
        ylabel('Period [days]')

        set(gca,'XTickLabel',[0:2:31])
        set(gca,'XTick',[1:86400*2:86400*31])
        
end
end

if (writeimgs)
  for i = [1:fn]
    figurex(i);
    fname = sprintf('%s/%s/%s/figures/mainPlot_%s',...
		    datadir,lower(agent),Info.short,fignames{i});
    fprintf('mainPlot: Writing %s.{pdf,png}\n',fname);
    print([fname,'.png'],'-dpng');
    print([fname,'.pdf'],'-dpdf');
  end
end


