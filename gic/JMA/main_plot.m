%% Setup
% Save images (requires each figure to open in new window for proper figure
% sizing; see figconfig.m)
addpath('../../stats'); % For PE calculation (PE_NONFLAG).

%% Load output of main.mat
load(sprintf('%s/mainCompute1_%s.mat',dirmat,dateo)); % Load output of main.m
load(sprintf('%s/mainCompute2_%s.mat',dirmat,dateo)); % Load output of main.m


if (0)
    %% Histograms of a_o and b_o values 
    % Computed using 3600 values to compute instead of using all data.
    fn=fn+1;
    figure(fn);
        hist(1000*aoboot)
        xlabel('a_o [A km/V]');
        ylabel('# in bin');
        th = title(sprintf('a_o = %0.2f +/- %.2f [A km/V]',1000*ao,1000*aobootstd));
        figconfig
        if png,print('-dpng',sprintf('%s/main_plot_ao_hist_%s.png',dirfig,dateo));end

    fn=fn+1;
    figure(fn);
        hist(1000*boboot)
        xlabel('b_o [A km/V]');
        ylabel('# in bin');
        th = title(sprintf('b_o = %0.2f +/- %.2f [A km/V]',1000*bo,1000*bobootstd));
        figconfig
        if png,print('-dpng',sprintf('%s/main_plot_bo_hist_%s.png',dirfig,dateo));end

    %% Effect of time shift on a_o and b_o
    fn=fn+1;
    figure(fn);clf;hold on;box on;grid on;
        plot(tl,aolag,'LineWidth',2);
        plot(tl,bolag,'LineWidth',2);
        plot(tl,(1-arvlag)/10,'LineWidth',2);
        xlabel('Lag');
        ylabel('[A km/mV]');
        [lh,lo] = legend('a_o','b_o','pe/10');
        figconfig
        if png,print('-dpng',sprintf('%s/main_plot_ao_bo_pe_vs_lag_%s.png',dirfig,dateo));end
end

%% Prediction of Ex using B as driver
% Using Time Domain (TD) and Frequency Domain (FD) method.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tE(Ix),E(Ix,1));
    plot(tE(Ix),Ep_TD(:,1));
    plot(tE(Ix),Ep_FD(:,1));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('E_x [mV/km]');
    th = title('B driver');
    [lh,lo] = legend('Measured',...
        sprintf('TD; PE = %.2f',pe_nonflag(E(Ix,1),Ep_TD(:,1))),...
        sprintf('FD; PE = %.2f',pe_nonflag(E(Ix,1),Ep_FD(:,1))),...
        'Location','SouthWest');
    %[lh,lo] = legend('Measured','TD','FD','Location','NorthWest');
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Expredicted_w_B_%s.png',dirfig,dateo));end

%% Prediction of Ey using B as driver
% Time domain method uses 60*5 causal and 60*5 acausal lag values.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tE(Ix),E(Ix,2));
    plot(tE(Ix),Ep_TD(:,2));
    plot(tE(Ix),Ep_FD(:,2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('E_y [mV/km]');
    th = title('B driver');
    [lh,lo] = legend('Measured',...
        sprintf('TD; PE = %.2f',pe_nonflag(E(Ix,2),Ep_TD(:,2))),...
        sprintf('FD; PE = %.2f',pe_nonflag(E(Ix,2),Ep_FD(:,2))),...
        'Location','SouthWest');
    %[lh,lo] = legend('Measured','TD','FD','Location','SouthWest');
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Eypredicted_w_B_%s.png',dirfig,dateo));end

%% Response of Ex to impulse in By
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_TD,H_TD(:,2),'LineWidth',2);
    plot(t_FD,H_FD(:,2),'LineWidth',2);
    xlabel('\tau [s]');
    ylabel('E_x [mV/km]');
    th = title('E_x response to 1 nT impulse in B_y at \tau = 0');
    [lh,lo] = legend('TD H_{xy}(\tau)','FD H_{xy}(\tau)');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Ex_IRF_to_By_%s.png',dirfig,dateo));end
    
%% Response of Ey to impulse in Bx
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t_TD,H_TD(:,3),'LineWidth',2);
    plot(t_FD,H_FD(:,3),'LineWidth',2);
    xlabel('\tau [s]');
    ylabel('E_y [mV/km]');
    th = title('E_y response to 1 nT impulse in B_x at \tau = 0');
    [lh,lo] = legend('TD H_{yx}(\tau)','FD H_{yx}(\tau)');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_Ey_IRF_to_Bx_%s.png',dirfig,dateo));end

%% Prediction of GIC using B as driver
% Time domain method uses 60*5 causal and 60*5 acausal lag values.
% Prediction is for GIC LPF @ 1 Hz.  Very similar results for raw data. The
% _Const_ lines correspond to the models
%
% $$ GIC(t) = aoBx(t) + boBy(t) $$
%
% and
%
% $$ GIC(t) = aoBx(t) + boBy(t) + coBz(t) $$
%
% where the constants are determined using ordinary least squares
% regression.  It is curious that addition of the Bz compontent to the
% model improves the predictions significantly.  It is also unexpected that
% predictions of GIC given *B* are so much better than predictions of GIC
% given *E* (next figure) because *E* is more directly related to GIC.
% That is, in terms of transfer fucntions, and $\omega$ = angular
% frequency,
%
% $$GIC(\omega) = Z_{GE}(\omega)E(\omega)$$
%
% and 
%
% $$ E(\omega) = Z_{EB}(\omega)B(\omega) $$
%
% so
%
% $$GIC(\omega) = Z_{GE}(\omega)Z_{EB}(\omega)B(\omega)$$
%
% Node that the PE for the FD method is poor.  It could be improved if
% dB/dt was used as an input instead of B.  The FD method is better for the
% next plot because E has less power at long periods (as would dB/dt).
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tGIC(Ix),GIC(Ix,2));
    plot(tGIC(Ix),GICp3_TD(:,2));
    plot(tGIC(Ix),GICp3_FD(:,2));
    plot(tGIC(Ix),GICp3_TD0(:,2));
    plot(tGIC(Ix),GICp3_TD03(:,2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('GIC [A]');    
    th = title('B driver');
    [lh,lo] = legend('Measured',...
        sprintf('TD; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp3_TD(:,2))),...
        sprintf('FD; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp3_FD(:,2))),...
        sprintf('Const x,y input; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp3_TD0(:,2))),...
        sprintf('Const x,y,z input; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp3_TD03(:,2))),...
        'Location','SouthWest');
    legend boxoff
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GICpredicted_w_B_%s.png',dirfig,dateo));end

%% Response of GIC to impulse in Bx
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aBx(t) + bBy(t).
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t3_TD,H3_TD(:,1),'LineWidth',2);
    plot(t3_FD,H3_FD(:,4),'LineWidth',2);
    plot(0,aoB,'r.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [A]');
    th = title('GIC response to 1 nT impulse in B_x at \tau = 0');
    [lh,lo] = legend('TD a(\tau)','FD a(\tau)','a_o');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GIC_IRF_to_B_x_%s.png',dirfig,dateo));end

%% Response of GIC to impulse in By
% The red dot for b is the value computed using ordinary linear least
% squares regression on GIC(t) = aBx(t) + bBy(t).
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t3_TD,H3_TD(:,2),'LineWidth',2);
    plot(t3_FD,H3_FD(:,2),'LineWidth',2);
    plot(0,boB,'r.','MarkerSize',30);
    xlabel('Time [s] since nT impulse in B_y');
    ylabel('GIC [A]');
    th = title('GIC response to 1 nT impulse in B_y at \tau = 0');
    [lh,lo] = legend('TD','FD','bo');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GIC_IRF_to_By_%s.png',dirfig,dateo));end
    
%% Prediction of GIC using E as driver
% Time domain method uses 60*5 causal and 60*5 acausal lag values.
% Prediction is for GIC LPF @ 1 Hz.  Very similar results for raw data.
% The "Const" line correspond to the model
% GIC(t) = a*Ex(t) + b*Ey(t)
% where a and b were determined by ordinary least squares regression.  Note
% that the computed values of a and b were a = 0.45 and b = -0.63.  The
% negative sign on b is unexpected given that when the model
% GIC(w) = A(w)*Ex(w) + B(w)*Ey(w) is used, the impulse response
% associated with A(w) and B(w) are generally positive.  The impulse
% responses are shown later.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(tGIC(Ix),GIC(Ix,2));
    plot(tGIC(Ix),GICp2_TD(:,2));
    plot(tGIC(Ix),GICp2_FD(:,2));
    plot(tGIC(Ix),GICp2_TD0(:,2));
    xlabel(sprintf('Days since %s',dateo));
    ylabel('GIC [A]');
    th = title('E driver');
    [lh,lo] = legend('Measured',...
        sprintf('TD; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp2_TD(:,2))),...
        sprintf('FD; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp2_FD(:,2))),...
        sprintf('Const; PE = %.2f',pe_nonflag(GIC(Ix,2),GICp2_TD0(:,2))),...
        'Location','SouthWest');
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GICpredicted_w_E_%s.png',dirfig,dateo));end


%% Response of GIC to impulse in Ex
% The red dot for a is the value computed using ordinary linear least
% squares regression on GIC(t) = aEx(t) + bEy(t).
% The value plotted is _a_/5 so the features of the IRFs are easier to see.
% The sign of _a_ is positive and consistent with the IRF, and the
% magnitude of _a_ relative to the peak of the IRF can be expained by the
% fact that _a_ represents an integral of the IRF.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t2_TD,1000*H2_TD(:,1),'LineWidth',2);
    plot(t2_FD,1000*H2_FD(:,3),'LineWidth',2);
    plot(0,1000*ao/5,'r.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 mV/km impulse in E_x at \tau = 0');
    [lh,lo] = legend('TD a(\tau)','FD a(\tau)','a_o/5');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GIC_IRF_to_Ex_%s.png',dirfig,dateo));end

%% Response of GIC to impulse in Ey
% The red dot for b is the value computed using ordinary linear least
% squares regression on GIC(t) = aEx(t) + bEy(t).
% _b_/2 is shown so the features of the IRFs are easier to see.
% Note that this IRF has the feature that it overshoots the zero line.
% This feature cannot be produced by (first-order) LR or RC circuit model
% alone.  This is a second-order effect.  Also note that the sign of _b_ is
% not consistent with the sign of the peak of the IRF.
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
    plot(t2_TD,1000*H2_TD(:,2),'LineWidth',2);
    plot(t2_FD,1000*H2_FD(:,2),'LineWidth',2);
    plot(0,1000*boB/3,'r.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 mV/km impulse in E_y at \tau = 0');
    [lh,lo] = legend('TD b(\tau)','FD b(\tau)','b_o/3');
    set(gca,'XLim',[-60,60]);
    figconfig
    if png,print('-dpng',sprintf('%s/main_plot_GIC_IRF_to_Ey_%s.png',dirfig,dateo));end

if (0) % For Pierre's IAGA presentation
    fn=fn+1;
    figure(fn);clf;hold on;box on;grid on;
        plot(tGIC(Ix),GIC(Ix,2),'LineWidth',2);
        plot(tGIC(Ix),GICp3_TD(:,2),'LineWidth',2);
        xlabel(sprintf('Days since %s',dateo));
        ylabel('GIC [A]');    
        [lh,oh] = legend('Measured','Predicted using B','Location','SouthWest');
        th = title('Magnetic Field and GIC Measurements in Memambetsu Japan');
        legend boxoff
        set(0,'DefaultAxesFontSize',16);
        set(th,'FontSize',14)
        set(lh,'fontsize',16);
        set(oh,'linewidth',2);
        if png,print('-dpng','%s/main_plot_GICpredicted_w_B_Pierre');end
    fn=fn+1;
    figure(fn);clf;hold on;box on;grid on;
        plot(tGIC(Ix),GIC(Ix,2),'LineWidth',2);
        plot(tGIC(Ix),GICp2_FD(:,2),'LineWidth',2);
        xlabel(sprintf('Days since %s',dateo));
        ylabel('GIC [A]');
        [lh,oh] = legend('Measured','Predicted using E','Location','SouthWest');
        th = title('Electric Field and GIC Measurements in Memambetsu Japan');
        legend boxoff
        set(0,'DefaultAxesFontSize',16);
        set(th,'FontSize',14)
        set(lh,'fontsize',16);
        set(oh,'linewidth',2);
        if png,print('-dpng','%s/main_plot_GICpredicted_w_E_Pierre');end
end
