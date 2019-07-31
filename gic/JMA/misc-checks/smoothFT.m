function [S,fe] = smoothFT(B,opts)

if nargin > 2
    winfn = opts.fd.window.function;
else
    winfn = @parzenwin;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in transferfnFD()
N = size(B,1);
f = [0:N/2]'/N;

[fe,Ne,Ic] = evalfreq(f);
if nargin > 1
    if strmatch(opts.fd.evalfreq.method,'linear','exact')
        [fe,Ne,Ic] = evalfreq(f,'linear',opts.fd.evalfreq.options);
    elseif strmatch(opts.fd.evalfreq.method,'logarithmic','exact')
        [fe,Ne,Ic] = evalfreq(f);
    end
end
% End duplicated code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ftB = fft(B);
ftB = ftB(1:floor(N/2),:);

for j = 2:length(Ic)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Caution - code below is duplicated in transferfnFD()
    W = winfn(2*Ne(j)+1);
    W = W/sum(W);
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];
    % End duplicated code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for k = 1:size(ftB,2)
        S(j,k) = sum(W.*real(ftB(r,k))) + sqrt(-1)*sum(W.*imag(ftB(r,k)));
    end

end