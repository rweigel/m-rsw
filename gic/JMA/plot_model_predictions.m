
if 0
    filestr = 'options-1';
    png = 0;
    allfigs = 0;

    dirfig = sprintf('figures/combined');
    if ~exist(dirfig,'dir')
        mkdir(dirfig);
    end

    fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
    fprintf('compute_TF_aves.m: Loading %s\n',fnamemat);
    FIO = load(fnamemat);

    file = sprintf('mat/compute_TF_aves-%s.mat',filestr);
    fprintf('plot_TF_aves: Loading from %s\n',file);
    F = load(file);
end

png = 1;
figprep(png,1000,800);

start = datestr(datenum(dateox) + F.GE.Seconds(22,1)/86400,'yyyymmddThhMMSS');

for k = 22:22%size(F.GE.Prediction,3)

    fdir = sprintf('figures/%s',F.GE.Dateo{k});
    t = [F.GE.Seconds(k,1):F.GE.Seconds(k,2)]'/86400;
    t = t + datenum(dateox);
    dateox = datestr(datenum(F.GE.Dateo{k},'yyyymmdd'),'yyyy-mm-dd');
    GIC = FIO.IO.GIC(:,2,k);

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
        plot(t,F.GEo.Prediction(:,2,k),'k');
        plot(t,F.GE.Prediction(:,2,k),'r');
        plot(t,F.GBa.Prediction(:,2,k),'g');
        plot(t,F.GB.Prediction(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        set(gca,'YTick',yt1);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - F.GEo.Prediction(:,2,k),'k');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        datetick('x');
        set(gca,'XTickLabel',[]);        
        [lh,lo] = legend(sprintf('Model 1 Error; PE = %.2f',F.GEo.PE(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - F.GE.Prediction(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 2 Error; PE = %.2f',F.GE.PE(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - F.GBa.Prediction(:,2,k),'g');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f',F.GBa.PE(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - F.GB.Prediction(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl3); 
        set(gca,'YTick',yt3);
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f',F.GB.PE(k,2)),'Location','NorthWest');
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

    yl1 = [-1,1.5]*1.01;
    yl2 = [-1,1]*1.01;
    yl3 = [-0.5,0.5]*1.01;

    yt1  = [-1:0.5:1.5];
    yt2  = [-1:0.5:1];
    yt3  = [-0.5:0.25:0.5];
    
    axes(ha(1));
        plot(t,GIC,'c');
        box on;grid on;hold on;
        plot(t,F.GEo.Prediction_Mean(:,2,k),'k');
        plot(t,F.GE.Prediction_Mean(:,2,k),'r');
        plot(t,F.GBa.Prediction_Mean(:,2,k),'g');
        plot(t,F.GB.Prediction_Mean(:,2,k),'b');
        plot(t,GIC,'c');
        set(gca,'YLim',yl1);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend({'GIC [A]','Model 1','Model 2','Model 3','Model 4'},'Orientation','Horizontal','Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(2));
        plot(t,GIC - F.GEo.Prediction_Mean(:,2,k),'k');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl2);
        set(gca,'YTick',yt2);
        datetick('x');
        set(gca,'XTickLabel',[]);        
        [lh,lo] = legend(sprintf('Model 1 Error; PE = %.2f',F.GEo.PE_Mean(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);
    axes(ha(3));
        plot(t,GIC - F.GE.Prediction_Mean(:,2,k),'r');
        box on;grid on;hold on;
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 2 Error; PE = %.2f',F.GE.PE_Mean(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(4));
        plot(t,GIC - F.GBa.Prediction_Mean(:,2,k),'g');
        box on;grid on;hold on;
        set(gca,'YAxisLocation','right');
        set(gca,'YLim',yl3);
        set(gca,'YTick',yt3);
        datetick('x');
        set(gca,'XTickLabel',[]);
        [lh,lo] = legend(sprintf('Model 3 Error; PE = %.2f',F.GBa.PE_Mean(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
    axes(ha(5));
        plot(t,GIC - F.GB.Prediction(:,2,k),'b');
        box on;grid on;hold on;
        set(gca,'YLim',yl3); 
        set(gca,'YTick',yt3);
        [lh,lo] = legend(sprintf('Model 4 Error; PE = %.2f',F.GB.PE_Mean(k,2)),'Location','NorthWest');
        set(lo,'LineWidth',2);        
        datetick('x');
        datetick_adjust();
        
    if png
        figsave(sprintf('%s/plot_model_predictions-MeanModel-%s.pdf',fdir,start));
    else
        axes(ha(1));        
        title('Out-of-sample model predictions');
    end

break

    figure(3);clf;
        %plot(GIC,'k');
        box on;grid on;hold on;
        plot(t,1*dy + GIC - F.GEo.Prediction(:,2,k),'m');
        plot(t,2*dy + GIC - F.GE.Prediction(:,2,k),'r');
        plot(t,3*dy + GIC - F.GBa.Prediction(:,2,k),'g');
        plot(t,4*dy + GIC - F.GB.Prediction(:,2,k),'b');
        plot(t,1*dy + GIC - F.GEo.Prediction_Mean(:,2,k),'k');
        plot(t,2*dy + GIC - F.GE.Prediction_Mean(:,2,k),'k');
        plot(t,3*dy + GIC - F.GBa.Prediction_Mean(:,2,k),'k');
        plot(t,4*dy + GIC - F.GB.Prediction_Mean(:,2,k),'k');
        text(t(1),1*dy+dy/4,sprintf('Model 1 Error; PE = %.2f/%.2f',F.GEo.PE(2),F.GEo.PE_Mean(k,2)));
        text(t(1),2*dy+dy/4,sprintf('Model 2 Error; PE = %.2f/%.2f',F.GE.PE(2),F.GE.PE_Mean(k,2)));
        text(t(1),3*dy+dy/4,sprintf('Model 3 Error; PE = %.2f/%.2f',F.GBa.PE(2),F.GBa.PE_Mean(k,2)));
        text(t(1),4*dy+dy/4,sprintf('Model 4 Error; PE = %.2f/%.2f',F.GB.PE(2),F.GB.PE_Mean(k,2)));
        title('In-sample (color) and mean model (black) predictions');
        datetick('x');
        datetick_adjust();
        xlabel(sprintf('Days since %s',dateox));
        if png
            figsave(sprintf('%s/plot_model_predictions-InSample-and-MeanModel-%s.pdf',fdir,start));
        end
        
    figure(1);set(gca,'YLim',max([yl1;yl2]));
    figure(2);set(gca,'YLim',max([yl1;yl2]));
    figure(3);set(gca,'YLim',max([yl1;yl2]));
    
    input('Continue');
    
end