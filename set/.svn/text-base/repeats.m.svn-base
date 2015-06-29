function [I,Ia] = repeats(X,r)
%REPEATS Indices of repeated elements or rows
%
%  I = REPEATS(X) lists indices of repeated elements in X that would be
%  removed by X = UNIQUE(X).
%
%  [I,Iall] = REPEATS(X) lists indices of all repeated elements in X.
%
%  ... = REPEATS(X,'rows') returns repeated rows.
%
%  Example: If X = [1 2 3 3 4 3], 
%
%  [I,Iall] = REPEATS(X) gives
%
%  I    = [3 4]
%  Iall = [3 4 6]
%  
%  See also, UNIQUE, REPEATS_DEMO.
  
if (nargin == 1)
  L = length(X);
  if (nargout == 2)
    Xo = X(:);
    [X,I,J] = unique(Xo(:));
    Io = I;
  else
    [X,I] = unique(X(:));
  end
end

if (nargin == 2)  
  L = size(X,1);
  if (nargout == 2)
    Xo = X;
    [X,I,J] = unique(Xo,'rows');
    Io = I;
  else
    [X,I] = unique(X,'rows');
  end
end

I = setdiff([1:L],I);

if (nargout == 2)
  if (nargin == 1)
    [J,K] = intersect(X,Xo(I)); clear J
  else
    [J,K] = intersect(X,Xo(I,:),'rows'); clear J
  end
  Ia = [I,Io(K)'];
end

  