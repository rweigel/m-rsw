function X = unscale(Xs,S,OPT)
%UNSCALE Scale columns of matrix.
%
%   X = UNSCALE(Xs,S) Invert the operation of [Xs,S] = SCALE(X);
%  
%   X = UNSCALE(Xs,S,OPT) Inverts operation of SCALE(X,OPT).
%
%   See also SCALE.

if (nargin < 3),OPT = 1;,end

if (OPT == 1)
  X        = Xs.*repmat(S(2,:),size(Xs,1),1);
  X        = X + repmat(S(1,:),size(Xs,1),1);
end

if (OPT == 2)
  X        = Xs.*repmat(S(2,:),size(Xs,1),1);  
  X        = X + repmat(S(1,:),size(Xs,1),1);
end

if (OPT == 3)
  X        = 10.^(Xs);
end

if (OPT == 4)
  Xs       = (2.0*Xs - 1.0);
  X        = Xs.*repmat(S(2,:),size(Xs,1),1);
  X        = X + repmat(S(1,:),size(Xs,1),1);
end

if (OPT == 5)
  X        = Xs.*repmat(S(2,:),size(Xs,1),1);
  X        = X + repmat(S(1,:),size(Xs,1),1);
end

if (OPT == 6)
  X        = Xs.*repmat(S(2,:),size(Xs,1),1);
  X        = X + repmat(S(1,:),size(Xs,1),1);
end
