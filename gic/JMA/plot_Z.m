function plot_Z(dateo,intervalno,png)

dirmat = sprintf('mat/%s',dateo);
dirfig = sprintf('figures/%s',dateo);

load(sprintf('%s/compute_TF_%s-%d.mat',dirmat,dateo,intervalno));

fhs = findobj('Type', 'figure');
fn = length(fhs);

%% Plot Zxxs and Zxy for GIC/E and GIC/B
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' Z_{xx_yy} GIC/{E,B}']);clf;hold on;box on;grid on;
%    Z_GB_Alt(:,1) = Z_EB_Ave(:,1).*Z_GE_Ave(:,1) + Z_EB_Ave(:,3).*Z_GE_Ave(:,2); 
%    Z_GB_Alt(:,2) = Z_EB_Ave(:,2).*Z_GE_Ave(:,1) + Z_EB_Ave(:,4).*Z_GE_Ave(:,2); 
    plot(1./fe_GE(2:end),abs(Z_GE(2:end,3)),'r','LineWidth',2);
    plot(1./fe_GB(2:end),abs(Z_GE(2:end,4)),'g','LineWidth',2);
    plot(1./fe_GE(2:end),abs(Z_GB(2:end,3)),'b','LineWidth',2);
    plot(1./fe_GB(2:end),abs(Z_GB(2:end,4)),'k','LineWidth',2);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    [lh,lo] = legend('Z_{xx} GIC/E','Z_{xy} GIC/E','Z_{xx} GIC/B','Z_{xy} GIC/B','Location','Best');
    figconfig
    if png,print('-dpng',sprintf('%s/Z_GE_GB_%s-%d.png',dirfig,dateo,intervalno));end

for j = 1:4
    Phi_GB(:,j) = (180/pi)*atan2(imag(Z_GB(:,j)),real(Z_GB(:,j)));
    Phi_GE(:,j) = (180/pi)*atan2(imag(Z_GE(:,j)),real(Z_GE(:,j)));
    Phi_EB(:,j) = (180/pi)*atan2(imag(Z_EB(:,j)),real(Z_EB(:,j)));
end

%% Plot Pxxs and Pxy for GIC/E and GIC/B
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' Phi_{xx,xy} GIC/{E,B}']);clf;hold on;box on;grid on;
    plot(1./fe_GE(2:end),abs(Phi_GE(2:end,3)),'r','MarkerSize',10);
    plot(1./fe_GB(2:end),abs(Phi_GE(2:end,4)),'g','MarkerSize',10);
    plot(1./fe_GE(2:end),abs(Phi_GB(2:end,3)),'b','MarkerSize',10);
    plot(1./fe_GB(2:end),abs(Phi_GB(2:end,4)),'k','MarkerSize',10);
    set(gca, 'XScale', 'log');
    [lh,lo] = legend('\phi_{xx} GIC/E','\phi_{xy} GIC/E','\phi_{xx} GIC/B','\phi_{xy} GIC/B','Location','Best');
    figconfig
    if png,print('-dpng',sprintf('%s/Z_Phi_GE_GB_%s-%d.png',dirfig,dateo,intervalno));end

return    
%% Plot Z for E/B
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' Z E/B']);clf;hold on;box on;grid on;
%    Z_GB_Alt(:,1) = Z_EB_Ave(:,1).*Z_GE_Ave(:,1) + Z_EB_Ave(:,3).*Z_GE_Ave(:,2); 
%    Z_GB_Alt(:,2) = Z_EB_Ave(:,2).*Z_GE_Ave(:,1) + Z_EB_Ave(:,4).*Z_GE_Ave(:,2); 
    plot(1./fe_EB(2:end),abs(Z_EB(2:end,1)),'r','LineWidth',2);
    plot(1./fe_EB(2:end),abs(Z_EB(2:end,2)),'g','LineWidth',2);
    plot(1./fe_EB(2:end),abs(Z_EB(2:end,3)),'b','LineWidth',2);
    plot(1./fe_EB(2:end),abs(Z_EB(2:end,4)),'k','LineWidth',2);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    [lh,lo] = legend('Z_{xx} E/B','Z_{xy} E/B','Z_{yx} E/B','Z_{yy} E/B','Location','Best');
    figconfig
    if png,print('-dpng',sprintf('%s/Z_EB_%s-%d.png',dirfig,dateo,intervalno));end

%% Plot phi for E/B
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' Phi E/B']);clf;hold on;box on;grid on;
    plot(1./fe_EB(2:end),abs(Phi_EB(2:end,1)),'r','MarkerSize',10);
    plot(1./fe_EB(2:end),abs(Phi_EB(2:end,2)),'g','MarkerSize',10);
    plot(1./fe_EB(2:end),abs(Phi_EB(2:end,3)),'b','MarkerSize',10);
    plot(1./fe_EB(2:end),abs(Phi_EB(2:end,4)),'k','MarkerSize',10);
    ;set(gca, 'XScale', 'log');
    [lh,lo] = legend('\phi_{xx} E/B','\phi_{xy} E/B','\phi_{xx} E/B','\phi_{xy} E/B','Location','Best');
    figconfig
    if png,print('-dpng',sprintf('%s/Phi_EB_%s-%d.png',dirfig,dateo,intervalno));end
