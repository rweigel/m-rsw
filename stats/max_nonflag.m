function Pd = max_nonflag(A,DIM,FLAG,COND)
%MAX_NONFLAG Largest non-FLAG component.
%
%   Amax = max_nonflag(A) for 1-D array is the max of elements not equal to
%   NaN.  
%  
%   Amax = max_nonflag(A,DIM) is max of elements not equal to NaN.
%
%   Amax = max_nonzero(A,DIM,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   If all elements along dimension DIM are equal to FLAG, a fill of FLAG is
%   used.
%
%   Maximum DIM is 3 if COND >= 0.  If three dimensional matrix, DIM must be 3.
%   (MAX_NONFLAG is not N-dimensional like function MAX.)
%
%   See also MAX, *_NONFLAG.

% R.S. Weigel, 04/02/2004.  

if (nargin < 2)
  if (min(size(A)) > 1)
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

if (prod(size(A)) == 1)
  Pd = FLAG;  % If one element and is zero, return FLAG.
  return;
end

if ( isempty(A) )
  Pd = [];  % If empty, return empty.
  return;
end

if (COND == -1) & (isnan(FLAG))
   Pd = max(A);
end	

if (DIM == 1)
  Pd = repmat(FLAG,1,size(A,2));  
  for i = 1:size(A,2)
    I = find(is_flag(A(:,i),FLAG,COND)==0);
    if (~isempty(I))
      Pd(1,i) = max(A(I,i));
    end
  end
end

if (DIM == 2)
  Pd = repmat(FLAG,size(A,1),1);
  for i = 1:size(A,1)
    I = find(is_flag(A(i,:),FLAG,COND)==0);
    if (~isempty(I))
      Pd(i,1) = max(A(i,I));
    end
  end
end

if (DIM == 3)
  Pd = repmat(FLAG,[size(A,1) size(A,2) 1]);
  for i = 1:size(A,1)
    for j = 1:size(A,2)      
      I = find(is_flag(A(i,j,:),FLAG,COND)==0);
      if (~isempty(I))
	    Pd(i,j,1) = max(A(i,j,I));
      end
    end
  end
end
