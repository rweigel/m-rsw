clear
E = randn(86400,1);
t = [0:86400-1]';
T = 2e4
E = sin(2*pi*t/T);
N = size(E,1);

fo  = [0:N/2]'/N;
f   = [fo;-flipud(fo(2:end-1))];
Ef  = filterE(E);
pE  = abs(fft(E));
pEf = abs(fft(Ef));

figure(1);clf
plot(f,2*abs(pE)/N,'b-');hold on;
plot(f,2*abs(pEf)/N,'r-');grid on;

figure(2);clf
plot(E(1:2*T));hold on;grid on;
plot(Ef(1:2*T));

