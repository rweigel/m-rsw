function X = prewhiten(X)

X = diff(X);
X(end+1,:) = 0*X(end,:);
