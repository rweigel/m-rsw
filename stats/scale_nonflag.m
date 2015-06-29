function [Xs,S] = scale_nonflag(X,OPT,So,FLAG,COND)
%SCALE_NONFLAG Scale columns of matrix using non-FLAG data.
%
%   [Xs,S]  = SCALE_NONFLAG(X,OPT,S,FLAG,COND) See IS_FLAG for a definition
%   of FLAG and COND.
%
%   If S = [] uses SCALE(X,OPT)
%
%   See also SCALE, *_NONFLAG.

% R.S. Weigel, 04/02/2004.

if (nargin == 1)
   OPT = 1;
end
if (nargin < 3)
   So = [];
end
if (nargin < 4)
  FLAG = NaN;
end
if (nargin < 5)
  COND = 1;
end

if (isempty(So))

  if (isempty(OPT)),OPT = 1;,end

  if (OPT == 1)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    S(1,:)    = mean_nonflag(X,1,FLAG,COND);
    X         = X - repmat(S(1,:),size(X,1),1);
    X(I)      = FLAG;
    S(2,:)    = max_nonflag(X,1,FLAG);
    Xs        = X./repmat(S(2,:),size(X,1),1);
    Xs(I)     = FLAG;
  end

  if (OPT == 2)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    S(1,:)    = mean_nonflag(X,1,FLAG,COND);
    X         = X - repmat(S(1,:),size(X,1),1);
    X(I)      = FLAG;
    S(2,:)    = std_nonflag(X,1,FLAG,COND);
    Xs        = X./repmat(S(2,:),size(X,1),1);  
    Xs(I)     = FLAG;
  end
  
  if (OPT == 3)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    Xs        = log10(X);
    Xs(I)     = FLAG;
    S         = [];
  end
  
  if (OPT == 4)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    [Xs,S]    = scale_nonflag(X,1,FLAG,COND);
    Xs        = (Xs+1.0)/2.0;
    Xs(I)     = FLAG;
  end
  
  if (OPT == 5)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    S(1,:)    = min_nonflag(X,1,FLAG,COND);
    X         = X - repmat(S(1,:),size(X,1),1);
    X(I)      = FLAG;
    S(2,:)    = max_nonflag(X,1,FLAG,COND);
    Xs        = X./repmat(S(2,:),size(X,1),1);
    Xs(I)     = FLAG;
  end

  if (OPT == 6)
    [X,I]     = reflag(X,FLAG,FLAG,COND);
    S(1,:)    = min_nonflag(X,1,FLAG,COND);
    X         = X - repmat(S(1,:),size(X,1),1);
    X(I)      = FLAG;
    S(2,:)    = std_nonflag(X,1,FLAG,COND);
    Xs        = X./repmat(S(2,:),size(X,1),1);
    Xs(I)     = FLAG;
  end
end

if (~isempty(So))

  S      = So;
  [X,I]  = reflag(X,FLAG,FLAG,COND);
  
  if (OPT == 1)
    X         = X - repmat(S(1,:),size(X,1),1);
    Xs        = X./repmat(S(2,:),size(X,1),1);
  end
  
  if (OPT == 2)
    X         = X - repmat(S(1,:),size(X,1),1);
    Xs        = X./repmat(S(2,:),size(X,1),1);  
  end
  
  if (OPT == 3)
    Xs        = log10(X);
    S         = [];
  end

  if (OPT == 4)
    X         = X - repmat(S(1,:),size(X,1),1);
    Xs        = X./repmat(S(2,:),size(X,1),1);
    Xs        = (Xs+1.0)/2.0;
  end
  
  if (OPT == 5)
    X         = X - repmat(S(1,:),size(X,1),1);
    Xs        = X./repmat(S(2,:),size(X,1),1);
  end
  
  if (OPT == 6)
    X         = X - repmat(S(1,:),size(X,1),1);
    Xs        = X./repmat(S(2,:),size(X,1),1);  
  end

  Xs(I)     = FLAG;

end
