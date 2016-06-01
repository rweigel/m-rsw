function [Z,f,H,t,Ep] = transferfnTD(B,E,Nc,Na)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time Domain
if ~exist('Na')
    Na = 0; % The number of acausal coefficients
end
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

[T,Xxy] = time_delay(E(:,1),B(:,2),Nc-1,Ts,Na,'pad');
LINxy   = basic_linear(Xxy,T);
Ep(:,1) = basic_linear(Xxy,LINxy.Weights,'predict');

[T,Xyx] = time_delay(E(:,2),B(:,1),(Nc-1),Ts,Na,'pad');
LINyx   = basic_linear(Xyx,T);
Ep(:,2) = basic_linear(Xyx,LINyx.Weights,'predict');

% Impulse response function using basic_linear() (last element is h0)
%hxx = LIN1.Weights(1:Nc) + LIN1.Weights(Nc+1:end-1);
%hxy = LIN1.Weights(Nc+1:end-1);
%hyx = LIN2.Weights(1:Nc) + LIN2.Weights(Nc+1:end-1);
%hyy = LIN2.Weights(Nc+1:end-1);

hxy = LINxy.Weights(1:end-1) + LINxy.Weights(end);
hyx = LINyx.Weights(1:end-1) + LINyx.Weights(end);

hxy = [0;hxy]; % Zero because Na = 0 -> h(t<=0) = 0.
hyx = [0;hyx];

% Note:
% If Nc is even, Z2H(feBL,ZBL) will not return same H as above.

H(:,1) = zeros(length(hxy),1);
H(:,2) = hxy;
H(:,3) = hyx;
H(:,4) = zeros(length(hxy),1);

% TODO: If Na ~= 0, need to account for in t and in fftshift
t = [-Na:Nc-1]';

% Transfer Function
Z(:,1)  = zeros(length(hxy),1);
Z(:,2)  = fft(hxy);
Z(:,3)  = fft(hyx);
Z(:,4)  = zeros(length(hxy),1);

N       = size(Z,1);
Z       = Z(1:floor(N/2)+1,:);
f       = [0:floor(N/2)]'/N;