% Compute and plot transfer function, phase, and impulse response
% for various profiles.

clear;

base = 'zplanewave_demo1'; % Output files will be named ./figures/base_...
mu_0 = 4*pi*1e-7; % Vacuum permeability

for profile = 1:5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ne = 4;
no = 1; 
N = no*10^ne; 
f = [1:N/2]/N;

if (profile == 1)
    h = [];
    s = 1;
    titlestr = sprintf('$\\mbox{Infinite half space}\\quad\\rho = %.1f \\mbox{ [Ohm}\\cdot\\mbox{m]}',1/s);
end
if (profile == 2)
    s = [1/1000,1/10,1/100,1/5];
    h = 1e3*[10,20,400];
    titlestr = sprintf('$\\rho = [%.1f,%.1f,%.1f,%.1f] \\mbox{ [Ohm}\\cdot\\mbox{m]}\\quad t = [%.1f,%.1f,%.1f,\\infty] \\mbox{[km]}',[1./s,h/1e3]);
end
if (profile == 3)
    s = [1/10,1/100,1/1000];
    h = 1e3*[1,10];
    titlestr = sprintf('$\\rho = [%.1f,%.1f,%.1f] \\mbox{ [Ohm}\\cdot\\mbox{m]}\\quad t = [%.1f,%.1f,\\infty] \\mbox{[km]}',[1./s,h/1e3]);
end
if (profile == 4)
    s = [10,0.1,10,0.1];
    h = 1e3*[10,10,10];
    titlestr = sprintf('$\\rho = [%.1f,%.1f,%.1f,%.1f] \\mbox{ [Ohm}\\cdot\\mbox{m]}\\quad t = [%.1f,%.1f,%.1f,\\infty] \\mbox{[km]}',[1./s,h/1e3]);
end
if (profile == 5)
    s = [0.1,10,0.1,10];
    h = 1e3*[10,10,10];
    titlestr = sprintf('$\\rho = [%.1f,%.1f,%.1f,%.1f] \\mbox{ [Ohm}\\cdot\\mbox{m]}\\quad t = [%.1f,%.1f,%.1f,\\infty] \\mbox{[km]}',[1./s,h/1e3]);
end

titlestr = [titlestr,sprintf('\\quad \\Delta f =1/(%d\\cdot 10^%d)$',no,ne)];

C    = zplanewave(s,h,f);   % = (1/(2*pi*f*j))*(Ex(f)/By(f)) = Ex(f)/B'y(f)
Cmag = sqrt(C.*conj(C));
Z    = j*2*pi*f.*C;         % Ex(f)/By(f)
Zmag = sqrt(Z.*conj(Z));

% Full array - zplanewave only returns f > 0.
Zf  = [0,Z,fliplr(conj(Z))]; 

% Full array for Ex(f)/B'y(f), B'y = dBy/dt
dZf = [0,C,fliplr(conj(C))];

% Apparent resistivity.  For infinite half-space will equal actual.
rho_a = C.*conj(C)*mu_0*2*pi.*f;
phi_C = (180/pi)*atan2(imag(C),real(C));

% Ex ~ exp(j*2*pi*f*t + phi) if By ~ exp(j*2*pi*f*t).
phi_Z = (180/pi)*atan2(imag(Z),real(Z));

figure(1);clf;
    loglog(f,rho_a,'b','LineWidth',3,'Marker','.','MarkerSize',10);
    hold on;
    loglog(f,Cmag,'g','LineWidth',3,'Marker','.','MarkerSize',10);
    loglog(f,Zmag,'k','LineWidth',3,'Marker','.','MarkerSize',10);
    th = title(titlestr); 
    set(th,'Interpreter','Latex');    
    grid on;
    %xlabel('Period [s]');
    xlabel('f\cdot\Deltat');
    
    lh = legend(' $\rho_a = \omega\mu_0\|\widetilde{C}\|^2\quad\mbox{[Ohm}\cdot\mbox{m]}$',...
                ' $\|\widetilde{C}\|=\|\widetilde{E}_x/\widetilde{B}''_y\| = \quad\mbox{[m/s]}$',...
                ' $\widetilde{Z}=\|\widetilde{E}_x/\widetilde{B}_y\| = \omega\|\widetilde{C}\|\quad\mbox{[m/s]}$'...
            );
    set(lh,'Interpreter','Latex');
    print('-dpng','-r150',sprintf('figures/%s_transferfn_profile_%d.png',base,profile));
    print('-depsc',sprintf('figures/%s_transferfn_profile_%d.eps',base,profile));
    fprintf('Wrote figures/%s_transferfn_profile_%d.{png,eps}\n',base,profile);
    
figure(2);clf;
    semilogx(f,phi_C,'g','LineWidth',3,'Marker','.','MarkerSize',10);
    hold on;
    semilogx(f,phi_Z,'k','LineWidth',3,'Marker','.','MarkerSize',10);
    grid on;
    set(gca,'YLim',[-90 90]);
    th = title(titlestr);
    set(th,'Interpreter','Latex');  
    %xlabel('Period [s]');
    %xlabel('Frequency [Hz]');
    xlabel('f\cdot\Deltat');
    lh = legend(' $\phi_{\widetilde{C}}\quad\mbox{[deg]}$',...
                ' $\phi_{\widetilde{Z}}\quad\mbox{[deg]}$',...
                'Location','NorthWest');
    set(lh,'Interpreter','Latex');
    print('-dpng',sprintf('figures/%s_phase_profile_%d.eps',base,profile));
    fprintf('Wrote figures/%s_phase_profile_%d.{png,eps}\n',base,profile)

if (isempty(h))
    s = [s,s,s];
    h = 1e3*[1,100];
end
figure(3);clf;
    d = cumsum(h);
    %d = [10^(round(log10(d(1)))-1),d,10^(round(log10(d(end)))+1)];
    d = [10^(2),d,10^6];
    s(end+1) = s(end);
    for i = 1:length(s)-1
        loglog([1/s(i),1/s(i)],[d(i),d(i+1)]/1e3,'LineWidth',5);
        hold on;
        loglog([1/s(i),1/s(i+1)],[d(i+1),d(i+1)]/1e3,'LineWidth',1);
    end
    grid on;
    % Add some space to left and right.
    xl = get(gca,'XLim');
    %set(gca,'XLim',[xl(1)*0.7,xl(2)*1.1]);
    set(gca,'XLim',[1e-1*0.7,1e3*1.1]);
    th = title(titlestr);
    set(th,'Interpreter','Latex');  

    set(gca,'YDir','reverse');
    %set(gca,'XAxisLocation','Top');
    xlabel('Resistivity [\Omega\cdotm]');
    ylabel('Depth [km]');
    print('-dpng','-r150',sprintf('figures/%s_geometry_profile_%d.png',base,profile));
    print('-depsc',sprintf('figures/%s_geometry_profile_%d.eps',base,profile));
    fprintf('Wrote figures/%s_geometry_profile_%d.{png,eps}\n',base,profile)

tft  = [-N/2:1:N/2];
dhft = fftshift(ifft(dZf));
hft  = fftshift(ifft(Zf));

figure(4);clf;
    plot(tft,hft,'k','LineWidth',2);
    hold on;grid on;
    plot(tft,dhft,'g','LineWidth',2);
    %plot(dhft(N/2+2)./sqrt([1:60]),'b','LineWidth',2);
    set(gca,'XLim',[-30,60])
    th = title(titlestr);
    set(th,'Interpreter','Latex');      
    xlabel('t/\Deltat');
    lh = legend('$E_x(t)\mbox{ for }B_y(t) = \delta(t)$',...
                '$E_x(t)\mbox{ for }B''_y(t) = \delta(t)$');
    set(lh,'Interpreter','Latex');
    print('-dpng','-r150',sprintf('figures/%s_IRF_profile_%d.png',base,profile));
    print('-depsc',sprintf('figures/%s_IRF_profile_%d.eps',base,profile));
    fprintf('Wrote figures/%s_IRF_profile_%d.{png,eps}\n',base,profile)
    
end % profile
