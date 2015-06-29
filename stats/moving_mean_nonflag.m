function [x,ng] = moving_mean_nonflag(x,N,FLAG,COND)
%MOVING_MEAN_NONFLAG Moving average of non-FLAG elements.
%  
%
%   See also MOVING_MEAN, MOVING_SUM_NONFLAG, FILTER, *_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

[x,ng] = moving_sum_nonflag(x,N,FLAG,COND);

I = (ng > 0);
x(I) = x(I)./ng(I);
I = (ng == 0);
x(I) = FLAG;
