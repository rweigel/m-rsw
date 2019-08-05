writepng = 1;

start = datestr(t(1),'yyyy-mm');

components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};
lc = ['r','g','b','k'];
ls = ['-','-','-','-'];

m1 = 2;
m2 = 2;
d1 = 1;
d2 = 3;

figprep(writepng,1200,600);
figure(1);clf;
    plot(t,B);
    datetick('x','dd');
    legend('Bx','By','Bz');
    title(sprintf('%s',upper(site)),'FontWeight','normal');
    xlabel(datestr(t(1),'mmm yyyy'));
    grid on;
    zoom off;
    hB = zoom(gca);
    hB.ActionPreCallback = @(obj,evd) fprintf('');
    hB.ActionPostCallback = @(obj,evd) fprintf('Showing B([%d:%d],:)\n',...
        round((evd.Axes.XLim-tB(1))*86400));
    drawnow;
if writepng
    fname = sprintf('figures/window/window_compare_plot-B-%s-v%d.pdf',start,codever);
    figsave(fname);
end

    
figprep(writepng,1200,600);    
figure(2);clf;
    plot(t,E);
    datetick('x','dd');
    xlabel(datestr(t(1),'mmm yyyy'));
    legend('Ex','Ey');
    title(sprintf('%s',upper(site)),'FontWeight','normal'); 
    grid on;    
    zoom off;
    hB = zoom(gca);
    hB.ActionPreCallback = @(obj,evd) fprintf('');
    hB.ActionPostCallback = @(obj,evd) fprintf('Showing E([%d:%d],:)\n',...
        round((evd.Axes.XLim-tE(1))*86400));
    drawnow;
if writepng
    fname = sprintf('figures/window/window_compare_plot-E-%s-v%d.pdf',start,codever);
    figsave(fname);
end
    
figprep(writepng,800,1000);
figure(3);clf;
subplot(4,1,1);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1),'k');
    plot(t(a:b),Ep{d1,m1}(a:b,1),'b');
    plot(t(a:b),Ep{d2,m2}(a:b,1),'r');
    datetick('x','dd');
    ylabel('mV/m');
    legend('$E_x$ Measured',methods{m1},methods{m2},'Location','Best');        
    title(sprintf('%s',upper(site)),'FontWeight','normal');
    hx = zoom(gca);
    hx.ActionPreCallback = @(obj,evd) fprintf('');
    hx.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,2);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1)-Ep{d1,m1}(a:b,1),'b');
    plot(t(a:b),E(a:b,1)-Ep{d2,m2}(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_x$ Prediction Error','VerticalAlignment','top');
    legend(LL{d1,m1,1},LL{d2,m2,1},'Location','Best');    
subplot(4,1,3);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2),'k');
    plot(t(a:b),Ep{d1,m1}(a:b,2),'b');
    plot(t(a:b),Ep{d2,m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd')    
    ylabel('mV/m');
    legend('$E_y$ Measured',methods{m1},methods{m2},'Location','Best');        
    hy = zoom(gca);
    hy.ActionPreCallback = @(obj,evd) fprintf('');
    hy.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,4);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2)-Ep{d1,m1}(a:b,2),'b');
    plot(t(a:b),E(a:b,2)-Ep{d2,m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    xlabel(datestr(t(1),'mmm yyyy'));
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_y$ Prediction Error','VerticalAlignment','top');
    xl = cellstr(get(gca,'XTickLabel'));
    xl{1} = [xl{1},'\n/',dateo(1:4)];
    set(gca,'XTickLabel',xl);
    legend(LL{d1,m1,2},LL{d2,m2,2},'Location','Best');    
    drawnow;

if writepng
    fname = sprintf('figures/window/window_compare_plot-Error-%s-v%d.pdf',start,codever);
    figsave(fname);
end

figprep(writepng,1200,1200);
figure(4);clf;
for i = 1:4
    subplot(2,2,i)
    k = 0;
    for d = 1:size(Z,1)
        for m = 1:size(Z,2)
            k = k+1;
            loglog(1./fe{d,m}(2:end),abs(Z{d,m}(2:end,i)),...
                  'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',10);
            hold on;grid on;
            ll{k} = sprintf('%s w = %d',methods{m},W(d));
        end
    end
    title(sprintf('%s %s; %s--%s',upper(site),components{i},dateo,datef),'FontWeight','normal');
    if i == 1
        legend(ll,'Location','Best');
    end
    xlabel('Period [s]');
    ylabel('[(mV/km)/nT]');
end
if writepng
    fname = sprintf('figures/window/window_compare_plot-Z-%s-v%d.pdf',start,codever);
    figsave(fname);
end


figprep(writepng,1200,1200);
figure(5);clf;
    subplot(2,1,1)
        k = 0;
        for d = 1:size(SNf,1)
            for m = 1:size(SNf,2)
                k = k+1;
                loglog(1./fef(2:end),SNf{d,m}(2:end,1),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
                ll{k} = sprintf('%s w = %d',methods{m},W(d));
            end
        end
        ylabel('SN for $E_x$');
        xlabel('Period [s]');        
        lh = legend(ll,'Location','EastOutside');
    subplot(2,1,2)
        for d = 1:size(SNf,1)
            for m = 1:size(SNf,2)
                loglog(1./fef(2:end),SNf{d,m}(2:end,2),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
            end
        end
        ylabel('SN for $E_y$')
        lh = legend(ll,'Location','EastOutside');
        set(lh,'Visible','off');
%        xl = get(gca,'XLim');

if writepng
    fname = sprintf('figures/window/window_compare_plot-SN1-%s-v%d.pdf',start,codever);
    figsave(fname);
end

figprep(writepng,1200,1200);        
figure(6);clf;
    subplot(2,1,1)
        k = 0;
        for d = 1:size(SNs,1)
            for m = 1:size(SNs,2)
                k = k+1;
                loglog(1./fes(2:end),SNs{d,m}(2:end,1),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
                ll{k} = sprintf('%s w = %d',methods{m},W(d));
            end
        end
        %set(gca,'XLim',xl);
        ylabel('SN for $E_x$')
        legend(ll,'Location','EastOutside');        
    subplot(2,1,2)
        for d = 1:size(SNs,1)
            for m = 1:size(SNs,2)
                loglog(1./fes(2:end),SNs{d,m}(2:end,2),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
            end
        end
        %set(gca,'XLim',xl);
        xlabel('Period [s]');        
        ylabel('SN for $E_y$')
        lh = legend(ll,'Location','EastOutside');
        set(lh,'Visible','off');

if writepng
    fname = sprintf('figures/window/window_compare_plot-SN2-%s-v%d.pdf',start,codever);
    figsave(fname);
end
        
