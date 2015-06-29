function x = moving_mean(x,N)
%MOVING_MEAN Moving average.
%  
%
%   See also MOVING_MEAN_NONFLAG, MOVING_MEAN, FILTER, *_NONFLAG.

% R.S. Weigel, 04/02/2004.

x = moving_sum(x,N)/N;

