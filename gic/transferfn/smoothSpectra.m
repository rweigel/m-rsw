function S = smoothSpectra(B,winfn,winopts)

if nargin < 3
    winopts = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in transferfnFD()
N = size(B,1);
f = [0:N/2]'/N;

if ~isempty(winopts)
    [fe,Ne,Ic] = evalfreq(f,'linear',winopts);
else
    [fe,Ne,Ic] = evalfreq(f);
end
% End duplicated code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ftB = fft(B);
ftB = ftB(1:N/2+1,:);

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

    for v = 1:size(ftB,2)
        S(j,v) = sum(W.*(ftB(r,1).*conj(ftB(r,1))));
    end

end