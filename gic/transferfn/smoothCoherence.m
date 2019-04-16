function [Cxy,fe] = smoothCoherence(x,y,opts)

if nargin > 2
    winfn = opts.fd.window.function;
else
    winfn = @parzenwin;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in transferfnFD()
N = size(x,1);
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

ftx = fft(x);
ftx = ftx(1:floor(N/2)+1,:);
fty = fft(y);
fty = fty(1:floor(N/2)+1,:);

for j = 2:length(Ic)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Caution - code below is duplicated in transferfnFD()
    W = winfn(2*Ne(j)+1);
    W = W/sum(W);
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];
    % End duplicated code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for k = 1:size(x,2)
        sxx = sum(W.*(ftx(r,k).*conj(ftx(r,k))));
        syy = sum(W.*(fty(r,k).*conj(fty(r,k))));
        sxy = sum(abs(W.*(ftx(r,k).*conj(fty(r,k)))));
        Cxy(j,k) = sxy.^2./(sxx*syy);
    end

end