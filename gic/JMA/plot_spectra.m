function plot_spectra(dateo,intervalno,filestr,png)

dirfig = sprintf('figures/%s',dateo);
dirmat = sprintf('mat/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

fe = fe_EB; % Same for all

fhs = findobj('Type', 'figure');
fn = length(fhs);

fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' PSD']);clf;
    loglog(1./fe(2:end),sqrt(SG(2:end,2)),'b','LineWidth',2)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(SE(2:end,1)),'r','LineWidth',2)
    loglog(1./fe(2:end),sqrt(SE(2:end,2)),'g','LineWidth',2)
    loglog(1./fe(2:end),sqrt(SB(2:end,1)),'k','LineWidth',2)
    loglog(1./fe(2:end),sqrt(SB(2:end,2)),'m','LineWidth',2)
    [lh,lo] = legend('GIC','E_x','E_y','B_x','B_y','Location','Best');
    ylabel('Power')
    figconfig;
    if png,print('-dpng',sprintf('%s/All_spectra_%s-%d.png',dirfig,dateo,intervalno));end

fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' GIC PSD errors']);clf;
    loglog(1./fe(2:end),sqrt(SG(2:end,2)),'b','LineWidth',2)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(Serr_GE(2:end,2)),'r-.','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_GB(2:end,2)),'g-.','LineWidth',2)
    [lh,lo] = legend('Measured','G/E Error','G/B Error','Location','Best');
    ylabel('Power')
    figconfig;
    if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' E PSD errors']);clf;
    loglog(1./fe(2:end),sqrt(SE(2:end,1)),'r-','LineWidth',2)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(SE(2:end,2)),'g-','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_EB(2:end,1)),'r-.','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_EB(2:end,2)),'g-.','LineWidth',2)
    [lh,lo] = legend('E_x','E_y','E_x error','E_y error','Location','Best');
    ylabel('Power')
    figconfig;
    if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

return

N = size(GICp_GB_Ave,1);
window = ones(N/8,1);
noverlap = N/16;
w = 2*pi*fe_EB;

err = GICp_GB_Ave(:,2)-GICp_GE_Ave(:,2);
[Perr_between,ferr] = pwelch(err,window,noverlap,w);
[C_between,fc] = mscohere(GICp_GB_Ave(:,2),GICp_GE_Ave(:,2),window,noverlap,w);

[Perr_GE,ferr] = pwelch(errorE,window,noverlap,w);
[C_GE,fc] = mscohere(All.GIC(:,3),GICp_GE_Ave(:,2),window,noverlap,w);

[Perr_GB,ferr] = pwelch(errorB,window,noverlap,w);
[C_GB,fc] = mscohere(All.GIC(:,3),GICp_GB_Ave(:,2),window,noverlap,w);
    
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' coherence']);clf;
    semilogx(2*pi./fc(2:end),C_GE(2:end),'r','LineWidth',2)
    hold on;box on;grid on;
    semilogx(2*pi./fc(2:end),C_GB(2:end),'g','LineWidth',2)
    semilogx(2*pi./fc(2:end),C_between(2:end),'b','LineWidth',1)
    [lh,lo] = legend('G/E','G/B','G/B-G/E','Location','South');
    ylabel('Coherence')
    figconfig;
    if png,print('-dpng',sprintf('%s/GE_GB_coherence_%s.png',dirfig,dateo));end

      
