function fillbelow(x,y,ymin,c)
%FILLBELOW

if (nargin < 4)
  c = 'black';
end

if (nargin == 2)  
  ymin = y;
  y    = x;
  x    = [1:length(x)]';
end
if (length(x) > size(x,1))
  x = x';
end
if (length(y) > size(y,1))
  y = y';
end
x = [x(1);x;x(end)];
y = [ymin;y;ymin];  

Inan = find(isnan(y)==1);
y(Inan)=ymin;

f = fill(x,y,c);
set(f,'EdgeColor',c);

plot(x(Inan),y(Inan),'x'); % Place x where value was NaN