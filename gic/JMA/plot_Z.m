function plot_Z(dateo,intervalno,filestr,png)

dirmat = sprintf('mat/%s',dateo);
dirfig = sprintf('figures/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));

fhs = findobj('Type', 'figure');
fn = length(fhs);

T = 1./GE_fe(2:end);

%% Plot Zxxs and Zxy for GIC/E and GIC/B
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;
    plot(T,abs(GE_Z(2:end,3)),'r','LineWidth',2);
    plot(T,abs(GE_Z(2:end,4)),'g','LineWidth',2);
    plot(T,abs(GB_Z(2:end,3)),'b','LineWidth',2);
    plot(T,abs(GB_Z(2:end,4)),'k','LineWidth',2);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    [lh,lo] = legend('$Z_{xx}$ GIC/E','$Z_{xy}$ GIC/E','$Z_{xx}$ GIC/B','$Z_{xy}$ GIC/B','Location','Best');
    %figconfig
    if png,print('-dpng',sprintf('%s/Z_GE_GB_%s-%d.png',dirfig,dateo,intervalno));end

%% Plot Pxxs and Pxy for GIC/E and GIC/B
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;
    plot(T,abs(GE_Phi(2:end,3)),'r','MarkerSize',10);
    plot(T,abs(GE_Phi(2:end,4)),'g','MarkerSize',10);
    plot(T,abs(GB_Phi(2:end,3)),'b','MarkerSize',10);
    plot(T,abs(GB_Phi(2:end,4)),'k','MarkerSize',10);
    set(gca, 'XScale', 'log');
    [lh,lo] = legend('$\phi_{xx}$ GIC/E','$\phi_{xy}$ GIC/E','$\phi_{xx}$ GIC/B','$\phi_{xy}$ GIC/B','Location','Best');
    %figconfig
    if png,print('-dpng',sprintf('%s/Z_Phi_GE_GB_%s-%d.png',dirfig,dateo,intervalno));end

return    
%% Plot Z for E/B
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' Z E/B']);clf;hold on;box on;grid on;
    plot(T,abs(EB_Z(2:end,1)),'r','LineWidth',2);
    plot(T,abs(EB_Z(2:end,2)),'g','LineWidth',2);
    plot(T,abs(EB_Z(2:end,3)),'b','LineWidth',2);
    plot(T,abs(EB_Z(2:end,4)),'k','LineWidth',2);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    [lh,lo] = legend('$Z_{xx}$ E/B','$Z_{xy}$ E/B','$Z_{yx}$ E/B','$Z_{yy}$ E/B','Location','Best');
    %figconfig
    if png,print('-dpng',sprintf('%s/Z_EB_%s-%d.png',dirfig,dateo,intervalno));end

%% Plot phi for E/B
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;
    plot(T,abs(Phi_EB(2:end,1)),'r','MarkerSize',10);
    plot(T,abs(Phi_EB(2:end,2)),'g','MarkerSize',10);
    plot(T,abs(Phi_EB(2:end,3)),'b','MarkerSize',10);
    plot(T,abs(Phi_EB(2:end,4)),'k','MarkerSize',10);
    set(gca, 'XScale', 'log');
    [lh,lo] = legend('\phi_{xx} E/B','\phi_{xy} E/B','\phi_{xx} E/B','\phi_{xy} E/B','Location','Best');
    %figconfig
    if png,print('-dpng',sprintf('%s/Phi_EB_%s-%d.png',dirfig,dateo,intervalno));end
