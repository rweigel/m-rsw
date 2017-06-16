function [ccv,pev,ep,f] = computeMetrics(E,Ep,ppd,Tl,Th);

%Tl = 9.1;
%Th = 18725;

Ep = filterE(Ep,Tl,Th);

pev(1) = pe_nonflag(E(:,1),Ep(:,1));
pev(2) = pe_nonflag(E(:,2),Ep(:,2));
tmp    = corrcoef(E(:,1),Ep(:,1),'rows','pairwise');
ccv(1) = tmp(2);
tmp    = corrcoef(E(:,2),Ep(:,2),'rows','pairwise');
ccv(2) = tmp(2);

t = [0:size(E,1)-1]';
% For testing scale 
%ex = sin(2*pi*t/1e3);
%ex = [ex,ex];
%err = E-Ep+ex;
err = E-Ep;

N = size(err,1);
f = [0:N/2]'/N;

if (0)
pEp = abs(fft(Ep));
pE  = abs(fft(E));
pE  = pE(1:end/2,:);
pEp = pEp(1:end/2,:);

I = find(1./f > Tl & 1./f < Th);
r = log(pE(I,:))
end

if (1)
fterr = 2*fft(err)/N;
[fe,Ne,Ic] = evalfreq(f);
for j = 1:length(Ic)
    W = parzenwin(2*Ne(j)+1); 
    W = W/sum(W);
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];      
    pa(j,1) = sum(abs(W.*fterr(r,1)));
    pa(j,2) = sum(abs(W.*fterr(r,2)));
end
f  = fe(2:end);
ep = pa(2:end,:);
end

if (0)
for i = 1:2
    tmp = err(1:ppd*floor(size(err,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f  = [0:NA/2]'/NA;
f  = f(2:end);
ep = pa(2:NA/2+1,:);
end

    