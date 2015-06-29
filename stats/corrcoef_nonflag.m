function Z = corrcoef_nonflag(X,Y,FLAG,COND)
%CORRCOEF_NONFLAG Correlation coefficient of non-FLAG elements.
%
%   Z = CORRCOEF_NONFLAG(X,Y) or CORRCOEF_NONFLAG([X Y]) is the
%   correlation between the elements in column vectors X and Y
%   that are both not equal to NaN.
%
%   Z = CORRCOEF_NONFLAG(X,Y,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   The syntax CORRCOEF_NONFLAG([X Y],FLAG,COND) is not allowed.
%
%   See also CORRCOEF, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

if (nargin == 1)
   if (size(X,2) ~= 2)
	  error('corrcoef_nonflag: two columns required when only one input.');
   end	
   Y = X(:,2);
   X = X(:,1);
end	

M = size(X,1);
N = size(X,2);

if (N > M)
  X = X';
  Y = Y';
  M = size(X,1);
  N = size(X,2);
  if (N > 1)
    error('X and Y must be 1-D arrays');
  end
end

Ib = is_flag([X,Y],FLAG,COND);

I = (Ib(:,1) == 0) & (Ib(:,2) == 0);

if (length(I) > 1)
  Z = corrcoef(X(I),Y(I));
else
  Z = FLAG;
end
