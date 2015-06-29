function Do = block_detrend(X,N)
%BLOCK_DETREND Subtract off block mean.
%
%   X_dt = BLOCK_DETREND(X,N) Subtracts off block mean of elements in
%   non-overlapping windows of width N.  Operation is done columnwise.
%   size(X_dt) = size(X).  If size(X,1)/N is not an integer, NaN is used
%   to pad X_dt.  X may be a 1 or 2-D matrix.
%   
%   See also BLOCK_DETREND_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (ndims(X) > 2)
   error('block_detrend: ndims(X) must be two or one');
end
if (size(X,1) == 1) & (size(X,2) >= 1)
   X = X';   
   flip = 1;
else
   flip = 0;
end
if (size(X,1) < N)
   error(['block_detrend: size(X,1) (= %d) must equal or less than'...
	  'N (= %d) '],size(X,1),N);   	      
end
  
for j = 1:size(X,2)
  
  D      = X(:,j);  

  Lo     = length(D);
  L      = floor(length(D)/N);
  tempD  = D(1:L*N);
  tempD  = reshape(tempD,N,L);

  temp   = mean(tempD,1);
  temp   = repmat(temp,N,1);
  D      = tempD-temp;

  D       = D(:);
  Do(:,j) = [D ; repmat(NaN,Lo-L*N,1)];

end

if (flip == 1)
   Do = Do';   
end
