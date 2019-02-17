
if ~exist('F','var')
    filestr = 'options-1';
    png = 0;
    allfigs = 0;

    dirfig = sprintf('figures/combined');
    if ~exist(dirfig,'dir')
        mkdir(dirfig);
    end

    file = sprintf('mat/main_%s.mat','options-1');
    fprintf('plot_model_predictions: Loading %s\n',file);
    F = load(file);
    fprintf('plot_model_predictions: Loaded %s\n',file);    
end

fdir = 'figures/predictions';
png = 0;
figprep(png,1000,800);

for k = 22:22%size(F.GE.Predicted,3)
%for k = 9:size(F.GE.Predicted,3)

    t = datenum('1970-01-01') + F.GE.Time(:,1,k)/(86400*1000); % Convert from Unix Time to ML datenum.
    start = datestr(t(1),'yyyy-mm-dd');
    GIC = F.GE.Out(:,2,k);

    figure(1);clf;

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
        plot(t,F.GEo.Predicted(:,2,k),'k');
        plot(t,F.GE.Predicted(:,2,k),'r');
        plot(t,F.GBa.Predicted(:,2,k),'g');
        plot(t,F.GB.Predicted(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        set(gca,'YTick',yt1);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - F.GEo.Predicted(:,2,k),'k');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        datetick('x');
        set(gca,'XTickLabel',[]);        
        [lh,lo] = legend(sprintf('Model 1 Error; PE = %.2f',F.GEo.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - F.GE.Predicted(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 2 Error; PE = %.2f',F.GE.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - F.GBa.Predicted(:,2,k),'g');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f',F.GBa.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - F.GB.Predicted(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl3); 
        set(gca,'YTick',yt3);
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f',F.GB.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
        datetick('x');
        datetick_adjust();
        %text(t(1),1*dy+dy/4,sprintf('Model 1 Error; PE = %.2f',F.GEo.PE(k,2)));
        %text(t(1),2*dy+dy/4,sprintf('Model 2 Error; PE = %.2f',F.GE.PE(k,2)));
        %text(t(1),3*dy+dy/4,sprintf('Model 3 Error; PE = %.2f',F.GBa.PE(k,2)));
        %text(t(1),4*dy+dy/4,sprintf('Model 4 Error; PE = %.2f',F.GB.PE(k,2)));
        %xlabel(sprintf('Days since %s',dateox));
        %ylabel('GIC tick separation')
 
    if png
        figsave(sprintf('%s/plot_model_predictions-InSample-%s.pdf',fdir,start));
    else
        axes(ha(1));
        title('In-sample model predictions');
    end
        
    figure(2);clf;
    ha = tight_subplot(5,1,[0.015,0.015],[0.05,0.02],[0.04,0.04]);

    yl1 = [-1.5,1.5]*1.01;
    yl2 = [-0.75,0.75]*1.01;

    yt1  = [-1.5:0.5:1.5];
    yt2  = [-0.75:0.25:0.75];
    
    axes(ha(1));
        plot(t,GIC,'c');
        box on;grid on;hold on;
        plot(t,F.GEo_avg.Mean.Predicted(:,2,k),'k');
        plot(t,F.GE_avg.Mean.Predicted(:,2,k),'r');
        plot(t,F.GBa_avg.Mean.Predicted(:,2,k),'g');
        plot(t,F.GB_avg.Mean.Predicted(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        set(gca,'YTick',yt1);
        %set(gca,'XLim',[t(1),t(end)]);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - F.GEo_avg.Mean.Predicted(:,2,k),'k');
        box on;grid on;hold on;
        %set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);        
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);        
        [lh,lo] = legend(sprintf('Model 1 Error; PE = %.2f',F.GEo_avg.Mean.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - F.GE_avg.Mean.Predicted(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);        
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 2 Error; PE = %.2f',F.GE_avg.Mean.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - F.GBa_avg.Mean.Predicted(:,2,k),'g');
        box on;grid on;hold on;
        %set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);        
        plot([t(1),t(end)],[0,0],'k-');       
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f',F.GBa_avg.Mean.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - F.GB_avg.Mean.Predicted(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl2); 
        set(gca,'YTick',yt2);
        %set(gca,'XLim',[t(1),t(end)]);
        plot([t(1),t(end)],[0,0],'k-');       
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f',F.GB_avg.Mean.PE(1,2,k)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
        datetick('x');
        datetick_adjust();
        
    if png
        figsave(sprintf('%s/plot_model_predictions-MeanModel-%s.pdf',fdir,start));
    else
        axes(ha(1));        
        title('Out-of-sample model predictions');
    end
    
    input('Continue');
    
end