function Y = prod_nonflag(X,Y,FLAG,COND)
%PROD_NONFLAG Product of nonflag values
%
%   Y = PROD_NONFLAG(X,Y)
%
%   Y = PROD_NONFLAG(X,Y,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   X and Y can be a matrix and scalar, or matrix and matrix.
%
%   See also *_NONFLAG.

% R.S. Weigel, 03/19/2005.  

if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

IX   = is_flag(X,FLAG,COND);
IY   = is_flag(Y,FLAG,COND);
I    = find((IX == 1) & (IY == 1));
Y    = X.*Y;
Y(I) = FLAG;
  