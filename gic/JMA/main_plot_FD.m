%% Setup
% Save images (requires each figure to open in new window for proper figure
% sizing; see figconfig.m)
addpath('../../stats'); % For PE calculation (PE_NONFLAG).

%% Load output of main.mat
load(sprintf('%s/mainCompute1_%s-%d.mat',dirmat,dateo,intervalno));
load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,intervalno));
   
%% Prediction of Ex using B as driver
% Using Time Domain (TD) and Frequency Domain (FD) method.
%
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tE(Ix),E(Ix,1));
    plot(tE(Ix),Ep_FD_EB(:,1));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('E_x [mV/km]');
    th = title('B driver');
    peo = pe_nonflag(E(Ix,1),Ep_FD_EB(:,1));
    [lh,lo] = legend('Measured',sprintf('FD; PE = %.2f',peo),'Location','SouthWest');
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_Expredicted_w_B_%s.png',dirfig,dateo));end
    fprintf('PE of Ex using B = %.2f\n',peo);
    
%% Prediction of Ey using B as driver
% Time domain method uses 60*5 causal and 60*5 acausal lag values.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tE(Ix),E(Ix,2));
    plot(tE(Ix),Ep_FD_EB(:,2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('E_y [mV/km]');
    th = title('B driver');
    peo = pe_nonflag(E(Ix,2),Ep_FD_EB(:,2));
    [lh,lo] = legend('Measured',...
        sprintf('FD; PE = %.2f',peo),'Location','SouthWest');
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_Eypredicted_w_B_%s.png',dirfig,dateo));end
    fprintf('PE of Ey using B = %.2f\n',peo);
    
%% Response of Ex to impulse in B
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_FD_EB,H_FD_EB(:,1),'r','LineWidth',2);
    plot(t_FD_EB,H_FD_EB(:,2),'b','LineWidth',2);
    xlabel('\tau [s]');
    ylabel('[mV/km]');
    th = title('E_x response to 1 nT impulse in B_x and B_y at \tau = 0');
    [lh,lo] = legend('FD H_{xx}(\tau) (Response to B_x)','FD H_{xy}(\tau) (Response to B_y)');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_Ex_IRF_to_B_%s.png',dirfig,dateo));end
    
%% Response of Ey to impulse in B
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_FD_EB,H_FD_EB(:,3),'r','LineWidth',2);
    plot(t_FD_EB,H_FD_EB(:,4),'b','LineWidth',2);
    xlabel('\tau [s]');
    ylabel('[mV/km]');
    th = title('E_y response to 1 nT impulse in B_x and B_y at \tau = 0');
    [lh,lo] = legend('FD H_{yx}(\tau) (Response to B_x)','FD H_{yy}(\tau) (Response to B_y)');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_Ey_IRF_to_B_%s.png',dirfig,dateo));end

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tGIC(Ix),GIC(Ix,2));
    plot(tGIC(Ix),GICp_FD_GE(:,2),'k');
    plot(tGIC(Ix),GICp_FD_GB(:,2));
    %plot(tGIC(Ix),GICp3_TD0(:,2));
    %plot(tGIC(Ix),GICp3_TD03(:,2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('GIC [A]');    
    %th = title('B driver');
    peoE = pe_nonflag(GIC(Ix,2),GICp_FD_GE(:,2));
    peoB = pe_nonflag(GIC(Ix,2),GICp_FD_GB(:,2));
    [lh,lo] = legend('Measured',sprintf('Using E: PE = %.2f',peoE),sprintf('Using B: PE = %.2f',peoB),'Location','SouthWest');
    legend boxoff
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_GICpredicted_w_E_and_B_%s',dirfig,dateo));end
    fprintf('PE of GIC using E = %.2f\n',peoE);
    fprintf('PE of GIC using B = %.2f\n',peoB);
    
%% Response of GIC to impulse in B
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aBx(t) + bBy(t).
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_FD_GB,1000*H_FD_GB(:,3),'r','LineWidth',2);
    plot(0,1000*aoB,'r.','MarkerSize',30);
    plot(t_FD_GB,1000*H_FD_GB(:,2),'b','LineWidth',2);
    plot(0,1000*boB,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 nT impulse at \tau = 0');
    [lh,lo] = legend('FD a(\tau)','a_o','FD b(\tau)','b_o');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_IRF_to_B_%s.png',dirfig,dateo));end
    
%% Response of GIC to impulse in E
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aEx(t) + bEy(t).
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_FD_GE,1000*H_FD_GE(:,3),'r','LineWidth',2);
    plot(0,1000*ao/5,'r.','MarkerSize',30);
    plot(t_FD_GE,1000*H_FD_GE(:,2),'b','LineWidth',2);
    plot(0,1000*bo/5,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 mV/km impulse at \tau = 0');
    [lh,lo] = legend('FD a(\tau)','a_o/5','FD b(\tau)','b_o/5');
    set(gca,'XLim',[-20,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_IRF_to_E_%s.png',dirfig,dateo));end
