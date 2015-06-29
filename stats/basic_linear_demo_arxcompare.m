warning('off','MATLAB:dispatcher:pathWarning')
addpath('../system');
addpath('../time');
addpath('../stats');

% BASIC_LINEAR approach is faster for small N
% ARX takes less memory for large N (? Need to verify)
% Both give similar answers

load basic_linear_demo_arxcompare.mat

N = 1e4;

% Create an input function
u = randn(N,1);

% Create an output that has a known relationship to input u via a known
% impulse response function h:
% y(n) = h(1)*u(n-1) + h(2)*u(n-2) + ... h(N)*u(n-N)
y = filter([0;h],1,u);

% Add some noise
y = y + 0.1*max(abs(y))*randn(N,1);

% Chop off non-steady-state part of input and output
y  = y(length(h)+1:end);
u  = u(length(h)+1:end);

% Throw in a NaN value to demonstrate that basic_linear can handle NaNs
% (arx() requires additional pre-processing).
if ~exist('arx')
  y(500) = NaN;
end

Na = 0;         % The number of acausal coefficients
Nc = length(h); % The number of causal coefficients
Ts = 0;         % How much to shift input wrt to output

tic
% T is the target, X is the input.
% Each row of X contains time delayed values of u
[T,X] = time_delay(y,u,(Nc-1),Ts,Na,'pad');

% Compute model by solving for h in overdetermined set of equations
% T(n)   = X(n-1)*h(1) + X(n-2)*h(2) + ...
% T(n+1) = X(n)*h(1) + X(n-1)*h(2) + ...
% If any row of X contains a NaN, it is omitted from the computation.
LIN   = basic_linear(X,T);
toc;

% Impulse response function using basic_linear() (last element is average)
hbl   = LIN.Weights(1:end-1);

yp = basic_linear(X,LIN.Weights,'predict');
if (exist('arx'))
  tic
  DATA = iddata(y,u,1);
  m = arx(DATA,[Na (Nc-1) (Ts+1)],'Tolerance',0.0001,'MaxIter',100)
  harx = m.b';
  toc
end

figure(1);clf
subplot(2,1,1)
plot(u,'b');grid on;
legend('Input');
subplot(2,1,2)
plot(y,'r','LineWidth',2);hold on;grid on;
plot(yp,'g');grid on;
legend('Output','Predicted output');

figure(2);clf;
plot([0;h],'r','linewidth',4);hold on;grid on;
plot([0;hbl],'g');
if (exist('arx'))
  plot([harx-[0;hbl]],'b');
end
legend('Actual IRF','basic\_linear() IRF','arx()-basic\_linear() IRF');
