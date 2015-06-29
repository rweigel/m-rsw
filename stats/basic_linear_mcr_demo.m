for i=1:5
  X = ones(100000,1);
  
  [T,X] = time_delay(X,X,10);
  LIN   = basic_linear_mcr(X+rand(size(X)),T);
  Delta_W(i) = mean(LIN.Weights_mcr-LIN.Weights);
  Ratio_T(i) = mean(LIN.Time/LIN.Time_mcr);  
end

break

Y     = [101:200]';
[T,Y] = time_delay(Y,Y,4);
Tpred = basic_linear_mcr(Y,LIN.Weights,'predict');

%starttest;

a = 1.0;
rand1 = [0.9501 0.2311 0.6068 0.4860 0.8913 ...
	 0.7621 0.4565 0.0185 0.8214 0.4447]';
rand2 = [0.6154 0.7919 0.9218 0.7382 0.1763 ...
	 0.4057 0.9355 0.9169 0.4103 0.8936]';
	 
X = ones(10,1) + rand1;
Y = X + a*rand2;

LIN = basic_linear_mcr(X,Y);

fprintf('Reference calc: %.16f\n',LIN.ARVtrain)
fprintf('Reference calc: %.16f\n',LIN.MSEtest)
fprintf('Reference calc: w(1) = %.6f, w(2) = %.6f\n',...
	LIN.Weights(1),LIN.Weights(2))

if (LIN.ARVtrain - arv(Y,LIN.Ttrain) > eps)
  fprintf('Test on arv failed\n')
else
  fprintf('Test on arv ok\n')
end

%endtest;



