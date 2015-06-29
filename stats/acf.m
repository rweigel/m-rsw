function r = acf(x,Nmax)
%ACF Autocorrelation function
%
%   r = ACF(x) returns the acf at lags 1:length(x)-2
%
%   r = ACF(x,N) returns the acf at lags 1:Nmax-2
%
%   See also ACOV.

if (nargin < 2)
  Nmax = length(x);
end

for k = 0:Nmax-2
  a = x(k+1:end);
  a = a-mean(a);
  b = x(1:end-k);
  b = b-mean(b);
  am = mean(a);         % mean of a
  bm = mean(b);         % mean of b
  ass = sum((a-am).^2); % sum of squares of a-mean(a)
  bss = sum((b-bm).^2); % sum of squares of b-mean(b)

  r(k+1) = sum(a.*b)/sqrt(ass*bss);
end