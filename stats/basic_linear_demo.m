warning('off','MATLAB:dispatcher:pathWarning')
addpath('~/svn/m-rsw/system');
addpath('~/svn/m-rsw/time');
addpath('~/svn/m-rsw/stats');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test NaN removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X    = [1:10]';
X(4) = NaN;

[T,X] = time_delay(X,X,1);
LIN   = basic_linear(X,T);
if (LIN.ARVtrain > 1e-30) % Last try was 4e-31
  fprintf('Test on NaN removal failed.\n')
else
  fprintf('Test on NaN removal passed.\n')
end

% Use computed weights on new data
Y     = [101:200]';
Y(1:20) = NaN;
[T,Y] = time_delay(Y,Y,1);
Tpred = basic_linear(Y,LIN.Weights,'predict');
if (LIN.ARVtrain - arv(Y,Tpred) > eps)
  fprintf('Test on NaN removal failed.\n')
else
  fprintf('Test on Nan removal passed.\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X     = [1:100]';
[T,X] = time_delay(X,X,4);
LIN   = basic_linear(X,T);

Y     = [101:200]';
[T,X] = time_delay(Y,Y,4);
Tpred = basic_linear(X,LIN.Weights,'predict');
if (LIN.ARVtrain - arv(T,Tpred) > eps)
  fprintf('Test on basic failed.\n')
else
  fprintf('Test on basic passed.\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do reference calculation
a = 1.0;
rand1 = [0.9501 0.2311 0.6068 0.4860 0.8913 ...
	 0.7621 0.4565 0.0185 0.8214 0.4447]';
rand2 = [0.6154 0.7919 0.9218 0.7382 0.1763 ...
	 0.4057 0.9355 0.9169 0.4103 0.8936]';
	 
X = ones(10,1) + rand1;
Y = X + a*rand2;

LIN = basic_linear(X,Y);

fprintf('Reference calc: %.16f\n',LIN.ARVtrain)
fprintf('Reference calc: %.16f\n',LIN.MSEtest)
fprintf('Reference calc: w(1) = %.6f, w(2) = %.6f\n',...
	LIN.Weights(1),LIN.Weights(2))

if (LIN.ARVtrain - arv(Y,LIN.Ttrain) > eps)
  fprintf('Test on arv failed.\n')
else
  fprintf('Test on arv passed.\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

