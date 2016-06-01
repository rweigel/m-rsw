function [Do,Trend] = block_detrend_nonflag(X,N,FLAG,COND)
%BLOCK_DETREND_NONFLAG Subtracts off block mean of non-FLAG elements.
%
%   D_dt = BLOCK_DETREND_NONFLAG(D,N) Subtracts off block mean of
%   elements not equal to NaN in non-overlapping windows of width N.
%
%   D_dt = BLOCK_DETREND_NONFLAG(D,N,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   D is a column vector and N is the number of elements per block.  D_dt
%   will have the same size as D.  If size(D,1)/N is not an integer FLAG
%   are used to pad D_dt.
%   
%   See also BLOCK_DETREND, BLOCK_DETREND_NONFLAG_DEMO, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

if (ndims(X) > 2)
   error('block_detrend_nonflag: ndims(X) must be two or one');
end
if (size(X,1) == 1) & (size(X,2) >= 1)
   X = X';   
   flip = 1;
else
   flip = 0;
end
if (size(X,1) < N)
   error(['block_detrend_nonflag: size(D,1) (= %d) must equal or less than'...
	  'N (= %d) '],size(X,1),N);   	      
end

for j = 1:size(X,2)
  
  D      = X(:,j);  

  Lo     = length(D);
  L      = floor(length(D)/N);
  tempD  = D(1:L*N);
  tempD  = reshape(tempD,N,L);

  temp   = mean_nonflag(tempD,1,FLAG);
  temp   = repmat(temp,N,1);
  I      = find( (temp == FLAG) | (tempD == FLAG));
  D      = tempD-temp;

  if (~isempty(I))
    D(I) = FLAG;
  end

  Do(:,j) = [D(:) ; FLAG*ones(Lo-L*N,1)];

  Trend(:,j) = [temp(:); FLAG*ones(Lo-L*N,1)];
end

if (flip == 1)
   Do = Do';   
   Trend = Trend';   
end
