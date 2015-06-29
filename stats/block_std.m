function Z = block_std(X,L)
%BLOCK_STD Block standard deviation
%
%   Y = BLOCK_STD(X,L) has columns that are the block standard deviation
%   of the columns of X with nonoverlapping window size L.
%
%   Y has the same number of columns as X and has floor(size(X,1)/L) 
%   rows (i.e., if last block is not full, the extra data points 
%   are ignored).
%
%   See also BLOCK_STD_NONFLAG, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
M = size(X,1);
N = size(X,2);
F = floor(M/L);

for i = 1:N
  Y      = reshape(X(1:F*L,i),L,F);
  Z(:,i) = std(Y,0,1)';
end
