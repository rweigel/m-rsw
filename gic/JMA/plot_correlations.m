function plot_correlations(dateo,intervalno,filestr,png)

dirfig = sprintf('figures/%s',dateo);
dirmat = sprintf('mat/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));
load(sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,intervalno));

fn = 0;

showpred = 1;

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

M = 3600*24;
% Compute cross correlation between E and GIC
[xc,lags] = xcorr(GIC(:,2),E(:,1),M,'coeff');
[~,ix] = max(xc);
fprintf('xcorr(GIC,Ex) max at %d s lag\n',lags(ix));

[yc,lags] = xcorr(GIC(:,2),E(:,2),M,'coeff');
[~,iy] = max(yc);
fprintf('xcorr(GIC,Ey) max at %d s lag\n',lags(iy));

[AC_GIC,lags] = xcorr(GIC(:,2),GIC(:,2),M,'coeff');

Er_GEo = GEo_Prediction(:,2)-GIC(:,2);
[AC_GEo,lags] = xcorr(Er_GEo,M,'coeff');

Er_GE = GE_Prediction(:,2)-GIC(:,2);
[AC_GE,lags] = xcorr(Er_GE,M,'coeff');

Er_GB = GB_Prediction(:,2)-GIC(:,2);
[AC_GB,lags] = xcorr(Er_GB,M,'coeff');

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    %plot(lags/3600,xc,'LineWidth',2);
    %plot(lags/3600,yc,'LineWidth',2);
    %plot(lags/3600,AC_GIC,'LineWidth',2);
    plot(lags/3600,AC_GEo,'LineWidth',2);
    plot(lags/3600,AC_GE,'LineWidth',2);    
    plot(lags/3600,AC_GB,'LineWidth',2);    
    xlabel('Lag [hrs]');
    [lh,lo] = legend('acorr(G/Eo Error)','acorr(G/E Error)','acorr(G/B Error)');
    %'xcorr(GIC,E_x)','xcorr(GIC,E_y)','acorr(GIC)',...

    %figconfig
    if png,print('-dpng',sprintf('%s/timeseries_xcorrelations_%s-%d.png',dirfig,dateo,intervalno));end