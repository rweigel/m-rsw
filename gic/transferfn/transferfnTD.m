function [Z,f,H,t,Ep] = transferfnTD(B,E,Nc,Na)

if ~exist('Na')
    Na = 0; % The number of acausal coefficients
end
Ts = 0; % Shift input with respect to output (not implemented for non-zero)

% Predict E given B
% Ex = ZxxBx + ZxyBy
% Ey = ZyxBx + ZyyBy
[T,Xxx] = time_delay(E(:,1),B(:,1),Nc,Ts,Na,'pad');
[T,Xxy] = time_delay(E(:,1),B(:,2),Nc,Ts,Na,'pad');
LINr1   = basic_linear([Xxx,Xxy],T); % r1 = Row 1 of transfer function
Ep(:,1) = basic_linear([Xxx,Xxy],LINr1.Weights,'predict');

if (size(E,2) == 2)
    [T,Xyx] = time_delay(E(:,2),B(:,1),Nc,Ts,Na,'pad');
    [T,Xyy] = time_delay(E(:,2),B(:,2),Nc,Ts,Na,'pad');
    LINr2   = basic_linear([Xyx,Xyy],T); % r2 = Row 2 of transfer function
    Ep(:,2) = basic_linear([Xyx,Xyy],LINr2.Weights,'predict');
end

t = [-Na+1:Nc]';

hxx = LINr1.Weights(1:Nc+Na);
hxy = LINr1.Weights(Nc+Na+1:end-1);

if (size(E,2) == 2)
    hyx = LINr2.Weights(1:Nc+Na);
    hyy = LINr2.Weights(Nc+Na+1:end-1);
end

if (Na == 0)
    hxx = [0;hxx]; % Zero because Na = 0 -> h(t<=0) = 0.
    hxy = [0;hxy];
    if (size(E,2) == 2)
        hyx = [0;hyx];
        hyy = [0;hyy];
    end
    t = [0;t];
end

H(:,1) = hxx;
H(:,2) = hxy;
if (size(E,2) == 2)
    H(:,3) = hyx;
    H(:,4) = hyy;
end

% Transfer Function
Z(:,1)  = fft(hxx);
Z(:,2)  = fft(hxy);

if (size(E,2) == 2)
    Z(:,3)  = fft(hyx);
    Z(:,4)  = fft(hyy);
end

N = size(Z,1);
Z = Z(1:floor(N/2)+1,:);
f = [0:floor(N/2)]'/N;