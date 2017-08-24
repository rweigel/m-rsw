function [Z,fe,H,t,Ep] = transferfnFD(B,E,method,winfn,winopts)

if nargin < 6
    verbose = 0;
end
if (nargin < 3)
    method = 1;
end
if (nargin < 4)
    winfn = 'rectangular';
end
if (nargin < 5)
    winopts = [];
end

N = size(B,1);
f = [0:N/2]'/N;

ftB = fft(B);
ftE = fft(E);
ftB = ftB(1:N/2+1,:);
ftE = ftE(1:N/2+1,:);

if ~isempty(winopts)
    df = winopts;
    % Smooth in frequency domain with rectangular window.
    Ic = [df+1:df:length(f)-df]; % Indicies of center points
    for j = 1:length(Ic)
        fe(j) = f(Ic(j)); % Evaluation frequency
        Ne(j) = df;       % Number of points to right and left used in window.
    end

    % Add zero frequency.
    fe = [0,fe]';
    Ne = [0,Ne]';
    Ic = [1,Ic]';
else
    [fe,Ne,Ic] = evalfreq(f);
end

for j = 1:length(Ic)

    if strmatch(winfn,'parzen')
        W = parzenwin(2*Ne(j)+1); 
        W = W/sum(W);
    end
    if strmatch(winfn,'bartlett')
        W = bartlett(2*Ne(j)+1); 
        W = W/sum(W);
    end
    if strmatch(winfn,'rectangular')
       W = ones(2*Ne(j)+1,1);  
       W = W/sum(W);
    end
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];  

    fa = f(Ic(j)-Ne(j));    
    fb = f(Ic(j)+Ne(j));
    if verbose
        fprintf('Window at f = %.8f has %d points; fl = %.8f fh = %.8f\n',...
                fe(j),length(r),fa,fb)
    end
    
    Zxy1(j) = sum(W.*ftE(r,1).*conj(ftB(r,2)))/sum(W.*ftB(r,2).*conj(ftB(r,2)));
    Zyx1(j) = sum(W.*ftE(r,2).*conj(ftB(r,1)))/sum(W.*ftB(r,1).*conj(ftB(r,1)));

    BxBx(j) = sum(W.*ftB(r,1).*conj(ftB(r,1))); 
    ByBx(j) = sum(W.*ftB(r,2).*conj(ftB(r,1))); 
    ExBx(j) = sum(W.*ftE(r,1).*conj(ftB(r,1))); 
    EyBx(j) = sum(W.*ftE(r,2).*conj(ftB(r,1))); 

    ByBy(j) = sum(W.*ftB(r,2).*conj(ftB(r,2)));
    ExBy(j) = sum(W.*ftE(r,1).*conj(ftB(r,2))); 
    EyBy(j) = sum(W.*ftE(r,2).*conj(ftB(r,2))); 

    ExEx(j) = sum(W.*ftE(r,1).*conj(ftE(r,1)));
    EyEx(j) = sum(W.*ftE(r,2).*conj(ftE(r,1)));

    EyEy(j) = sum(W.*ftE(r,2).*conj(ftE(r,2)));

    BxBy(j) = sum(W.*ftB(r,1).*conj(ftB(r,2)));

    DET(j) =  BxBx(j)*ByBy(j) - BxBy(j)*ByBx(j);
    Zxx(j) = (ExBx(j)*ByBy(j) - ExBy(j)*ByBx(j))/DET(j);
    Zxy(j) = (ExBy(j)*BxBx(j) - ExBx(j)*BxBy(j))/DET(j);
    Zyx(j) = (EyBx(j)*ByBy(j) - EyBy(j)*ByBx(j))/DET(j);
    Zyy(j) = (EyBy(j)*BxBx(j) - EyBx(j)*BxBy(j))/DET(j);
end

% .' is non-conjugate transpose

if (method == 1)
    Z(:,1) = zeros(length(Zxy1),1);
    Z(:,2) = Zxy1.';
    Z(:,3) = Zyx1.';
    Z(:,4) = zeros(length(Zxy1),1);
end

if (method == 2)
    Z(:,1) = Zxx.';
    Z(:,2) = Zxy.';
    Z(:,3) = Zyx.';
    Z(:,4) = Zyy.';
end

I = find(isinf(Z(1,:)) == 1 | isnan(Z(1,:)) == 1);
Z(1,I) = 0;

H = Z2H(fe,Z,f);
H = fftshift(H,1);
N = (size(H,1)-1)/2;
t = [-N:N]';

Ep = real(Zpredict(fe,Z,B));
