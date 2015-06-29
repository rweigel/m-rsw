clear;
% Value for uncorrelated series seems to be about 1.81 independent of
% distribution of series (randn vs. rand).  
% For 2-d, value is about 1.5

s = 10; % m and m2 are about 1.81
s = 1;  % m = 1.55, m2 = 1.81
K = [100,200,400,1000,2000];

for k = 1:length(K)
for i = 1:2000
  x = s*randn(2000,1);
  y = s*randn(2000,1);
  m(i,k)  = lsd(x,y,K(k));
  m2(i,k) = lsd([x,x],[y,y],K(k));
end
end
mean(m,1)
mean(m2,1)

