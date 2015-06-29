function err = errfn(x)

global Z;
global f;
global fmax;
global hmem;

if (length(x) == 1)
    s = x;
    h = [];
else
    s = x(1:(length(x)+1)/2);
    h = x((length(x)+1)/2+1:end);
end
C = zplanewave(s,h,f);

I = find(f >= fmax);
Zr = Z(1:I(1));
Cr = C(1:I(1));

%Zm = log10(sqrt(real(abs(Zr))));
%Cm = log10(sqrt(real(abs(Cr))));
%Zm = (sqrt(real(abs(Zr))));
%Cm = (sqrt(real(abs(Cr))));

Zm = Zr;
Cm = Cr;

if (any(s < 0)) || any(h < 0)
    err = Inf;
else
    err = sum(abs(Zm-Cm));    
    hm = ifft([0,C,fliplr(conj(C))]);
    err = mse(hmem,hm(1:end-1)');
end
%Zm = (1e3*Zr.*conj(Zr));
%Cm = (Cr.*conj(Cr));


