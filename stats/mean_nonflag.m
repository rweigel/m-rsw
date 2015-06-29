function [B,Ng] = mean_nonflag(A,DIM,FLAG,COND,force_internal_fn)
%MEAN_NONFLAG Average of non-FLAG elements.
%
%   [B,Ng] = mean_nonflag(A) for 1-D array is the mean of elements not equal
%   to NaN.  Ng contains the number of elements used in the average.
%
%   [B,Ng] = mean_nonflag(A,DIM) is mean of elements not equal to NaN.
%
%   [B,Ng] = mean_nonzero(A,DIM,FLAG,COND) See IS_FLAG for a definition of
%            FLAG and COND.
%
%   If all elements along dimension DIM are equal to FLAG, a fill of FLAG is
%   used.  Maximum DIM is 2.
%
%   See also MEAN, NONFLAG.

force_internal_fn = 0; % Use for loop

if (nargin < 2)
  DIM = min(find(size(A)>1));
end
if (nargin < 3)
  FLAG = NaN;
end
if (nargin < 4)
  COND = 1;
end
if (isnan(FLAG))
  COND = -1;
end

[B,Ng] = sum_nonflag(A,DIM,FLAG,COND);
Ib = find(Ng == 0);
B(Ib) = NaN;
Ig = find(Ng > 1);
B(Ig) = B(Ig)./Ng(Ig); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (force_internal_fn == 1)

if (DIM == 2)
  A = A';
end  

mrows = size(A,1);
ncols = size(A,2);

for j = 1:ncols

  k    = 0;
  temp = 0.0;
  
  for i = 1:mrows

    ind = i + (j-1)*mrows;
    
    if ( is_flag(A(ind),FLAG,COND) == 0 )
	temp = temp + A(ind);
	k   = k+1;
    end
  
  end

  if (k == 0)
    B(j)  = FLAG;
    Ng(j) = 0;
  else
    B(j)  = temp/k;
    Ng(j) = k;
  end

end % for j

if (DIM == 2)
  B  = B';
  Ng = Ng';
end  

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
