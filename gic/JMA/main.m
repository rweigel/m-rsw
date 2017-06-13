clear

[tGIC,GIC] = prepGIC();
[tE,E,tB,B] = prepEB('second');
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Nonsensical data

figure(1);clf
    plot(tB,B);
    hold on;
    %plot(tBd,Bd);
    ylabel('[nT]')
    xlabel('Days since 2012-12-13');
    legend('B_x','B_y','B_z');
    %legend('B_x @ 1 Hz','B_y @ 1 Hz','B_z @ 1 Hz','B_x @ 10 Hz','B_y @ 10 Hz','B_z @ 10 Hz');
    grid on;
    
figure(2);clf
    plot(tE,E);
    hold on;
    %plot(tEd,Ed);
    xlabel('Days since 2012-12-13');
    ylabel('[mV/km]')
    legend('E_x','E_y');
    %legend('E_x @ 1 Hz','E_y @ 1 Hz','E_x @ 10 Hz','E_y @ 10 Hz');
    grid on;
    
figure(3);clf
    plot(tGIC,GIC(:,1));
    hold on;
    plot(tGIC,GIC(:,2));
    set(gca,'XLim',[0 3])
    legend('GIC @ 1 Hz','GIC @ 1 Hz; LPF @ 1 Hz');
    xlabel('Days since 2006-12-13');
    ylabel('[A]');
    grid on;