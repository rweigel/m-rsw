function LIN = basic_linear(X,T,Itrain,Itest)
%BASIC_LINEAR A simple linear regression.
% 
%    LIN = BASIC_LINEAR(X,T) Each row of X is a set of observations that
%    will be used to predict the respective row in the single-column target
%    vector T.  The linear relationship between T from X is determined by
%    calculating the weights, w, and vector of coefficients b that satisfies
%    T = X*w+b.  All data is used for training.  Any row in which T or X has
%    one or more NaN elements is omitted.  The function TIME_DELAY may be
%    used to create the matrix X.
%
%    X = [] is allowed.  In this case the single output weight is the
%    average of the non-NaN elements of T.
%
%    LIN = BASIC_LINEAR(X,Target,Ntrain). The training set is a random
%    sample of Ntrain elements of Target.  The test set is composed of the
%    remaining elements.
%
%    LIN = BASIC_LINEAR(X,Target,Itrain,Itest) If Itrain and Itest are
%    vectors, data is trained with Target(Itrain) and X(Itrain,:) and tested
%    with Target(Itest) and X(Itest,:).
% 
%    LIN is a structure with fields ARVtrain, ARVtest, MSEtrain, MSEtest,
%    Ttrain, Ttest, and Weights, where W = [w ; b].  Ttrain and Ttest
%    will have the same number of elements of T, with NaNs 
%     
%    Tpredicted = BASIC_LINEAR(X,W,'predict') Creates output Tpredicted
%    based on linear model W.  length(Tpredicted) = size(X,1), even if X has
%    NaN elements; rows of X that have one or more NaNs will result in a
%    corresponding row of Tpredicted that is NaN.
%  
%    See also TIME_DELAY, BASIC_NET, BASIC_LINEAR_DEMO.

if (nargin == 3)
  if (isstr(Itrain))
    if strmatch('predict',Itrain)
      if isempty(X)
	LIN = T(1);
	return
      end
      if (size(X,2) ~= size(T,1))
%      if (size(X,2) ~= size(T,1)-1)
	error('basic_linear: size mismatch between X and W');
      end
%      LIN = X*T(1:end-1) + T(end);
       LIN = X*T(1:end);
      return;
    end
  end
end

if (nargin < 3)
  Itrain = [1:length(T)]';
  Itest  = Itrain;
end

if (length(Itrain) == 1)
  R      = randperm(length(T));
  Itest  = R(Itrain+1:end);
  Itrain = R(1:Itrain);
end

if (isempty(Itrain) & isempty(Itest))
  Itest  = [1:length(T)]';
  Itrain = [1:length(T)]';
end

if (length(Itrain) == 1)
  Ntrain = Itrain;
end

% Keep rows where X and T both had no NaNs
Ig = find( (isnan(sum([X,T],2)) == 0) ); % Both have all "good" elements
Ib = find( (isnan(sum([X,T],2))  > 0) ); % Either have "bad" element

% Solve for w that minimizes error in T(Itrain) = X(Itrain,:)*w + b;

%X         = [X ones(size(X,1),1)];  % Add a constant value for b.

ItrainI   = intersect(Itrain,Ig);
ItestI    = intersect(Itest,Ig);
if (length(ItestI) < 2)
  ItestI = Itest;
end

if ~isempty(X)
  w         = X(ItrainI,:)\T(ItrainI);    % See help mldivide.
  Ttest     = X(ItestI,:)*w;              % Test set predictions using w.
  Ttrain    = X(ItrainI,:)*w;             % Training set predictions using w.
else
  w      = mean_nonflag(T(ItrainI));
  Ttest  = repmat(mean_nonflag(T(ItestI)),length(ItestI),1);
  Ttrain = repmat(w,length(ItrainI),1);  
end

Etrain    = arv(T(ItrainI),Ttrain);
Etest     = arv(T(ItestI),Ttest);

MSEtrain  = mse(T(ItrainI),Ttrain);
MSEtest   = mse(T(ItestI),Ttest);

LIN.ARVtrain = Etrain;
LIN.ARVtest  = Etest;
LIN.MSEtrain = MSEtrain;
LIN.MSEtest  = MSEtest;
LIN.Weights  = w;
LIN.Ttrain   = Ttrain;
LIN.Itrain   = ItrainI;
LIN.Ttest    = Ttest;
LIN.Itest    = ItestI;

