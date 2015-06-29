function Z = block_min(X,L)
%BLOCK_MIN Block min
%
%   See also BLOCK_MEAN.

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
   error(['block_min: size(X,1) (= %d) must equal or less than'...
	  ' L (= %d) '],size(X,1),L);   	      
end
  
M = size(X,1);
N = size(X,2);
F = floor(M/L);

for i = 1:N
  Y      = reshape(X(1:F*L,i),L,F);
  Z(:,i) = min(Y,[],1)';
end

if (flip == 1)
   Z = Z';
end
