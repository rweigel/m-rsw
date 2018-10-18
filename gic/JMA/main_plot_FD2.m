%dateo = '20060818';
dateo = '20061213';

dirmat = sprintf('mat/%s',dateo);
dirfig = sprintf('figures/%s',dateo);


%fn=fn+1;figure(fn);clf;
for i = 1:intervalno
    load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i));
    Z_FD_EB_All(:,:,i) = Z_FD_EB;
    Z_FD_GE_All(:,:,i) = Z_FD_GE;
    Z_FD_GB_All(:,:,i) = Z_FD_GB;
end
Z_FD_EB_Std = zeros(size(Z_FD_EB(:,:,1)));
Z_FD_GE_Std = zeros(size(Z_FD_GE(:,:,1)));
Z_FD_GB_Std = zeros(size(Z_FD_GB(:,:,1)));
% TODO: Determine variance based on bootstrap instead of 1/sqrt(N), which
% is not correct because spectral estimates are not independent.
N = size(Z_FD_EB_All,3);
for i = 1:4
    Z_FD_EB_Ave(:,i) = mean(squeeze(Z_FD_EB_All(:,i,:)) ,2);
    Z_FD_EB_Std(2:end,i) = std(squeeze( abs(Z_FD_EB_All(2:end,i,:)) ) ,0, 2);

    Z_FD_GE_Ave(:,i) = mean(squeeze(Z_FD_GE_All(:,i,:)) ,2);
    Z_FD_GE_Std(2:end,i) = std(squeeze( abs(Z_FD_GE_All(2:end,i,:)) ) ,0, 2);

    Z_FD_GB_Ave(:,i) = mean(squeeze(Z_FD_GB_All(:,i,:)) ,2);
    Z_FD_GB_Std(2:end,i) = std(squeeze( abs(Z_FD_GB_All(2:end,i,:)) ) ,0, 2);
end
%plot(1./fe_FD_EB(2:end),Z_FD_EB_Ave(2:end,i));
%U = Z_FD_EB_Std(2:end,i)/sqrt(N);
%L = Z_FD_EB_Std(2:end,i)/sqrt(N);
%errorbar(1./fe_FD_EB(2:end),Z_FD_EB_Ave(2:end,i),L,U);

GICp_FD_GB_Ave = Zpredict(fe_FD_GB,Z_FD_GB_Ave,B(:,1:2));
peB = pe(GIC(:,2),GICp_FD_GB_Ave(:,2));
errorB = GIC(:,2)-GICp_FD_GB_Ave(:,2);
[C_FD_GB_Ave,f_C] = mscohere(GIC(:,2),GICp_FD_GB_Ave(:,2),86400,3600*4);

GICp_FD_GE_Ave = Zpredict(fe_FD_GE,Z_FD_GE_Ave,E(:,1:2));
peE = pe(GIC(:,2),GICp_FD_GE_Ave(:,2));
errorE = GIC(:,2)-GICp_FD_GE_Ave(:,2);
[C_FD_GE_Ave,f_C] = mscohere(GIC(:,2),GICp_FD_GE_Ave(:,2));

fn=fn+1;figure(fn);clf;hold on;box on;grid on;
    plot(GIC(:,2),'LineWidth',2)
    plot(GICp_FD_GB_Ave(:,2),'LineWidth',2)
    plot(GICp_FD_GE_Ave(:,2),'LineWidth',2)
    legend('Measured',sprintf('Using B; PE = %.2f',peB),sprintf('Using E; PE = %.2f',peE))

fn=fn+1;figure(fn);clf;hold on;box on;grid on;
    n = length(Ix);
    f = [0:n/2]'/n;
    H_FD_GE_Ave = Z2H(fe_FD_GE,Z_FD_GE_Ave,f);
    H_FD_GE_Ave = fftshift(H_FD_GE_Ave,1);
    H_FD_GB_Ave = Z2H(fe_FD_GB,Z_FD_GB_Ave,f);
    H_FD_GB_Ave = fftshift(H_FD_GB_Ave,1);

    n = (size(H_FD_GE_Ave,1)-1)/2;
    t = [-n:n]';
    plot(t,H_FD_GE_Ave(:,1),'r-','LineWidth',2);
    plot(t,H_FD_GB_Ave(:,1),'r-.','LineWidth',2);
    plot(t,H_FD_GE_Ave(:,2),'g-','LineWidth',2);
    plot(t,H_FD_GB_Ave(:,2),'g-.','LineWidth',2);

    legend('Hxx GIC/E','Hxx GIC/B','Hxy GIC/E','Hxy GIC/B')
    set(gca,'XLim',[-20,60]);

fn=fn+1;figure(fn);clf;hold on;box on;grid on;
for i = 2:2
    Z_FD_GB_Alt(:,1) = Z_FD_EB_Ave(:,1).*Z_FD_GE_Ave(:,1) + Z_FD_EB_Ave(:,3).*Z_FD_GE_Ave(:,2); 
    Z_FD_GB_Alt(:,2) = Z_FD_EB_Ave(:,2).*Z_FD_GE_Ave(:,1) + Z_FD_EB_Ave(:,4).*Z_FD_GE_Ave(:,2); 
    plot(1./fe_FD_EB(2:end),abs(Z_FD_EB_Ave(2:end,i)),'r','LineWidth',2);
    plot(1./fe_FD_GE(2:end),abs(Z_FD_GE_Ave(2:end,i)),'g','LineWidth',2);
    plot(1./fe_FD_GB(2:end),abs(Z_FD_GB_Ave(2:end,i)),'b','LineWidth',2);
    plot(1./fe_FD_GB(2:end),abs(Z_FD_GB_Alt(2:end,i)),'LineWidth',2);
    set(gca, 'XScale', 'log');set(gca, 'YScale', 'log');
end
[lh,lo] = legend('Z_{xy} E/B','Z_{xy} GIC/E','Z_{xy} GIC/B','Z_{xy} GIC/B alt');
figconfig
if png,print('-dpng',sprintf('%s/main_plot_FD_Zxy_aves_%s.png',dirfig,dateo));end

break

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
for i = 1:intervalno
    load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i));
    loglog(fe_FD_GE,abs(Z_FD_GE(:,1)),'r.')
    loglog(fe_FD_GE,abs(Z_FD_GE(:,2)),'g.')
    legend('Z_{xx}','Z_{xy}')
    Z_FD_GE_All(:,:,i) = Z_FD_GE;
end
figconfig
if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_Z_to_E_%s.png',dirfig,dateo));end

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;
for i = 1:intervalno
    load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i));
    loglog(fe_FD_GB,abs(Z_FD_GB(:,1)),'r.')
    loglog(fe_FD_GB,abs(Z_FD_GB(:,2)),'g.')
    legend('Z_{xx}','Z_{xy}')
    Z_FD_GB_All(:,:,i) = Z_FD_GB;
end
figconfig
if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_Z_to_B_%s.png',dirfig,dateo));end

break

fn=fn+1;
figure(fn);clf;hold on;box on;grid on;

for i = 1:intervalno
    load(sprintf('%s/mainCompute1_%s-%d.mat',dirmat,dateo,i));
    load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i));
    %% Response of GIC to impulse in E
    plot(t_FD_GE,1000*H_FD_GE(:,3),'r','LineWidth',2);
    plot(0,1000*ao/5,'r.','MarkerSize',30);
    plot(t_FD_GE,1000*H_FD_GE(:,2),'b','LineWidth',2);
    plot(0,1000*bo/5,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [mA]');
    th = title('GIC response to 1 mV/km impulse at \tau = 0');
    [lh,lo] = legend('FD a(\tau)','a_o/5','FD b(\tau)','b_o/5');
    set(gca,'XLim',[-20,60]);
end
figconfig    
if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_IRF_to_E_%s.png',dirfig,dateo));end

break
fn=fn+1;
figure(fn);clf;hold on;box on;grid on;

for i = 1:intervalno
    load(sprintf('%s/mainCompute1_%s-%d.mat',dirmat,dateo,i));;
    load(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i));;
    %% Response of GIC to impulse in E
    plot(t_FD_GB,H_FD_GB(:,3),'r','LineWidth',2);
    plot(0,aoB,'r.','MarkerSize',30);
    plot(t_FD_GB,H_FD_GB(:,2),'b','LineWidth',2);
    plot(0,bo,'b.','MarkerSize',30);
    xlabel('\tau [s]');
    ylabel('GIC [A]');
    th = title('GIC response to 1 nT impulse at \tau = 0');
    [lh,lo] = legend('FD a(\tau)','a_o','FD b(\tau)','b_o');
    set(gca,'XLim',[-20,60]);
end
figconfig    
if png,print('-dpng',sprintf('%s/main_plot_FD_GIC_IRF_to_B_%s.png',dirfig,dateo));end
