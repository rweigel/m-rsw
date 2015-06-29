function [xbp,aib,aibo,f] = bandpass(x,Tkeep)
%BANDPASS
%

y   = x-mean(x);
aib = fft(y);
P   = aib.*conj(aib);
N   = length(x);
f   = [1:N/2-1]/(N);
T   = (1./f);

if (length(Tkeep) == 1)
  I = find( T == Tkeep );
  if isempty(I)
    [Tm,I] = min(abs(T - Tkeep));  
    fprintf('bandpass.m: Warning: No exact match for requested period. ');
    fprintf(sprintf('Using %f\n',T(I)));
  end
else
  I = find( T >= Tkeep(1) | T <= Tkeep(2) );
end

Ikeep = [I+1,length(aib)-I+1];
Iomit = setdiff(1:length(aib),Ikeep);
aibo  = aib;

aib(Iomit) = 0;
xbp = real(ifft(aib));
