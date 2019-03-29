function plot_raw(tGIC,GIC,tE,E,tB,B,dateo,png,giclabels)

dirfig = sprintf('figures/%s',dateo);

figprep(png,1000,800);

figure;clf;orient tall

t = tGIC;

%ha = tight_subplot(3,1,[0.01,0.01],[0.05,0.02],[0.08,0.02]);
ha = tight_subplot(3,1,[0.015,0.015],[0.05,0.02],[0.055,0.04]);
    
xl = [min([tGIC(1),tE(1),tB(1)]),max([tGIC(end),tE(end),tB(end)])];
axes(ha(3));
    plot(tGIC,GIC);
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
    plot(tB,B(:,1:2));
    grid on;box on;hold on;
    if size(B,3) > 1
       plot(tB,squeeze(B(:,1:2,2)));
    end
    ylabel('[nT]');
    set(gca,'XLim',xl);
    datetick('x','HH:MM');
    datetick_adjust();
    set(gca,'XTickLabel',[]);
    if size(B,3) > 1
        [lh,lo] = legend('$B_x$ MMB','$B_y$ MMB','$B_x$ KAK','$B_y$ KAK','Location','SouthWest');
    else
        [lh,lo] = legend('$B_x$ MMB','$B_y$ MMB','Location','NorthWest');    
    end
    set(lo,'LineWidth',2);
axes(ha(2));
    plot(tE,E);
    grid on;box on;
    ylabel('[mV/km]')
    set(gca,'XLim',xl);
    datetick('x','HH:MM');
    datetick_adjust();
    set(gca,'XTickLabel',[]);    
    [lh,lo] = legend('$E_x$ MMB','$E_y$ MMB','Location','NorthWest');
    set(lo,'LineWidth',2);

if png
    figsave(sprintf('%s/plot_raw_All_%s.pdf',dirfig,dateo));
end
