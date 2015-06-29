function X = rectify(X)
%RECTIFY Rectify elements of array (set negative values to zero).
%
%   RECTIFY(X) = 0.5*(abs(X) + X)
%
%   See also ABS.

% R.S. Weigel, 04/02/2004.
  
X =  0.5*(abs(X) + X);