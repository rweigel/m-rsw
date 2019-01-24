function [Cxy,fe] = smoothCoherence(x,y,winfn,winopts)

if nargin < 4
    winopts = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in transferfnFD()
N = size(x,1);
f = [0:N/2]'/N;

if ~isempty(winopts)
    [fe,Ne,Ic] = evalfreq(f,'linear',winopts);
else
    [fe,Ne,Ic] = evalfreq(f);
end
% End duplicated code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ftx = fft(x);
ftx = ftx(1:N/2+1,:);
fty = fft(y);
fty = fty(1:N/2+1,:);

for j = 2:length(Ic)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Caution - code below is duplicated in transferfnFD()
    if strmatch(winfn,'parzen','exact')
        W = parzenwin(2*Ne(j)+1); 
        W = W/sum(W);
    end
    if strmatch(winfn,'bartlett','exact')
        W = bartlett(2*Ne(j)+1); 
        W = W/sum(W);
    end
    if strmatch(winfn,'rectangular','exact')
       W = ones(2*Ne(j)+1,1);  
       W = W/sum(W);
    end

    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];

    fa = f(Ic(j)-Ne(j));    
    fb = f(Ic(j)+Ne(j));
    % End duplicated code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for k = 1:size(x,2)
        sxx(k) = sum(W.*(ftx(r,k).*conj(ftx(r,k))));
        syy(k) = sum(W.*(fty(r,k).*conj(fty(r,k))));
        sxy(k) = sum(abs(W.*(ftx(r,k).*conj(fty(r,k)))));
        Cxy(j,k) = sxy(k).^2./(sxx(k)*syy(k));
    end

end