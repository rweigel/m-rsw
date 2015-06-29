function Z = block_std_nonflag(X,L,FLAG,COND)
%BLOCK_STD_NONFLAG Block average of non-FLAG elements.
%
%   Y = BLOCK_STD_NONFLAG(X,L) has columns that are the block std of
%   the columns of X with nonoverlapping window size L.  If any value
%   in window L is non-NaN, it is used for the average.  
%
%   Y has the same number of columns as X and has floor(size(X,1)/L) 
%   rows (i.e., if last block is not full, the extra data points 
%   are ignored).
%
%   Example: block_std_nonflag([1 3;2 NaN],2) = [1.5;2]
%
%   Y = BLOCK_STD_NONFLAG(X,L,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   See also BLOCK_STD, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end
  
M = size(X,1);
N = size(X,2);
F = floor(M/L);

if (L == 1)
  error('Input L must be greater than 1');
end

for i = 1:N
  Y      = reshape(X(1:F*L,i),L,F);
  Z(:,i) = std_nonflag(Y,1,FLAG,COND)';
end
