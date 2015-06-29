function [Xs,S] = scale(X,OPT,S)
%SCALE Scale columns of matrix.
%
%   [Xs,S]  = SCALE(X) Subtract off mean and divide by max(abs()) of columns.
%   S(1,:)  = mean of each column. 
%   S(2,:)  = max(abs()) of each column after mean is subtracted off.
%   
%   [Xs,S] = SCALE(X,OPT) scales using method OPT.
%
%   [Xs,S] = SCALE(X,OPT,S) scales using method of option OPT with scale 
%            factors S; Returned S = Xs in this case.
%   
%   OPT = 1 Scale to [-1,1] (default).  Mean is zero, max(abs(X)) is 1.
%           S(1,:) = means of each column. 
%           S(2,:) = max(abs()) of each column after mean is subtracted off.
%   OPT = 2 Subtract of mean and divide by standard dev. (N-1 normalization).
%           S(1,:) = Means of each column.
%           S(2,:) = Standard deviation of each column.
%   OPT = 3 Take log10 of each column. 
%           S      = [];
%   OPT = 4 Scale to interval [0,1].  Mean is 0.5, max is 1, min is variable.
%           S(1,:) = means of each column. 
%           S(2,:) = max(abs()) of each column after mean is subtracted off.
%   OPT = 5 Scale to interval [0,1].  max is 1, min 0, mean is variable.
%           S(1,:) = min of each column. 
%           S(2,:) = max of each column after min is subtracted off.
%   OPT = 6 Subtract off min and divide by standard dev. (N-1 normalization).
%           S(1,:) = min of each column. 
%           S(2,:) = std of each column after min is subtracted off.
%   OPT = 7 Divide by max of each column.
%           S(1,:) = mean of each column.
%           S(2,:) = max of each column. 
%
%   See also UNSCALE.

if (nargin == 1), OPT = 1;,end

if (nargin < 3)

if (isempty(OPT)),OPT = 1;,end

if (OPT == 1)
  S(1,:)    = mean(X);
  X         = X - repmat(S(1,:),size(X,1),1);
  S(2,:)    = max(abs(X));
  Iz = find(S(2,:)==0);
  if (~isempty(Iz))
    for i = 1:length(Iz)
      warning(sprintf(...
	  'scale: max of column %d after removal of mean is zero.',Iz(i)))
    end
  end
  S(2,Iz) = 1;
  Xs      = X./repmat(S(2,:),size(X,1),1);
end

if (OPT == 2)
   S(1,:)    = mean(X);
   X         = X - repmat(S(1,:),size(X,1),1);
   S(2,:)    = std(X);
   Iz = find(S(2,:)==0);
   if (~isempty(Iz))
     error(sprintf('scale: standard deviation of column %d is zero.',Iz))
   end
   Xs        = X./repmat(S(2,:),size(X,1),1);  
end

if (OPT == 3)
  Xs        = log10(X);
  S         = [];
end

if (OPT == 4)
  [Xs,S]    = scale(X);
  Xs        = (Xs+1.0)/2.0;
end

if (OPT == 5)
  S(1,:)    = min(X);
  X         = X - repmat(S(1,:),size(X,1),1);
  S(2,:)    = max(X);
  Xs        = X./repmat(S(2,:),size(X,1),1);
end

if (OPT == 6)
  S(1,:)    = min(X);
  X         = X - repmat(S(1,:),size(X,1),1);
  S(2,:)    = std(X);
   Iz = find(S(2,:)==0);
   if (~isempty(Iz))
     error(sprintf('scale: standard deviation of column %d is zero.',Iz))
   end
  Xs        = X./repmat(S(2,:),size(X,1),1);
end

if (OPT == 7)
  S(1,:)    = mean(X);
  S(2,:)    = max(X);
  Xs        = X./repmat(S(2,:),size(X,1),1);
end

end

if (nargin == 3)
  
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

if (OPT == 7)
  Xs        = X.*repmat(S(2,:),size(X,1),1);
end

end
