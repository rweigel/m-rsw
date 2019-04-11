setpaths;
if ~exist('F','var')
    filestr = 'options-1';

    dirfig = sprintf('figures/combined');
    if ~exist(dirfig,'dir')
        mkdir(dirfig);
    end

    file = sprintf('mat/main_%s.mat','options-1');
    fprintf('plot_model_predictions: Loading %s\n',file);
    F = load(file);
    fprintf('plot_model_predictions: Loaded %s\n',file);    
end

EB = F.EB_avg.Mean;
EBf = F.EB_avg.Fuji;

png = 0;
fdir = 'figures/predictions';
figprep(png,1000,800);
a = F.opts.td.Ntrim;
b = size(EB.Predicted,1)-a+1;
EB.Predicted(1:a,:,:) = NaN;
EB.Predicted(b:end,:,:) = NaN;
EBf.Predicted(1:a,:,:) = NaN;
EBf.Predicted(b:end,:,:) = NaN;

for k = 1:size(EB.Predicted,3)

    t = F.EB.Time(:,1,k);
    start = datestr(t(1),'yyyy-mm-dd');

    figure(1);clf;

    %ha = tight_subplot(5,1,[0.015,0.015],[0.05,0.02],[0.04,0.04]);
    ha = tight_subplot(5,1);

    if 1
    yl1 = [-60,60]*1.01;
    yl2 = [-30,30]*1.01;
    yl3 = [-10,10]*1.01;
    
    yt1  = [-60:10:60];
    yt2  = [-30:10:30];
    yt3  = [-10:5:10];    
    end
    
    axes(ha(1));
        plot(t,F.EB.In(:,1,k),'c');
        box on;grid on;hold on;        
        plot(t,F.EB.In(:,2,k),'m');
        if exist('yl1')
            set(gca,'YLim',yl1);
            set(gca,'YTick',yt1);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'$E_x$','$E_y$'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,F.EB.Out(:,1,k),'k');
        box on;grid on;hold on;
        plot(t,EB.Predicted(:,1,k),'r');
        plot(t,EBf.Predicted(:,1,k),'b');
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
        plot(t,F.EB.Out(:,2,k),'k');
        box on;grid on;hold on;        
        plot(t,EB.Predicted(:,2,k),'r');
        plot(t,EBf.Predicted(:,2,k),'b');
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
        plot(t,F.EB.Out(:,1,k)-EB.Predicted(:,1,k),'r');
        box on;grid on;hold on;        
        plot(t,F.EB.Out(:,1,k)-EBf.Predicted(:,1,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl2')        
            set(gca,'YLim',yl2/5);
            set(gca,'YTick',yt2/5);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({...
                            sprintf('Method 1 $E_x$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                    EB.PE(1,1,k),EB.CC(1,1,k),EB.MSE(1,1,k)),...
                            sprintf('Fuji   1 $E_x$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EBf.PE(1,1,k),EBf.CC(1,1,k),EBf.MSE(1,1,k))...
                        },'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(5));
        plot(t,F.EB.Out(:,2,k)-EB.Predicted(:,2,k),'r');
        box on;grid on;hold on;        
        plot(t,F.EB.Out(:,2,k)-EBf.Predicted(:,2,k),'b');
        set(gca,'YAxisLocation','right');
        if exist('yl3')
            set(gca,'YLim',yl3/5);
            set(gca,'YTick',yt3/5);
        end
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({...
                            sprintf('Method 1 $E_y$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EB.PE(1,2,k),EB.CC(1,2,k),EB.MSE(1,2,k)),...
                            sprintf('Fuji   1 $E_y$ Error PE/CC/MSE = %.2f/%.2f/%.2f',...
                                EBf.PE(1,2,k),EBf.CC(1,2,k),EBf.MSE(1,2,k))...
                        },'Location','NorthWest');
        set(lo,'LineWidth',2);
        datetick('x');
        datetick_adjust();
  
    if png
        figsave(sprintf('%s/plot_EB_predictions-%s.pdf',fdir,start));
    end
    
    input('Continue');
    
end