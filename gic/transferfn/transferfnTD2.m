function [Z,f,H,t,Ep] = transferfnTD2(B,E,Nc,Na)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time Domain
if ~exist('Na')
    Na = 0; % The number of acausal coefficients
end
Ts = 0; % Shift input with respect to output

% Ordering Leads to rank deficient matrix.
% http://www.cs.yale.edu/publications/techreports/tr398.pdf
%[T,X1]  = time_delay(E(:,1),B,Nc-1,Ts,Na,'pad');
%LIN1    = basic_linear(X1,T);
%[T,X2]  = time_delay(E(:,2),B,Nc-1,Ts,Na,'pad');
%LIN2    = basic_linear(X2,T);
% Impulse response function using basic_linear() (last element is h0)
%hxx = LIN1.Weights(1:2:2*(Nc-1)-1);
%hxy = LIN1.Weights(2:2:2*(Nc-1));
%hyx = LIN2.Weights(2:2:2*(Nc-1));
%hyy = LIN2.Weights(1:2:2*(Nc-1)-1);

[T,X11] = time_delay(E(:,1),B(:,1),Nc-1,Ts,Na,'pad');
[T,X12] = time_delay(E(:,1),B(:,2),Nc-1,Ts,Na,'pad');
LIN1    = basic_linear([X11,X12],T);
Ep(:,2) = basic_linear([X11,X12],LIN1.Weights,'predict');

[T,X21] = time_delay(E(:,2),B(:,1),Nc-1,Ts,Na,'pad');
[T,X22] = time_delay(E(:,2),B(:,2),Nc-1,Ts,Na,'pad');
LIN2    = basic_linear([X21,X22],T);
Ep(:,1) = basic_linear([X21,X22],LIN2.Weights,'predict');

% Impulse response function using basic_linear() (last element is h0)
hxx = LIN1.Weights(1:Nc-1);
hxy = LIN1.Weights(Nc:end-1);
hyx = LIN2.Weights(1:Nc-1);
hyy = LIN2.Weights(Nc:end-1);

% Note:
% If Nc is even, Z2H(feBL,ZBL) will not return same H as above.

% Zero because Na = 0 -> h(t<=0) = 0.
H(:,1) = [0;hxx];
H(:,2) = [0;hxy];
H(:,3) = [0;hyx];
H(:,4) = [0;hyy];

% TODO: If Na ~= 0, need to account for in t and in fftshift
t = [0:Nc-1]';

% Transfer Function
Z = fft(H);
N = size(Z,1);
Z = Z(1:floor(N/2)+1,:);
f = [0:floor(N/2)]'/N;