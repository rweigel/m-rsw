function x = moving_sum(x,N)
%MOVING_SUM Moving sum 
%  
%   Y = MOVING_SUM(X,N) Each column of X is filtered according to
%
%   Y(i+(N-1),j) = X(i+(N-1),j) + X(i-(N-2),j) + ... + X(i-(N-N),j)
%
%   with Y(1:N-1,:) = NaN.  This is a moving sum filter with the moving
%   sum computed only when N elements are availablee.
%
%   For example if N = 3, 
%   Y(1,j) = NaN;
%   Y(2,j) = NaN;
%   Y(3,j) = X(3,j) + X(2,j) + X(1,j);
%
%   See also MOVING_MEAN_NONFLAG, FILTER.

if (N > size(x,1))
  error(['moving_sum: N (= %d) must be less than or equal '...
          'size(x,1) (= %d)\n'],N,size(x,1));
end

x = filter(ones(N,1),1,x);
x(1:N-1,:) = NaN;

