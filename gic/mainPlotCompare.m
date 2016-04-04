CON20 = load('main_CON20');
UTF19 = load('main_UTN19');

figurex(1);clf;
    plot(CON20.dn,CON20.B(:,1),'b');
    hold on;grid on;    
    plot(UTF19.dn,UTF19.B(:,1)','g');
    datetick('x');
    ylabel('nT')
    legend('CON20 B_x','UTN19 B_x')
