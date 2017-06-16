function [pa,fe] = logsmooth(f,x)
    
[fe,Ne,Ic] = evalfreq(f);
for j = 1:length(Ic)
    W = parzenwin(2*Ne(j)+1); 
    W = W/sum(W);
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];      
    pa(j,1) = sum(abs(W.*x(r,1)));
end
