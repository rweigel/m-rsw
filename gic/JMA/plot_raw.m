function plot_raw(tGIC,GIC,tE,E,tB,B,dateo)

dirfig = sprintf('figures/%s',dateo);

png = 0;

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

fhs = findobj('Type', 'figure');
fn = length(fhs);

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
