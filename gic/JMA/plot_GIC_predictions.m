fdir = 'figures/predictions';
if ~exist(fdir,'dir')
    mkdir(fdir);
end

figprep(writepng,1000,800);

for k = 22:22%size(GE.Predicted,3)
%for k = 1:size(GE.Predicted,3)

    t = GE.Time(:,1,k);
    start = datestr(t(1),'yyyy-mm-dd');
    GIC = GE.Out(:,2,k);

    fh = figure(1);clf;
    set(fh,'DefaultAxesFontSize',10);

    ha = tight_subplot(5,1,[0.015,0.015],[0.05,0.02],[0.04,0.04]);

    yl1 = [-1,1.5]*1.01;
    yl2 = [-0.5,0.5]*1.01;
    yl3 = [-0.25,0.25]*1.01;

    yt1  = [-1:0.5:1.5];
    yt2  = [-0.5:0.25:0.5];
    yt3  = [-0.25:0.125:0.25];
    
    axes(ha(1));
        plot(t,GIC,'c');
        box on;grid on;hold on;
        plot(t,GEo.Predicted(:,2,k),'k');
        plot(t,GE.Predicted(:,2,k),'r');
        plot(t,GBa.Predicted(:,2,k),'g');
        plot(t,GB.Predicted(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        set(gca,'YTick',yt1);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},...
                        'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - GEo.Predicted(:,2,k),'k');
        box on;grid on;hold on;
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        datetick('x');
        set(gca,'XTickLabel',[]);        
        [lh,lo] = legend(sprintf('Model 1 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
            GEo.PE(1,2,k),...
            GEo.CC(1,2,k),...
            GEo.MSE(1,2,k)),...            
            'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - GE.Predicted(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 2 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
            GE.PE(1,2,k),...
            GE.CC(1,2,k),...
            GE.MSE(1,2,k)),...            
            'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - GBa.Predicted(:,2,k),'g');
        box on;grid on;hold on;
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 3 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
            GBa.PE(1,2,k),...
            GBa.CC(1,2,k),...            
            GBa.MSE(1,2,k)),...            
            'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - GB.Predicted(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl3); 
        set(gca,'YTick',yt3);
        [lh,lo] = legend(sprintf('Model 4 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
                GB.PE(1,2,k),...
                GB.CC(1,2,k),...
                GB.MSE(1,2,k)),...                
            'Location','NorthWest');
        set(lo,'LineWidth',2);        
        datetick('x');
        datetick_adjust();
 
    if writepng
        fname = sprintf('%s/plot_GIC_predictions-InSample-%s-v%d-o%d.pdf',...
                        fdir,start,codever,oos_aves);        
        figsave(fname);
    else
        axes(ha(1));
        title('In-sample model predictions');
    end
        
    fh = figure(2);clf;
    ha = tight_subplot(5,1,[0.015,0.015],[0.05,0.02],[0.04,0.04]);
    set(fh,'DefaultAxesFontSize',10);
    
    yl1 = [-1.5,1.5]*1.01;
    yl2 = [-0.75,0.75]*1.01;
    yt1  = [-1.5:0.5:1.5];
    yt2  = [-0.75:0.25:0.75];

    axes(ha(1));
        plot(t,GIC,'c');
        box on;grid on;hold on;
        plot(t,GEo_avg.Mean.Predicted(:,2,k),'k');
        plot(t,GE_avg.Mean.Predicted(:,2,k),'r');
        plot(t,GBa_avg.Mean.Predicted(:,2,k),'g');
        plot(t,GB_avg.Mean.Predicted(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        set(gca,'YTick',yt1);
        %set(gca,'XLim',[t(1),t(end)]);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},...
                        'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - GEo_avg.Mean.Predicted(:,2,k),'k');
        box on;grid on;hold on;
        %set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);        
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);
        if 0
        [lh,lo] = legend(sprintf('Model 1 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
            GEo_avg.Mean.PE(1,2,k),...
            GEo_avg.Mean.CC(1,2,k),...
            GEo_avg.Mean.MSE(1,2,k)),...
            'Location','NorthWest');
        else
        [lh,lo] = legend(sprintf('Model 1 Error; PE = %.2f',...
            GEo_avg.Mean.PE(1,2,k)),...
            'Location','NorthWest');
        end
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - GE_avg.Mean.Predicted(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);
        if 0
        [lh,lo] = legend(sprintf('Model 2 Error; PE/CC/MSE = %.2f/%.2f/%.4f',...
            GE_avg.Mean.PE(1,2,k),...
            GE_avg.Mean.CC(1,2,k),...
            GE_avg.Mean.MSE(1,2,k)),...
            'Location','NorthWest');
        else
        [lh,lo] = legend(sprintf('Model 2 Error; PE = %.2f',...
            GE_avg.Mean.PE(1,2,k)),...
            'Location','NorthWest');
        end
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - GBa_avg.Mean.Predicted(:,2,k),'g');
        box on;grid on;hold on;
        %set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);        
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);
        if 0
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f/%.2f/%.4f',...
            GBa_avg.Mean.PE(1,2,k),...
            GBa_avg.Mean.CC(1,2,k),...
            GBa_avg.Mean.MSE(1,2,k)),...
            'Location','NorthWest');
        else
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f',...
            GBa_avg.Mean.PE(1,2,k)),...
            'Location','NorthWest');
        end
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - GB_avg.Mean.Predicted(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl2); 
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);
        plot([t(1),t(end)],[0,0],'k-');       
        if 0
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f/%.2f/%.4f',...
            GB_avg.Mean.PE(1,2,k),...
            GB_avg.Mean.CC(1,2,k),...
            GB_avg.Mean.MSE(1,2,k)),...
            'Location','NorthWest');
        else
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f',...
            GB_avg.Mean.PE(1,2,k)),...
            'Location','NorthWest');
        end
        set(lo,'LineWidth',2);        
        datetick('x');
        datetick_adjust();
        
        
    if writepng
        fname = sprintf('%s/plot_GIC_predictions-MeanModel-%s-v%d-o%d.pdf',...
                        fdir,start,codever,oos_aves);
        figsave(fname);
    else
        axes(ha(1));        
        title('Mean model predictions');
        input('Continue');
    end
    
end