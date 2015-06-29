function Pd = std_nonflag(A,DIM,FLAG,EXACT)
%STD_NONFLAG Standard deviation of non-FLAG elements.
%
%   Astd = STD_NONFLAG(A,DIM) is std of elements not equal to NaN.
%
%   Astd = STD_NONFLAG(A,DIM) is std of elements not equal to NaN.
%
%   Astd = STD_NONFLAG(A,DIM,FLAG,EXACT) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   If all elements along dimension DIM are equal to FLAG, a fill of FLAG is
%   used.
%
%   Maximum DIM is 3.  If three dimensional matrix, DIM must be 3.
%   (STD_NONFLAG is not N-dimensional like function STD.)
%
%   See also STD, *_NONFLAG.

% R.S. Weigel, 04/02/2004.
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if (nargin < 2)
  DIM = min(find(size(A)>1));
end
if (nargin < 3)
  FLAG     = NaN;
end
if (nargin < 4)
  EXACT = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

if (prod(size(A)) == 1)
  Pd = FLAG;  % If one element and is zero, return FILL
  return;
end

if ( isempty(A) )
  Pd = FLAG;  % If empty, return FILL
  return;
end

if (DIM == 1)
  Pd = repmat(FLAG,1,size(A,2));  
  for i = 1:size(A,2)
      I = [];
    if (EXACT == 0)
      I = find(A(:,i) < FLAG);
    end
    if (EXACT == 1)
      I = find(A(:,i) ~= FLAG);
    end
    if (EXACT == 2)
      I = find(abs(A(:,i)) < FLAG);
    end
    if (isnan(FLAG))
      I = find(isnan(A(:,i)) == 0);
    end

    if (~isempty(I))
      % Using this
      % Pd(1,i) = std(A(I,i)); 
      % when all elements are the same gives error:
      % ??? First argument must be single or double
      % This has the same problem: std([1:10])
      
      % Workaround
      if all(A(I,i)==A(I(1),i))
	Pd(1,i) = 0.0;      
      else
	try
	  Pd(1,i) = std(A(I,i));
	catch
	  fprintf(['std_nonflag: problem with STD function.  Setting STD' ...
		   ' to NaN']);
	  lasterr()
	  Pd(1,i) = 0.0;
	end
      end
    end
  end
end

if (DIM == 2)
  Pd = repmat(FLAG,size(A,1),1);
  for i = 1:size(A,1)
      I = [];
    if (EXACT == 0)
      I = find(A(i,:) < FLAG);
    end
    if (EXACT == 1)
      I = find(A(i,:) ~= FLAG);
    end
    if (EXACT == 2)
      I = find(abs(A(i,:)) < FLAG);
    end
    if (isnan(FLAG))
      I = find(isnan(A(i,:)) == FLAG);
    end

    if (~isempty(I))
      Pd(i,1) = std(A(i,I));
    end
  end
end

if (DIM == 3)
  Pd = repmat(FLAG,[size(A,1) size(A,2) 1]);
  for i = 1:size(A,1)
    for j = 1:size(A,2)      
        I = [];
      if (EXACT == 0)
	I = find(A(i,j,:) < FLAG);
      end
      if (EXACT == 1)
	I = find(A(i,j,:) ~= FLAG);
      end
      if (EXACT == 2)
	I = find(abs(A(i,j,:)) < FLAG);
      end
      if (isnan(FLAG))
	I = find(isnan(A(i,j,:)) == FLAG);
      end
      
      if (~isempty(I))
	Pd(i,j,1) = std(A(i,j,I));
      end
    end
  end
end



