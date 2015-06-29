function Z = block_mean(X,L)
%BLOCK_MEAN Block average.
%
%   Y = BLOCK_MEAN(X,L) has columns that are the block mean of the columns
%   of X with nonoverlapping window size L.
%
%   Y has the same number of columns as X and has floor(size(X,1)/L) 
%   rows (i.e., if last block is not full, the extra data points 
%   are ignored).
%
%   See also BLOCK_MEAN_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (ndims(X) > 2)
   error('block_mean: ndims(X) must be one or two');
end
if (size(X,1) == 1) & (size(X,2) >= 1)
   X = X';   
   flip = 1;
else
   flip = 0;
end
if (size(X,1) < L)
   error(['block_max: size(X,1) (= %d) must equal or less than'...
	  ' L (= %d) '],size(X,1),L);   	      
end
  
M = size(X,1);
N = size(X,2);
F = floor(M/L);

for i = 1:N
  Y      = reshape(X(1:F*L,i),L,F);
  Z(:,i) = mean(Y,1)';
end

if (flip == 1)
   Z = Z';
end
