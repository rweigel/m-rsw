function Z = block_corrcoef(X,Y,L)
%BLOCK_CORRCOEF Block standard deviation
%
%   Z = BLOCK_CORRCOEF(X,Y,L) has columns that are the block correlation
%   coefficient of 1-D arrays X and Y with nonoverlapping window size L.
%
%   Z has floor(size(X,1)/L) rows (i.e., if last block is not full, the
%   extra data points are ignored).
%
%   See also BLOCK_CORRCOEF_NONFLAG, *_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (ndims(X) > 2)
   error('block_corrcoef: ndims(X) must be one or two');
end
if (size(X,1) == 1) & (size(X,2) >= 1)
   X = X';   
   flip = 1;
else
   flip = 0;
end
if (size(X,1) < L)
   error(['block_corrcoef: size(X,1) (= %d) must equal or less than'...
	  ' L (= %d) '],size(X,1),L);   	      
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

F  = floor(M/L);
Xr = reshape(X(1:F*L),L,F);
Yr = reshape(Y(1:F*L),L,F);

for i = 1:F
  tmp = corrcoef(Xr(:,i),Yr(:,i));
  Z(i,1) = tmp(2);
end

if (flip == 1)
   Z = Z';
end
