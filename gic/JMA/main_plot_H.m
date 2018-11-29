function main_plot_H(dateo,intervalno,png)

dirmat = sprintf('mat/%s',dateo);
dirfig = sprintf('figures/%s',dateo);

%load(sprintf('%s/main_%s.mat',dirmat,dateo));
load(sprintf('%s/mainCompute1_%s-%d.mat',dirmat,dateo,intervalno));
load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,intervalno));

fhs = findobj('Type', 'figure');
fn = length(fhs);

%% Response of GIC to impulse in E
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aEx(t) + bEy(t).
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;set(fh,'Name',[dateo,' GIC/E IRF']);
    plot(t_GE,1000*H_GE(:,3),'r','LineWidth',2);
    %plot(0,1000*ao/5,'r.','MarkerSize',30);
    plot(t_GE,1000*H_GE(:,2),'b','LineWidth',2);
    %plot(0,1000*bo/5,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 mV/km impulse at \tau = 0');
    %[lh,lo] = legend('FD a(\tau)','a_o/5','FD b(\tau)','b_o/5');
    [lh,lo] = legend('FD a(\tau)','FD b(\tau)','Location','Best');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_H_GIC_IRF_to_E_%s-%d.png',dirfig,dateo,intervalno));end
    
%% Response of GIC to impulse in B
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aBx(t) + bBy(t).
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;set(fh,'Name',[dateo,' GIC/B IRF']);
    plot(t_GB,1000*H_GB(:,3),'r','LineWidth',2);
    %plot(0,1000*aoB,'r.','MarkerSize',30);
    plot(t_GB,1000*H_GB(:,2),'b','LineWidth',2);
    %plot(0,1000*boB,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 nT impulse at \tau = 0');
    %[lh,lo] = legend('FD a(\tau)','a_o','FD b(\tau)','b_o');
    [lh,lo] = legend('FD a(\tau)','FD b(\tau)','Location','Best');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_H_GIC_IRF_to_B_%s-%d.png',dirfig,dateo,intervalno));end

return

%% Response of Ex to impulse in B
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;set(fh,'Name',[dateo,' Ex/B IRF']);
    plot(t_EB,H_EB(:,1),'r','LineWidth',2);
    plot(t_EB,H_EB(:,2),'b','LineWidth',2);
    xlabel('\tau [s]');
    ylabel('[mV/km]');
    th = title('E_x response to 1 nT impulse in B_x and B_y at \tau = 0');
    [lh,lo] = legend('H_{xx}(\tau)','H_{xy}(\tau)','Location','Best');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Ex_IRF_to_B_%s-%d.png',dirfig,dateo,intervalno));end
    
%% Response of Ey to impulse in B
fn=fn+1;fh=figure(fn);clf;hold on;box on;grid on;set(fh,'Name',[dateo,' Ey/B IRF']);
    plot(t_EB,H_EB(:,3),'r','LineWidth',2);
    plot(t_EB,H_EB(:,4),'b','LineWidth',2);
    xlabel('\tau [s]');
    ylabel('[mV/km]');
    th = title('E_y response to 1 nT impulse in B_x and B_y at \tau = 0');
    [lh,lo] = legend('H_{yx}(\tau)','H_{yy}(\tau)','Location','Best');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Ey_IRF_to_B_%s-%d.png',dirfig,dateo,intervalno));end
