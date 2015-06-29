%Large example
%load /home/weigel/svn-pending/papers/2009_Density_RC/mat/main_gethires2_G_S.mat
%[T,X] = time_delayF(G(:,1),S(:,1),240,0,60);

%addpath('~/svn/m-rsw/time');

x    = [1:10]';
t    = x;
x(1) = NaN;
%x(7) = NaN;

if (0)
[T,X] = time_delay(t,x,2,0,2);
Ig = find( (isnan(sum([X,T],2)) == 0) );
[T,X]
T = T(Ig);
X = X(Ig,:);
[T,X]

[T,X] = time_delayF(t,x,2,0,2);
[T,X]
break
end

if (0)
[T,X] = time_delay(t,x,0,0,2);
Ig = find( (isnan(sum([X,T],2)) == 0) );
T = T(Ig);
X = X(Ig,:);
[T,X]

[T,X] = time_delayF(t,x,0,0,2);
[T,X]
end

if (1)
[T,X] = time_delay(t,x,2,0,2);
Ig = find( (isnan(sum([X,T],2)) == 0) );

[T,X]

T = T(Ig);
X = X(Ig,:);
%[T,X]

[T,X,t] = time_delayF(t,x,2,0,2);
[T,X]
%[T,X,t]
end

