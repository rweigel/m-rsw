if ~exist('Z_TD','var')
    load('main.mat');
end

figure(5);clf;hold on;
    plot(t_TD,H_TD);
    plot(t_FD,H_FD);
    grid on;
    break
    
figure(1);clf;hold on;
    plot(tB,B);
    ylabel('[nT]')
    xlabel('Days since 2012-12-13');
    legend('B_x','B_y','B_z');
    grid on;
    
figure(2);clf;hold on;
    plot(tE,E);
    xlabel('Days since 2012-12-13');
    ylabel('[mV/km]')
    legend('E_x','E_y');
    %legend('E_x @ 1 Hz','E_y @ 1 Hz','E_x @ 10 Hz','E_y @ 10 Hz');
    grid on;
    
figure(3);clf;hold on;
    plot(tGIC,GIC(:,1));
    plot(tGIC,GIC(:,2));
    set(gca,'XLim',[0 3])
    legend('GIC @ 1 Hz','GIC @ 1 Hz; LPF @ 1 Hz');
    xlabel('Days since 2006-12-13');
    ylabel('[A]');
    grid on;
    
figure(4);clf;hold on;
    plot(tE,E(:,1));
    plot(tE,Ep_TD(:,1));
    plot(tE,Ep_FD(:,1));
    xlabel('Days since 2012-12-13');
    ylabel('[mV/km]');
    legend('E_x measured','E_x TD predicted','E_x FD predicted');
    grid on;
    