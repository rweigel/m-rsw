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

sf = size(B,1)/2;

%set(fh,'Name',[dateo,' PSD'])
fn=fn+1;fh=figure(fn);clf;
    loglog(1./fe(2:end),sqrt(SG(2:end,2))/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(SE(2:end,1))/sf,'r','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),sqrt(SE(2:end,2))/sf,'g','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),sqrt(SB(2:end,1))/sf,'k','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),sqrt(SB(2:end,2))/sf,'m','LineWidth',2,'Marker','.','MarkerSize',15)
    vlines(1/fe(end))
    [lh,lo] = legend('GIC [A]','E_x [mV/km]','E_y [mV/km]','B_x [nT]','B_y [nT]','Location','Best');
    ylabel('Power Spectra')
    %figconfig;
    if png,print('-dpng',sprintf('%s/All_spectra_%s-%d.png',dirfig,dateo,intervalno));end

N = size(GICp_GB,1);
window = ones(N/8,1);
noverlap = N/16;
%w = 2*pi*fe_EB;

err = GIC(:,2)-GICp_GE(:,2);
[Perr,ferr] = pwelch(err,window,noverlap);

keyboard

[C_between,fc] = mscohere(GICp_GB_Ave(:,2),GICp_GE_Ave(:,2),window,noverlap,w);


fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' GIC PSD errors']);clf;
    loglog(1./fe(2:end),sqrt(SG(2:end,2)),'b','LineWidth',2)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(Serr_GE(2:end,2)),'r-.','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_GB(2:end,2)),'g-.','LineWidth',2)
    [lh,lo] = legend('Measured','G/E Error','G/B Error','Location','Best');
    ylabel('Power')
    %figconfig;
    if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' E PSD errors']);clf;
    loglog(1./fe(2:end),sqrt(SE(2:end,1)),'r-','LineWidth',2)
    hold on;box on;grid on;
    loglog(1./fe(2:end),sqrt(SE(2:end,2)),'g-','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_EB(2:end,1)),'r-.','LineWidth',2)
    loglog(1./fe(2:end),sqrt(Serr_EB(2:end,2)),'g-.','LineWidth',2)
    [lh,lo] = legend('E_x','E_y','E_x error','E_y error','Location','Best');
    ylabel('Power')
    %figconfig;
    if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

 
if (0)
N = size(GICp_GB,1);
window = ones(N/8,1);
noverlap = N/16;
%w = 2*pi*fe_EB;

keyboard
err = GIC(:,2)-GICp_GE(:,2);
[Perr,ferr] = pwelch(err,window,noverlap);
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
end

end

function vlines(m)
    yl = get(gca,'YLim');
    loglog([60,60],yl,'--','Color',[0.5,0.5,0.5]);
    text(60,yl(1),'1m','VerticalAlignment','bottom');

    if m < 3600*2
        yl = get(gca,'YLim');
        loglog([60*60,60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(60*60,yl(1),'1h','VerticalAlignment','bottom');
    end
    if m < 86400
        yl = get(gca,'YLim');
        loglog([12*60*60,12*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(12*60*60,yl(1),'12h','VerticalAlignment','bottom');
    end
    if m < 86400/2
        yl = get(gca,'YLim');
        loglog([6*60*60,6*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(6*60*60,yl(1),'6h','VerticalAlignment','bottom');
    end        
    if m < 86400*2
        yl = get(gca,'YLim');
        loglog([24*60*60,24*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(24*60*60,yl(1),'1d','VerticalAlignment','bottom');
    end    
end   


