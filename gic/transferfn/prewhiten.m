function [X,a,b] = prewhiten(X,N)

rmpath('../../stats'); % So native spectrogram is used.
[S,f] = spectrogram(X);
[b,a] = yulewalk(N,f.'/f(end),1./mean(abs(S.')));
X = filter(b,a,X);
addpath('../../stats');

end
