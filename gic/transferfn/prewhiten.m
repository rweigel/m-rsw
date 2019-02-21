function [X,a,b] = prewhiten(X,N)

[S,f] = spectrogram(X);
[b,a] = yulewalk(N,f.'/f(end),1./mean(abs(S.')));
X = filter(b,a,X);

end
