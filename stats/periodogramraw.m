function [I,f,a,b,a0] = periodogramraw(x,method)
%PERIODOGRAM Compute raw periodogramraw
%
%   [I,f,a,b,a0] = PERIODOGRAMRAW(x)
%
%   [I,f] = PERIODOGRAMRAW(x,'fast') uses fft method to compute
%   coefficients. a, b, and a0 are not returned.
%
%   Notation is used in Fourier Methods section of
%   http://bobweigel.net/csi763/
%

if (nargin < 2)
  method = 'slow';
end

if strmatch('fast',method,'exact')

  N = length(x);
  xfft = fft(x);
  b = (2/N)*real(xfft);
  a = (2/N)*imag(xfft);
  if (round(N/2) == N/2) % N is even
    f = [1:N/2]'/N;
    a(N/2+1)=(1/2)*a(N/2+1);
    b(N/2+1)=(1/2)*b(N/2+1);
    I = (N/2)*[a.*a+b.*b];
    I = I(1:N/2+1);
    a = real((2/N)*exp(-2*pi*j*[1:N/2]'/N).*xfft(2:N/2+1));
    b = -imag((2/N)*exp(-2*pi*j*[1:N/2]'/N).*xfft(2:N/2+1));
    a(end) = a(end)/2;
  end
  if (round(N/2) ~= N/2) % N is odd
    f = [1:(N-1)/2]'/N;    
    I = (N/2)*[a.*a+b.*b];
    I = I(1:(N-1)/2+1);
    a = real((2/N)*exp(-2*pi*j*[1:(N-1)/2]'/N).*xfft(2:(N-1)/2+1));
    b = -imag((2/N)*exp(-2*pi*j*[1:(N-1)/2]'/N).*xfft(2:(N-1)/2+1));
  end
  f = [0;f];
  a0 = xfft(1)/N;
  return;
end

N  = length(x);
a0 = mean(x);
t  = [1:N]';

if (round(N/2) == N/2) % N is even
  q = N/2-1;
  for i = 1:q
    fi = i/N;
    f(i,1) = fi;
    ci = cos(2*pi*fi*t);
    si = sin(2*pi*fi*t);
    a(i,1) = (2/N)*sum(x.*ci);
    b(i,1) = (2/N)*sum(x.*si);
  end
  I = a.*a + b.*b;
  a(i+1,1) = (1/N)*sum(x.*((-1).^t));
  b(i+1,1) = 0; % Adding this for convenience (but makes number of output
                % parameters one more than length of input).
  f(i+1,1) = 1/2;
  I(i+1,1) = a(i+1,1)*a(i+1,1);
  I = (N/2)*[a0*a0*2*2; I];
end

if (round(N/2) ~= N/2) % N is odd
  q = (N-1)/2;
  for i = 1:q
    fi = i/N;
    f(i,1) = fi;
    ci = cos(2*pi*fi*t);
    si = sin(2*pi*fi*t);
    a(i,1) = (2/N)*sum(x.*ci);
    b(i,1) = (2/N)*sum(x.*si);
  end
  I = a.*a + b.*b;
  I = (N/2)*[a0*a0*2*2; I];
end

f = [0;f];

