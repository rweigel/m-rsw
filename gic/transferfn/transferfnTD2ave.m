function [Z,f,H,t,Ep] = transferfnTD2ave(B,E,Nc,Na,Ns)

k = 1;
n = floor(size(B,1)/Ns);
a = 1;
b = Ns;
for i = 1:n
    Br{i} = B(a:b,:);
    Er{i} = E(a:b,:);
    a = b+1;
    b = (i+1)*Ns;
end

parfor i = 1:n % (no speed-up?)
%for i = 1:n
    fprintf('Computing segment %d/%d\n',i,n);
    [Z,f,H,t,Ep] = transferfnTD2(Br{i},Er{i},Nc,Na);
    Hc{i} = H;
    T{i} = t;
end

for i = 1:length(Hc)
    if (i == 1)
	Ha = Hc{i};
    else
	Ha = Ha + Hc{i};
    end
end

H = Ha/n;
t = T{1};
Ep = Hpredict(t,H,B);

% TODO: If Na ~= 0, need to account for in t and in fftshift
t = [-Na:Nc-1]';

% Transfer Function
Z(:,1)  = zeros(size(H,1),1);
Z(:,2)  = fft(H(:,2));
Z(:,3)  = fft(H(:,3));
Z(:,4)  = zeros(size(H,1),1);

N       = size(Z,1);
Z       = Z(1:floor(N/2)+1,:);
f       = [0:floor(N/2)]'/N;
