X = rand(10,1);
Y = rand(10,1);

block_corrcoef(X,Y,10)-corrcoef(X,Y)

block_corrcoef([X ; X],[Y ; Y],10) - [corrcoef(X,Y) ; corrcoef(X,Y)]

corrcoef_nonflag(X,Y) - corrcoef(X,Y)

X = [X ; NaN];
Y = [Y ; NaN];
corrcoef_nonflag(X,Y) - corrcoef(X(1:end-1),Y(1:end-1))
