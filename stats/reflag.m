function [X,I,Ig] = reflag(X,FLAG_o,FLAG_f,COND)
%REFLAG Change flag values.
%
%  X = REFLAG(X,FLAG_o,FLAG_f) Replaces instances of FLAG_o in X with FLAG_f.
%
%  X = REFLAG(X,FLAG_o,FLAG_f,COND) See IS_FLAG for a definition
%  of FLAG and COND.
%
%  [X,I]    = REFLAG(...) Returns I, the indices of the reflagged elements.
%  [X,I,Ig] = REFLAG(...) Returns Ig, the indices of the nonflagged elements.
%
%  See also *_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (nargin < 4)
  COND = 1;
end

if (length(FLAG_o) > 1)
  error('reflag: FLAG_o must be a scalar');
end
if (length(FLAG_f) > 1)
  error('reflag: FLAG_f must be a scalar');
end

if (COND == 2)
  if (FLAG_o < 0)
    warning('With COND = 2 and FLAG_o < 0, all elements will be FLAG_f');
  end
end

I = is_flag(X,FLAG_o,COND);
if (~isempty(I))
  X(I) = FLAG_f;
end

if (nargout > 1)
  I = find(I == 1);
end	
if (nargout > 2)
  Ig = find(I == 0);
end
