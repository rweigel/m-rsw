
clear;
load('mat/main_options-1-v1-o0.mat','GE_avg');

a = GE_avg.Mean.Z(:,3);
b = GE_avg.Mean.Z(:,4);
fe = GE_avg.Mean.fe;

ang = linspace(0,2*pi,1000);
sf = 180/pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% G = a*E_north + b*E_east 
%
% Let east correspond to cartesian x-dir, north correspond to y-dir, then
%
%   E_east = Eo*cos(ang)
%   E_north = Eo*sin(ang)
%
% Substitution using Eo = 1 gives
%
% G = a*sin(ang) + b*cos(ang)
%
% Check that we get 45 degrees west of north (135 degrees)
% when ao = 72, bo = -72.
ao = 72;
bo = -72;
for i = 1:length(ang)
    G(i) = ao*sin(ang(i)) - bo*cos(ang(i));
end
[~,I] = max(G);
fprintf('Angle of E for max GIC when ao = 72, bo = -72: %.0f degrees\n',sf*ang(I));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultLegendInterpreter','latex')
set(0,'DefaultAxesTickLabelInterpreter','latex');

% In the following, Ex and Ey are both assumed to have the same phase (=0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);clf;

% Compute angle numerically
% TODO: Figure out analytic formula
ang_max = [0,0];
phase_max = [0,0];
for j = 2:length(a)
    for i = 1:length(ang)
        G(i) = a(j)*sin(ang(i)) + b(j)*cos(ang(i));
    end
    plot(sf*ang,abs(G));hold on;
    xlabel('Angle $0^{\circ}$ = east; $90^{\circ}$ = north');
    ylabel('$|GIC|$');
    title('$|GIC|$ at all evaluation periods',...
          'FontWeight','normal');
    [~,I] = max(abs(G)); % Note that abs(G) is used.
    [~,I] = findpeaks(abs(G));
    ang_max(j,:) = ang(I);
    phase_max(j,:) = atan2(imag(G(I)),real(G(I)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
subplot(2,1,1)
    semilogx(1./fe,sf*ang_max,'*');
    title(['Angles of $\mathbf{E}(\omega)$ for max $|GIC(\omega)|$; '...
           '0$^{\circ}$ = East, 90$^{\circ}$ = North'],...
           'FontWeight','normal');
    ylabel('[degrees]');
    grid on;
    set(gca,'YTick',[0:45:360]);
subplot(2,1,2)
    semilogx(1./fe,sf*phase_max,'*');
    title('Phases of max $|GIC(\omega)|$ relative to $E_x$ and $E_y$ (both at 0$^{\circ}$)',...
          'FontWeight','normal');
    ylabel('[degrees]');
    xlabel('Period [s]');
    grid on;
    set(gca,'YTick',[-180:45:180]);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

orient tall
print -dpdf angles.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3);clf;
clear G
ang  = linspace(0,2*pi,100);
ang2 = linspace(0,2*pi,100);
ang_max = [0,0];
phase_max = [0,0];
for j = 2:length(a)
    for k = 1:length(ang2)
        for i = 1:length(ang)
            G(i,k) = a(j)*sin(ang(i)) + exp(sqrt(-1)*ang2(k))*b(j)*cos(ang(i));
        end
        [~,I] = findpeaks(abs(G(:,k)));
        ang_max(j,k,1:2) = ang(I);
        phase_max(j,k,1:2) = atan2(imag(G(I,k)),real(G(I,k)));
    end
    
    if j == 10
        colormap('parula');
        subplot(2,1,1)
            imagesc(sf*ang,sf*ang2,abs(G));
            title(sprintf('T = %.1f [s]',1./fe(j)));
            cb = colorbar;
            set(get(cb,'Title'),'String','|GIC|');
            ylabel('Field angle');
            xlabel('Phase of $E_y$');
            set(gca,'XTick',0:45:360);
            set(gca,'YTick',0:45:360);
        subplot(2,1,2)
            imagesc(sf*ang,sf*ang2,sf*atan2(imag(G),real(G)));
            cb = colorbar;
            set(get(cb,'Title'),'String','\angle GIC');
            ylabel('Field angle');
            xlabel('Phase of $E_y$');
            set(gca,'XTick',0:45:360);
            set(gca,'YTick',0:45:360);
            orient tall
            print -dpdf angles2.pdf
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
