function plot_raw(tGIC,GIC,tE,E,tB,B,dateo,png,giclabels)

dirfig = sprintf('figures/%s',dateo);

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

figure;clf;orient tall

ha = tight_subplot(3,1,[0.01,0.01],[0.1,0.02],[0.1,0.02]);
tB = tB + 86400;
tE = tE + 86400;
tGIC = tGIC + 86400;

dateox = datestr(-1 + datenum(dateo,'yyyymmdd'),'yyyy-mm-dd');
axes(ha(1));
    plot(tB/86400,B);
    grid on;box on;
    %xlabel(sprintf('Days since %s',dateo));
    ylabel('[nT]')
    ytl = get(gca,'YTickLabel');
    ytl{1} = ' ';
    set(gca,'YTickLabel',ytl);
    set(gca,'XTickLabel',[])
    xlim([tB(1)/86400,tB(end)/86400])
    %th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('B_x','B_y','B_z','Location','SouthWest');
axes(ha(2));%
    plot(tE/86400,E);
    grid on;box on;
    %xlabel(sprintf('Days since %s',dateo));
    ylabel('[mV/km]')
    ytl = get(gca,'YTickLabel');
    ytl{1} = ' ';
    set(gca,'YTickLabel',ytl);
    set(gca,'XTickLabel',[])
    xlim([tB(1)/86400,tB(end)/86400])
    %th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('E_x','E_y','Location','NorthWest');
axes(ha(3));%grid on;box on;hold on;
    plot(tGIC/86400,GIC);
    %datetick('x','yyyy-mm-dd')
    grid on;box on;
    [lh,lo] = legend(giclabels,'Location','SouthWest');
    %xlabel(sprintf('Days since %s',dateo));
    ylabel('[A]');
    %th = title('Memambetsu 187 kV substation');    
    xlabel(sprintf('Days since %s',dateox));
    xlim([tB(1)/86400,tB(end)/86400])

if png,print('-dpng',sprintf('%s/plot_raw_All_%s.png',dirfig,dateo));end
if png,print('-dpdf',sprintf('%s/plot_raw_All_%s.pdf',dirfig,dateo));end

return

png = 1
%% 1-second magnetic field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;figure(fn);clf;hold on;box on;grid on;
    plot(tB/86400,B);
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[nT]')
    th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('B_x','B_y','B_z','Location','NorthWest');
    figconfig;
    %if png,print('-dpng',sprintf('%s/main_plot_B_%s-%d.png',dirfig,dateo,intervalno));end

%% 1-second electric field measurements
% From http://www.kakioka-jma.go.jp/obsdata/metadata/en on 07/01/2017
fn=fn+1;figure(fn);clf;hold on;box on;grid on;
    plot(tE/86400,E);
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[mV/km]')
    th = title('Memambetsu Magnetic Observatory (MMB)');
    [lh,lo] = legend('E_x','E_y','Location','NorthWest');
    figconfig
    %if png,print('-dpng',sprintf('%s/main_plot_E_%s-%d.png',dirfig,dateo,intervalno));end
    
fn=fn+1;figure(fn);clf;hold on;box on;grid on;
    plot(tGIC/86400,GIC);
    [lh,lo] = legend('GIC @ 1 Hz','GIC @ 1 Hz; LPF @ 1 Hz','Location','SouthWest');
    xlabel(sprintf('Days since %s',dateo));
    ylabel('[A]');
    th = title('Memambetsu 187 kV substation');    
    figconfig
    %if png,print('-dpng',sprintf('%s/main_plot_GIC_%s-%d.png',dirfig,dateo,intervalno));end
