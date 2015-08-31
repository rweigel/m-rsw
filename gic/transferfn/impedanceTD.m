function [Z,f,Zxy1,Zyx1,fxy1,fyx1,H,hxy,hyx,Fxy,Fyx] = impedanceTD(B,E,Nc)

for i = 1:size(B,2)
	B(:,i) = B(:,i) - mean(B(:,i));
end
for i = 1:size(E,2)
	E(:,i) = E(:,i) - mean(E(:,i));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time Domain
Na = 0; % The number of acausal coefficients
Ts = 0; % Shift input with respect to output

% T is the output, X is the input.
% Each row of X contains time delayed values of u
% Compute model by solving for H = {h0,h1,...} in overdetermined set
% of equations
% ym(n)   = h0 + u(n-1)*h(1) + u(n-2)*h(2) + ...
% ym(n+1) = h0 + u(n-0)*h(1) + u(n-1)*h(2) + ...
% ...
% If any row above contains a NaN, it is omitted from the computation.
% Solve for Ym = X*H -> H = Ym\U 

[T,Xxy] = time_delay(E(:,2),B(:,1),(Nc-1),Ts,Na,'pad');
LINxy = basic_linear(Xxy,T)
Fxy = basic_linear(Xxy,LINxy.Weights,'predict');

[T,Xyx] = time_delay(E(:,1),B(:,2),(Nc-1),Ts,Na,'pad');
LINyx = basic_linear(Xyx,T)
Fyx = basic_linear(Xyx,LINyx.Weights,'predict');

% Impulse response function using basic_linear() (last element is h0)
hxy = LINxy.Weights(1:end-1) + LINxy.Weights(end);
hyx = LINyx.Weights(1:end-1) + LINyx.Weights(end);
hxy = [0;hxy]; % Zero is because Na = 0 -> h(t<=0) = 0.
hyx = [0;hyx]; % Zero is because Na = 0 -> h(t<=0) = 0.
tyx = [0:length(hyx)-1];

% Transfer Function
Zxy  = fft(hxy);
Zyx  = fft(hyx);
Nxy  = length(Zxy);
Nyx  = length(Zyx);
Zxy1  = Zxy(1:floor(Nxy/2)+1);
Zyx1  = Zyx(1:floor(Nyx/2)+1);

fxy1 = [0:Nxy/2]'/Nxy;
fyx1 = [0:Nyx/2]'/Nyx;

f = fxy1; % Need to change this to be a cell array. 
Z = {};
H = {};
