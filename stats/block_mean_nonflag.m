function [Z,Ng] = block_mean_nonflag(X,L,FLAG,COND)
%BLOCK_MEAN_NONFLAG Block average of non-FLAG elements.
%
%   Y = BLOCK_MEAN_NONFLAG(X,L) has columns that are the block mean of
%   the columns of X with nonoverlapping window size L.  If any value
%   in window L is non-NaN, it is used for the average.  
%
%   Y has the same number of columns as X and has floor(size(X,1)/L) 
%   rows (i.e., if last block is not full, the extra data points 
%   are ignored).
%
%   Example: block_mean_nonflag([1 3 ; 2 NaN],2) = [1.5 ; 2]
%
%   Y = BLOCK_MEAN_NONFLAG(X,L,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   See also BLOCK_MEAN, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

if (ndims(X) > 2)
   error('block_detrend: ndims(X) must be one or two');
end
if (size(X,1) == 1) & (size(X,2) >= 1)
   X = X';   
   flip = 1;
else
   flip = 0;
end
if (size(X,1) < L)
   error('block_detrend: size(X,1) (= %d) must equal or less than L (= %d) ',...
         size(X,1),L);   	      
end
  
M = size(X,1);
N = size(X,2);
F = floor(M/L);

if (L == 1)
  warning('Input L should be greater than 1');
  Z = X;
  Ng = is_flag(X,FLAG,COND);
  return;
end

for i = 1:N
  Y = reshape(X(1:F*L,i),L,F);
  if (nargout > 1)
    [tempZ,tempNg] = mean_nonflag(Y,1,FLAG,COND);
    Z(:,i)  = tempZ';
    Ng(:,i) = tempNg';
  else
    Z(:,i) = mean_nonflag(Y,1,FLAG,COND)';  
  end
end

if (flip == 1)
   Z = Z';
end
