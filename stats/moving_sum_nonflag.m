function [x,ng] = moving_sum_nonflag(x,N,FLAG,COND)
%MOVING_SUM_NONFLAG Moving sum of non-FLAG elements
%  
%   Y = MOVING_SUM_NONFLAG(X,N) Each column of X is filtered according to
%
%   Y(i+(N-1),j) = X(i+(N-1),j) + X(i-(N-2),j) + ... + X(i-(N-N),j)
%
%   with Y(1:N-1,:) = NaN.  This is a moving sum filter with the moving
%   sum computed only when N elements are available.
%
%   For example if N = 3, 
%   Y(1,j) = NaN;
%   Y(2,j) = NaN;
%   Y(3,j) = X(3,j) + X(2,j) + X(1,j);
%
%   See also MOVING_MEAN, FILTER.

if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

Ib = is_flag(x,FLAG,COND);

if (nargout > 1)
  ng = ones(size(x));
  ng(Ib) = 0;
  ng = filter(ones(N,1),1,ng);
  ng(1:N-1,:) = NaN;
end

x(Ib) = 0;
x = filter(ones(N,1),1,x);
x(1:N-1,:) = NaN;
