% Transfer function of 1/f^\alpha noise.
% From Kasdin, 1995, Discrete Simulation of Colored Noise and Stochastic
% Processes and 1/f^\alpha Power Law Noise Generation.
% http://dx.doi.org/10.1109/5.381848
%
% See also http://www.mathworks.com/help/dsp/ref/dsp.colorednoise-class.html

clear;

Nk = 2000;
n  = 1;
d  = 2;
alpha = n/d;
h(1) = 1;
for k = 2:Nk
    h(k) = (alpha/2 + k - 1)*h(k-1)/k;
end

N  = length(h);
yf = fft(h);
I  = sqrt(yf.*conj(yf));
I  = I/I(2);
p  = (180/pi)*atan2(imag(yf),real(yf));
f  = [1:N/2]/N;

dt = 0.1; % Result seems to be independent of dt?
t  = dt*[1:Nk];
y  = [1./t.^alpha];

N2 = length(y);
yf = fft(y);
I2 = sqrt(yf.*conj(yf));
I2 = I2/I2(2);
p2 = (180/pi)*atan2(imag(yf),real(yf));
f2 = [1:N2/2]/N2;

% http://www.dsprelated.com/showarticle/40.php
% Note alpha in ref equals -alpha here.
phi = 180*(alpha-1)/2;

figure(1);clf;
    % Plot 1/f^alpha line
    loglog([f(1),f(end)],[1/f(1)^alpha,1/f(end)^alpha]*f(1)^alpha,'k','LineWidth',3);
    hold on;
    loglog(f,I(2:N/2+1),'b-.','LineWidth',3);
    loglog(f2,I2(2:N2/2+1),'g-.','LineWidth',3);
    xlabel('f')
    set(gca,'XLim',[1e-4 1])
    set(gca,'YLim',[1e-2 2])    
    grid on;hold on;
    title('Raw Periodogram');
    legend(sprintf('1/f^{%d/%d}',n,d),'Simulation 1','Simulation 2')
    print('-dpng','-r600',sprintf('figures/transfer_function_demo2_magnitude.png'));
    print('-depsc',sprintf('figures/transfer_function_demo2_magnitude.eps'));
    fprintf('Wrote figures/transfer_function_demo2_magnitude.{png,eps}\n');

figure(2);clf;
    plot([f(1),f(end)],[phi,phi],'k','LineWidth',3);
    grid on;hold on;
    plot(f,p(2:N/2+1),'b-.','LineWidth',3);
    plot(f2,p2(2:N/2+1),'g-.','LineWidth',3);
    xlabel('f')
    set(gca,'YLim',[-90 0])
    title('Raw Phase');
    legend(sprintf('1/f^{%d/%d}',n,d),'Simulation 1','Simulation 2','Location','SouthEast')
    print('-dpng','-r600',sprintf('figures/transfer_function_demo2_phase.png'));
    print('-depsc',sprintf('figures/transfer_function_demo2_phase.eps'));
    fprintf('Wrote figures/transfer_function_demo2_phase.{png,eps}\n');