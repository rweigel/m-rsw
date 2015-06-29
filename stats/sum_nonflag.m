function [B,Ng] = sum_nonflag(A,DIM,FLAG,COND)
%SUM_NONFLAG Average of non-FLAG elements.
%
%   [B,Ng] = SUM_NONFLAG(A) for 1-D array is the sum of elements not equal
%   to NaN.  Ng contains the number of elements used in the sum.
%
%   [B,Ng] = SUM_NONFLAG(A,DIM) is sum of elements not equal to NaN.
%
%   [B,Ng] = SUM_NONFLAG(A,DIM,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   If all elements along dimension DIM are equal to FLAG, a fill of FLAG is
%   used.  Maximum DIM is 2.
%
%   See also SUM, NONFLAG.

if (nargin < 2)
  DIM = min(find(size(A)>1));
end
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end
if (isnan(FLAG))
  COND = -1;
end

B = zeros(size(A));
I = ~is_flag(A,FLAG,COND);

B(I) = A(I);
B    = sum(B,DIM);
Ng   = sum(I,DIM);
