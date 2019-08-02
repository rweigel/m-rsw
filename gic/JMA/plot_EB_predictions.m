fdir = 'figures/predictions';
if ~exist(fdir,'dir')
    mkdir(fdir);
end

figprep(writepng,1000,800);

%EB = EB_avg.Mean;
%EBf = EB_avg.Fuji;

a = opts.td.Ntrim;
b = size(EB_avg.Mean.Predicted,1)-a+1;
EB_avg.Mean.Predicted(1:a,:,:) = NaN;
EB_avg.Mean.Predicted(b:end,:,:) = NaN;
EB_avg.Fuji.Predicted(1:a,:,:) = NaN;
EB_avg.Fuji.Predicted(b:end,:,:) = NaN;

for k = 1:size(EB.Predicted,3)

    t = EB.Time(:,1,k);
    start = datestr(t(1),'yyyy-mm-dd');

    figure(1);clf;

    %ha = tight_subplot(5,1,[0.015,0.015],[0.05,0.02],[0.04,0.04]);
    ha = tight_subplot(5,1);

    yl1 = [-60,60]*1.01;
    yl2 = [-30,30]*1.01;
    yl3 = [-10,10]*1.01;
    
    yt1  = [-60:10:60];
    yt2  = [-30:10:30];
    yt3  = [-10:5:10];    
    
    axes(ha(1));
        plot(t,EB.In(:,1,k),'c');
        box on;grid on;hold on;        
        plot(t,EB.In(:,2,k),'m');
        if exist('yl1')
            set(gca,'YLim',yl1);
            set(gca,'YTick',yt1);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'$E_x$','$E_y$'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,EB.Out(:,1,k),'k');
        box on;grid on;hold on;
        plot(t,EB_avg.Mean.Predicted(:,1,k),'r');
        plot(t,EB_avg.Fuji.Predicted(:,1,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl2')
            set(gca,'YLim',yl2);
            set(gca,'YTick',yt2);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'$E_x$','Method 1','Fujii'},'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,EB.Out(:,2,k),'k');
        box on;grid on;hold on;        
        plot(t,EB_avg.Mean.Predicted(:,2,k),'r');
        plot(t,EB_avg.Fuji.Predicted(:,2,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl3')
            set(gca,'YLim',yl3);
            set(gca,'YTick',yt3);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'$E_y$','Method 1','Fujii'},'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(4));
        plot(t,EB.Out(:,1,k)-EB_avg.Mean.Predicted(:,1,k),'r');
        box on;grid on;hold on;        
        plot(t,EB.Out(:,1,k)-EB_avg.Fuji.Predicted(:,1,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl2')        
            set(gca,'YLim',yl2/5);
            set(gca,'YTick',yt2/5);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({...
                            sprintf('Method 1 $E_x$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                    EB_avg.Mean.PE(1,1,k),EB_avg.Mean.CC(1,1,k),EB_avg.Mean.MSE(1,1,k)),...
                            sprintf('Fujii   1 $E_x$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EB_avg.Fuji.PE(1,1,k),EB_avg.Fuji.CC(1,1,k),EB_avg.Fuji.MSE(1,1,k))...
                        },'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(5));
        plot(t,EB.Out(:,2,k)-EB_avg.Mean.Predicted(:,2,k),'r');
        box on;grid on;hold on;        
        plot(t,EB.Out(:,2,k)-EB_avg.Fuji.Predicted(:,2,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl3')
            set(gca,'YLim',yl3/5);
            set(gca,'YTick',yt3/5);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({...
                            sprintf('Method 1 $E_y$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EB_avg.Mean.PE(1,2,k),EB_avg.Mean.CC(1,2,k),EB_avg.Mean.MSE(1,2,k)),...
                            sprintf('Fujii   1 $E_y$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EB_avg.Fuji.PE(1,2,k),EB_avg.Fuji.CC(1,2,k),EB_avg.Fuji.MSE(1,2,k))...
                        },'Location','NorthWest');
        set(lo,'LineWidth',2);
        datetick('x');
        datetick_adjust();
  
    if writepng
        fname = sprintf('%s/plot_EB_predictions-%s-v%d-o%d.pdf',fdir,start,codever,oos_aves);
        figsave(fname);
    else
        input('Continue');
    end
    
end