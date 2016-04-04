load ../data/iris/CON20/data/CON20-natural-cleaned.mat
Xn = D;
load ../data/iris/CON20/data/CON20-counts-cleaned.mat
Xc = D;

t = [0:size(X,1)-1]'/86400;
sum(isnan(Xc))
sum(isnan(Xn))
figure(1);clf
  plot(t,Xn,'b');
  hold on;
  plot(t,1e-11*Xc,'r');
  legend('Natural [nT]','Counts/10^{11}');
