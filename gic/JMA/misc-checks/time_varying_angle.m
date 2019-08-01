% Assume E varies as cos(2*pi*t/T) and Ex and Ey are in phase
% (in phase supported by data).
% Assume angle of E varies linearly.

% All angles with respect to East with 90 degrees = North.

r2d = (180/pi); % Radians to degrees
N = 86400;
t = [0:N-1]';

% Adjustable parameters
T = 60*60*3;
a = 1;
b = 1;

alpha = 2*pi*t/t(end); % linear variation between 0 and 2*pi over range of t

Ex = cos(2*pi*t/T).*cos(alpha);
Ey = cos(2*pi*t/T).*sin(alpha);

Ex = Ex - mean(Ex);
Ey = Ey - mean(Ey);

ftEx = fft(Ex);
ftEy = fft(Ey);

ftGIC = a*ftEx + b*ftEy;

GIC = ifft(ftGIC);

[maxGIC,Imax] = max(GIC);
[minGIC,Imin] = min(GIC);
[minGICa,Imina] = min(abs(GIC)); % GIC nearest zero.

fh = figure(1);clf;
set(fh,'DefaultTextInterpreter','latex');
set(fh,'DefaultLegendInterpreter','latex');
set(fh,'DefaultAxesTickLabelInterpreter','latex');

subplot(3,1,1);
    plot(t,r2d*alpha,'k');
    grid on;hold on;
    plot(Imax,r2d*alpha(Imax),'r.','MarkerSize',20);
    plot(Imin,r2d*alpha(Imin),'b.','MarkerSize',20);    
    plot(Imina,r2d*alpha(Imina),'k.','MarkerSize',20);        
    legend('Angle of $\mathbf{E}$',...
           'Angle at max GIC',...
           'Angle at min GIC',...
           'Angle at min abs(GIC)',...
           'Location','NorthWest');
    title(sprintf('a = %d, b = %d $\\Rightarrow$ Angle of line = %d$^{\\circ}$',...
                    a,b,round(r2d*atan2(b,a))));
    set(gca,'YTick',[0:45:360]);
subplot(3,1,2)
    plot(t,Ex,'r');
    hold on;grid on;
    plot(t,Ey,'b');
%    plot(Imax,Ex(Imax),'r.','MarkerSize',20);
%    plot(Imin,Ex(Imin),'b.','MarkerSize',20);        
%    plot(Imax,Ex(Imax),'ro','MarkerSize',1);
%    plot(Imin,Ex(Imin),'bo','MarkerSize',1);        
    legend('$E_x$','$E_y$');
subplot(3,1,3)
    plot(t,GIC,'k');
    hold on;grid on;
    plot(Imax,maxGIC,'r.','MarkerSize',20);
    plot(Imin,minGIC,'b.','MarkerSize',20);
    plot(Imina,minGICa,'k.','MarkerSize',20);         
    legend('$GIC$','max GIC','min GIC','min abs(GIC)');
    

print -dpdf time_varying_angle.pdf

