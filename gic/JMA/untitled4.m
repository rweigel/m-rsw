x = (1:10)';
y = 10 - 2*x + randn(10,1); y(10) = 0;
bols = regress(y,[ones(10,1) x])
bmvr = mvregress([ones(10,1) x],y)
brob = robustfit(x,y)
figure(1);clf;
    scatter(x,y)
    hold on
    plot(x,bols(1)+bols(2)*x,'r-');
    plot(x,brob(1)+brob(2)*x,'r-');
    plot(x,bmvr(1)+bmvr(2)*x,'r-');
