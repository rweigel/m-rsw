clear
Nb = 1000;
N = 1000;
Ax = 1;
Ay = 1;
x   = randn(N,1);
y   = randn(N,1);
errx = Ax*randn(N,1);
erry = Ay*randn(N,1);

po(1) = 1;
po(2) = 2;

z = po(1)*x + po(2)*y;
z = po(1)*(x + 0.1*z + errx) + po(2)*(y + 0.1*z + erry);

pstar = regress(z,[x,y])';
for i = 1:Nb
    I = randi(N,round(0.63*N),1);
    pboot(i,:) = regress(z(I),[x(I),y(I)])';
end

po
pstar
mean(pboot,1)
for i = 1:2
    [pboots,I] = sort(pboot(:,i));
    pl = [mean(pboots),pboots(159),pboots(1000-159)]
end

if (1)
    zhat = pstar(1)*x + pstar(2)*y;
    err  = zhat-z;
    I = randi(N,N,1);
    err = err(I);
    %zhat = zhat+err;
    ccx = abs(cc(x,err));
    ccy = abs(cc(y,err));
    for i = 1:Nb
        I = randi(N,N,1);    
        pboot(i,:) = regress(zhat,[x+sqrt(ccx)*err(I),y+sqrt(ccy)*err(I)])';
    end
end
po
pstar - (pstar-mean(pboot,1))

break

zhat = pstar(1)*x + pstar(2)*y;
err = z - zhat;

for i = 1:Nb
    zhat = pboot(i,1)*x + pboot(i,2)*y;
    I = randi(N,N,1);
    zhat = zhat+err;
    ccx = abs(cc(x,err));
    ccy = abs(cc(y,err));
    I = randi(N,N,1);    
    pboot(i,:) = regress(zhat,[x+sqrt(ccx)*err(I),y+sqrt(ccy)*err(I)])';
end

po
pstar - (pstar-mean(pboot,1))

break

y = 0.1 + 10*x + err;
whos err
err = randn(size(x));
y = 0.1 + 10*x + err;
[b,bint,r,rint,stats] = regress(y,[x,ones(size(x))]);
b
yhat = b(2) + 10*x;
err2 = y-yhat;
yhat = b(2) + b(1)*x;
regress(yhat,x)
regress(yhat,[x,ones(size(x))])
regress(yhat,[x,ones(size(x))],err2)
regress(yhat+err2,[x,ones(size(x))])
yhat = b(2) + b(1)*x;
err2 = yhat-y;
break

po
p



cc(y,yhat)


