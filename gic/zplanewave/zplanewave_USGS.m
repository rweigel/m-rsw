clear;

rho_h = load('../USGSModels/CP1_GroundModel.txt')

s = 1./rho_h(:,1)';
s(end+1) = s(end);
h = rho_h(:,2)';

mu_0 = 4*pi*1e-7; % Vacuum permeability

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparison with Figure 2.4(c) of Simpson and Baer
fprintf('\n');

T = logspace(-3,3,30);
f = 1./T;

%s = [1/1000,1/10,1/100,1/5]';
%h = 1e3*[10,20,400];

C    = zplanewave(s,h,f);
Z    = j*2*pi*f.*C;
Zmag = sqrt(Z.*conj(Z));

rho_a = C.*conj(C)*mu_0*2*pi.*f;
phi_C = (180/pi)*atan2(imag(C),real(C));
phi_Z = (180/pi)*atan2(imag(Z),real(Z));

figure(1);clf;
    loglog(1./f,Zmag,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    loglog(1./f,rho_a,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    xlabel('Period [s]');
    lh = legend(' $\|\widetilde{Z}\| = \|\widetilde{E_x}/\widetilde{B_y}\| = \omega\cdot\|\widetilde{C}\|\quad\mbox{[m/s]}$',' $\rho_a = \|\widetilde{C}\|^2\cdot\omega\mu_0\quad\mbox{[Ohm}\cdot\mbox{m]}$');
    set(lh,'Interpreter','Latex');
    fname = './figures/zplanewave_test_rho_a';
    print('-dpng','-r150',[fname,'.png']);
    print('-depsc',[fname,'.eps']);
    fprintf('Wrote %s.{png,eps}\n',fname);
    
figure(2);clf;
    semilogx(1./f,phi_Z,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    semilogx(1./f,phi_C,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    set(gca,'YLim',[-90 180]);
    xlabel('Period [s]');
    lh = legend(' $\phi_{\widetilde{Z}}\quad\mbox{[deg]}$',...
                ' $\phi_{\widetilde{C}}\quad\mbox{[deg]}$',...
                'Location','NorthWest');
    set(lh,'Interpreter','Latex');
    fname = './figures/zplanewave_test_phi_a';
    print('-dpng','-r150',[fname,'.png']);
    print('-depsc',[fname,'.eps']);
    fprintf('Wrote %s.{png,eps}\n',fname);

figure(3);clf;
    d = cumsum(h);
    d = [10^(round(log10(d(1)))-1),d,10^(round(log10(d(end)))+1)];
    s(end+1) = s(end);
    for i = 1:length(s)-1
        loglog([1/s(i),1/s(i)],[d(i),d(i+1)]/1e3,'LineWidth',5);
        hold on;
        loglog([1/s(i),1/s(i+1)],[d(i+1),d(i+1)]/1e3,'LineWidth',1);
    end
    grid on;
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','Top');
    xlabel('Resistivity [\Omega\cdotm]');
    ylabel('Depth [km]');
    axis([.7 10^4 1 10^4]);
    fname = './figures/zplanewave_test_geometry';
    print('-dpng','-r150',[fname,'.png']);
    print('-depsc',[fname,'.eps']);
    fprintf('Wrote %s.{png,eps}\n',fname);

    if (0)
        for i = 1:length(hf)-1
            loglog([hf(i),hf(i+1)]/1e3,[1/s(i),1/s(i)],'LineWidth',5);
            %loglog([hf(i),hf(i+1)],'LineWidth',3);
            hold on;
        end
        grid on;
        xlabel('Depth [km]');
        ylabel('Resistivity [\Omega\cdotm]');
    end
diary off