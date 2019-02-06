function plot_raw(tGIC,GIC,tE,E,tB,B,dateo,png,giclabels)

dirfig = sprintf('figures/%s',dateo);

figprep(png,1000,800);

figure;clf;orient tall

%[t,E,B] = timealign(tGIC,tE,E,B);

t = tGIC;

%ha = tight_subplot(3,1,[0.01,0.01],[0.05,0.02],[0.08,0.02]);
ha = tight_subplot(3,1,[0.015,0.015],[0.05,0.02],[0.055,0.04]);
    
tf = [t(1):t(end)]'/86400;
t = tf + datenum(dateo,'yyyymmdd');

xl = [t(1),t(end)];
axes(ha(3));
    plot(t,GIC);
    grid on;box on;
    ylabel('[A]');
    set(gca,'XLim',xl);
    datetick('x','HH:MM');
    datetick_adjust();
    xt = get(gca,'XTick');
    [lh,lo] = legend(giclabels,'Location','SouthWest');
    set(lo,'LineWidth',2);
    %th = title('Memambetsu 187 kV substation');    
axes(ha(1));
    plot(t,B(:,1:2));
    grid on;box on;
    %xlabel(sprintf('Days since %s',dateo));
    ylabel('[nT]');
    set(gca,'XLim',xl);
    datetick('x','HH:MM');
    datetick_adjust();
    set(gca,'XTickLabel',[]);    
    [lh,lo] = legend('$B_x$','$B_y$','Location','SouthWest');
    set(lo,'LineWidth',2);
    %th = title('Memambetsu Magnetic Observatory (MMB)');
axes(ha(2));
    plot(t,E);
    grid on;box on;
    ylabel('[mV/km]')
    set(gca,'XLim',xl);
    datetick('x','HH:MM');
    datetick_adjust();
    set(gca,'XTickLabel',[]);    
    [lh,lo] = legend('$E_x$','$E_y$','Location','NorthWest');
    set(lo,'LineWidth',2);
    %th = title('Memambetsu Magnetic Observatory (MMB)');

if png
    figsave(sprintf('%s/plot_raw_All_%s.pdf',dirfig,dateo));
else
    axes(ha(1));
    title('In-sample model predictions');
end
