function X = removeTrend(X,Xt)

Nr = size(X,1)/size(Xt,1);

for i = 1:size(X,2)
    X(:,i) = X(:,i) - repmat(Xt(:,i),Nr,1);
end