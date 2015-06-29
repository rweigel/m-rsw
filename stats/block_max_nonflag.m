function Z = block_max(X,L)
%BLOCK_MAX_NONFLAG Block max of non-nan elements
%
%   See also BLOCK_MEAN.

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
  Z(:,i) = max_nonflag(Y,1)';
end

if (flip == 1)
   Z = Z';
end
