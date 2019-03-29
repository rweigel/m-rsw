function plot_timeseries(dateo,intervalno,filestr,png)

dirfig = sprintf('figures/%s',dateo);
dirmat = sprintf('mat/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));
load(sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,intervalno));

fn = 0;

showpred = 1;

figprep(png,1000,500);

%Use this to find spikes:
%plot(E)
%Click on spikes using data cursor in figure window
%dcm1 = datacursormode(gcf());
%set(dcm1, 'UpdateFcn', @(obj,event) get(event, 'Position'), 'Enable', 'on');

%% 1-second magnetic field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t/86400,B(:,1:2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[nT]')
    th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('$B_x$','$B_y$','Location','Best');
    %if png,print('-dpng',sprintf('%s/timeseries_B_%s-%d.png',dirfig,dateo,intervalno));end

%% 1-second electric field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[mV/km]')
    %th = title('Memambetsu Magnetic Observatory (MMB)');
    if showpred
        plot(t/86400,E(:,1)+10,'k','LineWidth',1);
        plot(t/86400,EB_Prediction(:,1)+10,'b','LineWidth',1)
        plot(t/86400,E(:,1)-EB_Prediction(:,1)+30,'r','LineWidth',1)
        
        plot(t/86400,E(:,2)-10,'k','LineWidth',1);
        plot(t/86400,EB_Prediction(:,2)-10,'b','LineWidth',1)
        plot(t/86400,E(:,2)-EB_Prediction(:,2)-30,'r','LineWidth',1)

        [lh,lo] = legend(...
                         '$E_x$',...
                         sprintf('$E_x$ predicted PE = %.2f',EB_PE(1)),...
                         '$E_x$ prediction error',...
                         '$E_y$',...
                         sprintf('$E_y$ predicted PE = %.2f',EB_PE(1)),...
                         '$E_y$ prediction error');
                     
    else
        plot(t/86400,E(:,1),'b','LineWidth',1);
        plot(t/86400,E(:,2),'k','LineWidth',1);       
        [lh,lo] = legend('$E_x$','$E_y$','Location','NorthWest');
    end
    %figconfig
    %if png,print('-dpng',sprintf('%s/timeseries_E_%s-%d.png',dirfig,dateo,intervalno));end

%% 1-second GIC measurements from Watari
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    if showpred
        plot(t/86400,GIC(:,2),'b');
        plot(t/86400,GEo_Prediction(:,2),'k');
        plot(t/86400,GE_Prediction(:,2),'r');
        plot(t/86400,GBa_Prediction(:,2),'g');
        plot(t/86400,GB_Prediction(:,2),'b');
        plot(t/86400,GEo_Prediction(:,2)-GIC(:,2)-2,'k');
        plot(t/86400,GE_Prediction(:,2)-GIC(:,2)-3,'r');
        plot(t/86400,GBa_Prediction(:,2)-GIC(:,2)-4,'g');
        plot(t/86400,GB_Prediction(:,2)-GIC(:,2)-5,'b');
        [lh,lo] = legend('GIC',...
            sprintf('Model 1 PE = %.2f',GEo_PE(2)),...
            sprintf('Model 2 PE = %.2f',GE_PE(2)),...
            sprintf('Model 3 PE = %.2f',GBa_PE(2)),...
            sprintf('Model 4 PE = %.2f',GB_PE(2)),...
            sprintf('Model 1 Error'),...
            sprintf('Model 2 Error'),...
            sprintf('Model 3 Error'),...
            sprintf('Model 4 Error'),...
            'Location','Best');
    else
        plot(t/86400,GIC(:,1));
        plot(t/86400,GIC(:,2));
        [lh,lo] = legend('GIC','Despiked','Location','Best');
    end
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[A]');
    th = title('Memambetsu 187 kV substation');    
    %figconfig
    %if png,print('-dpng',sprintf('%s/timeseries_GIC_%s-%d.png',dirfig,dateo,intervalno));end
