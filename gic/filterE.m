function [Ef,f] = filterE(E,Tl,Th)

N = size(E,1);

ftX = fft(E);
pX  = abs(ftX);
fo  = [0:N/2]'/N;
f   = [fo;-flipud(fo(2:end-1))];
I   = find(1./abs(f) > Th | 1./abs(f) < Tl);

ftXf = ftX;
ftXf(I,:) = 0;
Ef = real(ifft(ftXf));
%Ef = E+Ef;
