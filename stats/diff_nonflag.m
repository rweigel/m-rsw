function Pd = diff_nonflag(A,DIM,FLAG,COND)
%MEAN_NONFLAG Average of elements 
%
%   Adiff = diff_nonflag(A) for 1-D array is the first difference between
%   elements not equal to FLAG = NaN.  Adiff(end) is set equal to FLAG so
%   that Adiff has the same size as A.
%
%   Adiff = diff_nonflag(A,DIM) is differrence of elements not equal to NaN
%   along dimension DIM.
%
%   Adiff = diff_nonzero(A,DIM,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   If all elements along dimension DIM are equal to FLAG, a fill of FLAG is
%   used.
%
%   Maximum DIM is 2.  (DIFF_NONFLAG is not N-dimensional like function
%   DIFF.)
%
%   See also DIFF, NONFLAG.

% R.S. Weigel, 04/02/2004.  
  
if (nargin < 2)
  if (min(size(A) > 1))
    error('DIM must be specified');
  else
    [junk,DIM] = max(size(A));
  end
end
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end

N = 1;

if (prod(size(A)) == 1)
  Pd = FLAG;  % If one element, return FILL
  return;
end

if ( isempty(A) )
  Pd = [];  % If empty, return empty
  return;
end

if (size(A,1)==1)
  DIM = 2;
end
if (size(A,2)==1)
  DIM = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if (DIM == 1)
  for i = 1:size(A,2)
	I = is_flag(A(:,i),FLAG,COND);
 
    temp = diff(A(:,i),N);    
    temp = [temp ; FLAG*ones(N,1)];

    if (~isempty(I))
      if (I(1) == 1)
	    temp(1)   = FLAG;
	    if (length(I) > 1)
	      I = I(2:end);
	    end
      end
      if (I(end) == length(temp))
	     temp(end) = FLAG;
	     if (length(I) > 1)
	        I = I(1:end-1);
	     end
      end
      temp(I) = FLAG;
      if (length(I) > 1)
	    temp(I-1)  = FLAG;
      end
    end

    Pd(:,i) = temp;

  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if (DIM == 2)
  for i = 1:size(A,1)
	I = is_flag(A(i,:),FLAG,COND);
 
    temp = diff(A(i,:),N);    
    temp = [temp , FLAG*ones(N,1)];

    if (~isempty(I))
      if (I(1) == 1)
	     temp(1) = FLAG;
	     if (length(I) > 1)
	        I = I(2:end);
	     end
      end
      if (I(end) == length(temp))
	     temp(end) = FLAG;
	     if (length(I) > 1)
	        I = I(1:end-1);
	     end
      end
      temp(I) = FLAG;
      if (length(I)>1)
	    temp(I-1)  = FLAG;
      end
    end
    
    Pd(i,:) = temp;

  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

