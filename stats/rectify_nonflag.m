function X = rectify_nonflag(X,FLAG,COND)
%RECTIFY_NONFLAG Rectify non-FLAG elements
%
%   RECTIFY_NONFLAG(X) Rectifies the non-NaN elements of X.
%
%   RECTIFY_NONFLAG(X,FLAG,COND) See IS_FLAG for a definition of FLAG and COND.
%
%   See also ABS, *_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (nargin < 2)
  FLAG = NaN;
end
if (nargin < 3)
  COND = 1;
end

I = is_flag(X,FLAG,COND);
X = 0.5*(abs(X) + X);

if (~isempty(I))
  X(I) = FLAG;
end
