function LIN = basic_linear(X,T,Itrain,Itest)
% BASIC_LINEAR A simple linear regression.
% 
%    LIN = BASIC_LINEAR(X,T) All of data is used for training.  Each row of
%    X is a set of observations that will be used to predict the respective
%    row in the single-column target vector T.  Determines the linear
%    relationship between T from X by calculating the vector of coefficients
%    b that satisfies T = X*w+b.
%
%    LIN = BASIC_LINEAR(X,Target) All of data is used for training.  Xin
%    is the input vector, Target is the target vector.
%
%    LIN = BASIC_LINEAR(X,Target,Ntrain). Training set is a random sample
%    of Ntrain elements of Target.  The test set is composed of the
%    remaining elements.
%
%    LIN = BASIC_LINEAR(X,Target,Itrain,Itest) If Itrain and Itest are
%    vectors, data is trained with Target(Itrain) and X(Itrain,:) and tested
%    with Target(Itest) and X(Itest,:).
% 
%    LIN is a structure with fields ARVtrain,ARVtest, MSEtrain,MSEtest,
%    Ttrain,Ttest,Tpred, and W, where W = [w,b];
%     
%    Tpredicted = BASIC_LINEAR(X,W,'predict') Creates output Tpredicted
%    based on linear model W.
%  
%    See also BASIC_NET.

if (nargin == 3)
  if (isstr(Itrain))
    if strmatch('predict',Itrain)
      LIN = X*T(1:end-1) + T(end);
      return;
    end
  end
end

if (nargin < 3)
  Itrain = [1:length(T)]';
  Itest  = Itrain;
end

if ( length(Itrain) == 1 )
  Ntrain = Itrain;
  R      = randperm(length(T));
  Itest  = R(Ntrain+1:end);
  Itrain = R(1:Ntrain);
end

if (isempty(Itrain) & isempty(Itest))
  Itest = [1:length(T)]';
  Itrain = [1:length(T)]';
end

% Begin by solving for w that minimizes error in 
% T(Itrain) = X(Itrain,:)*w + b;

X         = [X ones(size(X,1),1)];  % Add a constant value for b.

X_p1 = X(1:end-1,:);
X_p1 = X_p1(Itrain(1:end-1),:);
X_m1 = X(2:end,:);
X_m1 = X_p1(Itrain(1:end-1),:);

T_m1 = T(1:end-1);
T_m1 = T_m1(Itrain(1:end-1));

tic
Xx = (X_p1')*X_m1;
Tt = (X_p1')*T_m1;
w_mcr     = Xx\Tt;
LIN.Time_mcr = toc();
fprintf('MCR  : %f\n',LIN.Time_mcr);

%w         = X(Itrain(1:end-1),:)\T(Itrain(1:end-1));  % See help mldivide.
tic
w         = X(Itrain,:)\T(Itrain);  % See help mldivide.
LIN.Time = toc();
fprintf('MLDIV: %f\n',LIN.Time);

tic
w         = X(Itrain,:)\T(Itrain);  % See help mldivide.
LIN.Time_norm = toc();
fprintf('NORM : %f\n',LIN.Time_norm);

Ttest     = X(Itest,:)*w;           % Test set predictions using w.
Ttrain    = X(Itrain,:)*w;          % Training set predictions using w.

Etrain    = arv(T(Itrain),Ttrain);
Etest     = arv(T(Itest),Ttest);

MSEtrain  = sqrt((sum(([T(Itrain)-Ttrain]).^2))/length(Itrain));
MSEtest   = sqrt((sum(([T(Itest)-Ttest]).^2))/length(Itest));

LIN.ARVtrain = Etrain;
LIN.ARVtest  = Etest;
LIN.MSEtrain = MSEtrain;
LIN.MSEtest  = MSEtest;
LIN.Ttrain   = Ttrain;
LIN.Ttest    = Ttest;
LIN.Weights  = w;
LIN.Weights_mcr = w_mcr;
LIN.Tpred    = w*X(1:end-1) + w(end);
