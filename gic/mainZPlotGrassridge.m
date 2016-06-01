for i = 1:2
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    if (i == 1)
	plot(tRTD,HRTD(:,2),'r','LineWidth',2);
	plot(tR,HR(:,3),'b','LineWidth',2);
	plot(tRTD,HRTD(:,2),'r.','MarkerSize',8);
	plot(tR,HR(:,3),'b.','MarkerSize',8);
    else
	plot(tRTD,HRTD(:,3),'r','LineWidth',2);
	plot(tR,HR(:,2),'b','LineWidth',2);
	plot(tRTD,HRTD(:,3),'r.','MarkerSize',8);
	plot(tR,HR(:,2),'b.','MarkerSize',8);
    end
    legend('Time Domain Method',...
	   'Frequency Domain Method',...
	   'Location','SouthEast');
    set(gca,'XLim',[-5 10]*60)
    set(gca,'XTick',[-6:2:10]*60)
    xl = get(gca,'XLim');
    yl = get(gca,'YLim');
    if (i == 1)
	text(xl(1),yl(2),...
	     ' Response of GIC to 1 nT/s impulse of dB_x/dt at t = 0',...
	     'VerticalAlignment','top')
    else
	text(xl(1),yl(2),...
	     ' Response of GIC to 1 nT/s impulse of dB_y/dt at t = 0',...
	     'VerticalAlignment','top')
    end
    title(sprintf('%s/%s',long,agent))
    ylabel('GIC [A]')
    if (ppd == 1440)
	xlabel('t [min]')
    end
    fignames{fn} = sprintf('%s_%s_H_dBxdt_%s-%s',short,label,ts1,ts2);

% Clone figure	
h1=gcf;
fn = fn+1;
h2 = figure(fn);clf
    objects=allchild(h1);
    copyobj(get(h1,'children'),h2);
    set(gca,'XLim',[-0.5 1]*60)
    set(gca,'XTick',[-0.5:0.25:1]*60)
	xl = get(gca,'XLim');
	yl = get(gca,'YLim');	
	text(xl(1)+0,yl(2),...
	     ' Response of GIC to 1 nT/s impulse of dB_x/dt at t = 0',...
	     'VerticalAlignment','top')
    fignames{fn} = sprintf('%s_%s_H_dBxdt_Zoom_%s-%s',short,label,ts1,ts2);    	
end

if (writeimgs)
  for i = [1:fn]
    figurex(i);
    fname = sprintf('%s/%s/%s/figures/mainPlot_%s',...
		    datadir,lower(agent),short,fignames{i});
    fprintf('mainPlot: Writing %s.{pdf,png}\n',fname);
    print([fname,'.png'],'-dpng');
    print([fname,'.pdf'],'-dpdf');
  end
end
