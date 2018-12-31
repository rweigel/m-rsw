function plot_timeseries(dateo,intervalno,filestr,png)

dirfig = sprintf('figures/%s',dateo);
dirmat = sprintf('mat/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));

fn = 0;

showpred = 1;

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

%Use this to find spikes
%plot(E)
%Click on spikes using data cursor in figure window
%dcm1 = datacursormode(gcf());
%set(dcm1, 'UpdateFcn', @(obj,event) get(event, 'Position'), 'Enable', 'on');

%% 1-second magnetic field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t/86400,B);
    %plot(t,40*GIC(:,2),'k')
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[nT]')
    th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('B_x','B_y','B_z','Location','Best');
    figconfig;
    if png,print('-dpng',sprintf('%s/timeseries_B_%s-%d.png',dirfig,dateo,intervalno));end

%% 1-second electric field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[mV/km]')
    th = title('Memambetsu Magnetic Observatory (MMB)');
    if showpred
        plot(t/86400,E(:,1),'b','LineWidth',1);
        plot(t/86400,E(:,2),'k','LineWidth',1);
        plot(t/86400,Ep_EB(:,1),'b--','LineWidth',1)
        plot(t/86400,Ep_EB(:,2),'k--','LineWidth',1)
        PE_EB(1) = pe_nonflag(E(:,1),Ep_EB(:,1));
        PE_EB(2) = pe_nonflag(E(:,2),Ep_EB(:,2));
        [lh,lo] = legend('E_x','E_y',...
            sprintf('E_x predicted PE = %.2f',PE_EB(1)),...
            sprintf('E_y predicted PE = %.2f',PE_EB(2)),'Location','Best');
    else
        plot(t/86400,E(:,1),'b','LineWidth',1);
        plot(t/86400,E(:,2),'k','LineWidth',1);       
        [lh,lo] = legend('E_x','E_y','Location','NorthWest');
    end
    figconfig
    if png,print('-dpng',sprintf('%s/timeseries_E_%s-%d.png',dirfig,dateo,intervalno));end

%% 1-second GIC measurements
% From S. Watari via email.  Data file has two columns, one is 1-second
% data and the other is 1-second data low-pass-filtered at @ 1 Hz (no
% additional details are given for filter).  Results are not dependent on
% which column was used.
%
% This is the original data after converting from JST to UT.  Note that
% there appears to be a ~66-second shift in this data that clearly appears
% when the IRF is computed.  The computed GIC response to an impulse in E
% or B at time zero has a peak at -66 seconds.  This shift was made before
% all transfer function calculations.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    if showpred
        plot(t/86400,GIC(:,3),'b');
        plot(t/86400,GICp_GE(:,2),'r');
        plot(t/86400,GICp_GB(:,2),'g');
        plot(t/86400,GICp_GE(:,2)-GIC(:,3)+3,'r');
        plot(t/86400,GICp_GB(:,2)-GIC(:,3)+3,'g');
        PE_GE = pe_nonflag(GIC(:,2),GICp_GE(:,2));
        PE_GB = pe_nonflag(GIC(:,2),GICp_GB(:,2));
        [lh,lo] = legend('GIC Despiked',...
            sprintf('GIC G/E predicted PE = %.2f',PE_GE),...
            sprintf('GIC G/B predicted PE = %.2f',PE_GB),...
            sprintf('GIC G/E error (shifted +3)'),...
            sprintf('GIC G/B error (shifted +3)'),...
            'Location','SouthWest');
    else
        plot(t/86400,GIC(:,1));
        plot(t/86400,GIC(:,2));
        plot(t/86400,GIC(:,3));      
        [lh,lo] = legend('GIC @ 1 Hz','GIC @ 1 Hz; LPF @ 1 Hz','Despiked','Location','Best');
    end
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[A]');
    th = title('Memambetsu 187 kV substation');    
    figconfig
    if png,print('-dpng',sprintf('%s/timeseries_GIC_%s-%d.png',dirfig,dateo,intervalno));end

% Compute cross correlation between E and GIC
[xc,lags] = xcorr(GIC(:,2),E(:,1),60*60,'coeff');
[~,ix] = max(xc);
fprintf('xcorr(GIC,Ex) max at %d s lag\n',lags(ix));

[yc,lags] = xcorr(GIC(:,2),E(:,2),60*60,'coeff');
[~,iy] = max(yc);
fprintf('xcorr(GIC,Ey) max at %d s lag\n',lags(iy));

[gc,lags] = xcorr(GIC(:,2),GIC(:,2),60*60,'coeff');

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(lags/3600,xc,'LineWidth',2);
    plot(lags/3600,yc,'LineWidth',2);
    plot(lags/3600,gc,'LineWidth',2);
    xlabel('Lag [hrs]');
    [lh,lo] = legend('xcorr(GIC,E_x)','xcorr(GIC,E_y)','acorr(GIC)');
    figconfig
    if png,print('-dpng',sprintf('%s/timeseries_xcorrelations_%s.png',dirfig,dateo));end
