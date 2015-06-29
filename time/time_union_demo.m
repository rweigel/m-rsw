clear

X1 = [2003 1 1 0 2 -99;...
      2003 1 1 0 3 -98;...
      2003 1 1 1 4 -97;...
      2003 1 1 10 4 -96];

X2        = X1;
FLAG      = 99999;
%[Xu,Tu]   = time_union3(X1,99999,'hour');
[Xu,Tu]   = time_union3(X1,99999,'min');
[Tu,Xu]
break


X1 = [2003 1 1 0 0 0 -99;...
      2003 1 1 0 2 0 -98;...
      2003 1 1 1 0 0 -97;...
      2003 1 1 10 0 0 -96];

X2        = X1;
FLAG      = 99999;
Xu        = time_union2(X1,99999,'hour');

break
Xu        = time_union({X1,X2},99999,'hour');

whos X1 X2
[X1u,X2u,T] = time_union(X1,X2,99999,'hour');
whos X1u X2u

X2(:,1)   = 2004;

whos X1 X2
[X1u,X2u] = time_union(X1,X2,99999,'min');
whos X1u X2u

X1u(1:10)
a = 365*24*60+1;
X2u(a:a+9)

[X1u,X2u] = time_union(X1,X2,99999,'day');

X1u(1:11)
X2u(366:366+10)

input('Continue');

X1 = [2003 1 1 2 0 0 -99;...
      2003 1 1 1 0 0 -98;...
      2003 1 1 1 0 0 -97;...
      2003 1 1 10 0 0 -96];

X2        = X1;
FLAG      = 99999;
Xu        = time_union({X1,X2},99999,'hour');

whos X1 X2
[X1u,X2u,T] = time_union(X1,X2,99999,'hour');
whos X1u X2u
