function Xs = block_smooth(X,L)
%BLOCK_SMOOTH

X = block_mean(X,L);
Xs = [];

for i = 1:size(X,1)
  Xs = [Xs;repmat(X(i,:),L,1)];
end
  