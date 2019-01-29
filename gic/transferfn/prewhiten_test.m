
%function X = prewhiten(X)

X = rand(1000,1);
X = E(:,1);

% Method 1
Xw = prewhiten(X);
[Sw1,f] = spectrogram(Xw);

loglog(f,mean(abs(S),2));
hold on;
loglog(f,mean(abs(Sw),2));
legend('Original','Whitened');
