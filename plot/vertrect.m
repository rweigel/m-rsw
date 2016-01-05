function h = vertrect(X,c)
%VERTRECT  Plot vertical rectangle.
%
%    h = VERTRECT(X) Plots a vertical rectangle with left/right boundaries
%    given by first/second column of each row in X.
%
%    h = VERTRECT(X,c) colors the rectangle by rgb values in c
%    (default is c = [0.75 0.75 0.75]).
%
%    Example: plot(rand(10)); vertrect([1,2;4,6])
%
%    See also VERTLINE.   

if ~exist('c')
	c = [0.75 0.75 0.75];
end

h_1  = gca();
xlim = get(h_1, 'XLim');
ylim = get(h_1, 'YLim');

I1 = find( X(:,1) >= xlim(1) & X(:,1) <= xlim(2) );
X1 = X(I1,1);
X2 = X(I1,2);

ih = ishold();
if ~ih,hold on,end

if (1)
	Xm = [X1,X2,X2,X1];
	r  = length(X1);
	Ym = [repmat(ylim(1),r,1),repmat(ylim(1),r,1),...
		  repmat(ylim(2),r,1),repmat(ylim(2),r,1)];
	h = fill(Xm',Ym',c,'EdgeAlpha',0);
end

if (0)
	for i = 1:length(X1)
		x = [X1(i),X2(i),X2(i),X1(i)];
		y = [ylim(1),ylim(1),ylim(2),ylim(2)];
		h(i) = fill(x,y,c);
		set(h(i),'EdgeAlpha',0);
	end
end

if ~ih,hold off,end
