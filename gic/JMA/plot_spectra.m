function plot_spectra(dateo,intervalno,filestr,png)

dirfig = sprintf('figures/%s',dateo);
dirmat = sprintf('mat/%s',dateo);

load(sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno));
load(sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,intervalno));

Serr_GEo = smoothSpectra(GICp_GEo-GIC,'parzen');

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
fn=fn+1;figure(fn);clf;
    loglog(1./fe(2:end),SG(2:end,2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
    hold on;box on;grid on;
    loglog(1./fe(2:end),SE(2:end,1)/sf,'r','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),SE(2:end,2)/sf,'g','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),SB(2:end,1)/sf,'k','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),SB(2:end,2)/sf,'m','LineWidth',2,'Marker','.','MarkerSize',15)
    vlines(1/fe(end))
    %[lh,lo] = legend('GIC [A]','E_x [mV/km]','E_y [mV/km]','B_x [nT]','B_y [nT]','Location','Best');
    [lh,lo] = legend('GIC','E_x','E_y','B_x','B_y','Location','Best');
    ylabel('PSD')
    xlabel('Period [s]')
    %figconfig;
    if png,print('-dpng',sprintf('%s/All_spectra_%s-%d.png',dirfig,dateo,intervalno));end

fn=fn+1;figure(fn);clf;
    loglog(1./fe(2:end),SG(2:end,2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
    hold on;box on;grid on;
    loglog(1./fe(2:end),Serr_GEo(2:end,2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),Serr_GE(2:end,2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),Serr_GB(2:end,2)/sf,'k-.','LineWidth',2,'Marker','.','MarkerSize',15)

    vlines(1/fe(end))
    [lh,lo] = legend('GIC','G/Eo Error','G/E Error','G/B Error','Location','Best');
    ylabel('PSD');
    xlabel('Period [s]')
    %figconfig;
    if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

fn=fn+1;figure(fn);clf;
    loglog(1./fe(2:end),SE(2:end,1)/sf,'r-','LineWidth',2,'Marker','.','MarkerSize',15)
    hold on;box on;grid on;
    loglog(1./fe(2:end),SE(2:end,2)/sf,'g-','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),Serr_EB(2:end,1)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
    loglog(1./fe(2:end),Serr_EB(2:end,2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
    vlines(1/fe(end))
    [lh,lo] = legend('E_x','E_y','E_x error','E_y error','Location','Best');
    ylabel('PSD')
    xlabel('Period [s]')
    %figconfig;
    if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

end


