function h = pcolor2(x,y,z)
%PCOLOR2 Revised version of PCOLOR for visualizing matrices
%    
%    PCOLOR2(x,y,z) Puts colored square with center at x and y
%    and plots a square for all values of z.  If x or y has repeated
%    values, the z value of the last occurence is used.
%  
%    z = cumsum(ones(3,3));
%    x = [1:3];
%    y = [1:3];
%    pcolor2(x,y,z) 
%    Will have each colored square have its center at integer x and y.
%    x-axis is the column number of z
%    y-axis is the row number of z
% 
%    PCOLOR2(z) assumes 
%    x = [1:size(z,2)]
%    y = [1:size(z,1)]'
%
%  See PCOLOR2_DEMO.  

if (nargin == 1)
  z = x;
  x = [1:size(z,2)];
  y = [1:size(z,1)]';
end

if (nargin == 2)
  error('Either one or three inputs are required');
end

[xu,Ix] = unique(x);
[yu,Iy] = unique(y);
if (length(Iy) < length(y))
  fprintf('Warning: pcolor2 - y values are not unique. Using last value.\n');
  [I,Iyr] = repeats(y);
  Iyr = sort(Iyr);
  b = min(length(Iyr),10);
  fprintf('pcolor2: First %d (of %d) non-unique values\n',b,length(I));
  for i = 1:b
    fprintf('pcolor2: y(%d) = %f, z(%d) = %f\n',Iyr(i),y(Iyr(i)),...
	    Iyr(i),z(Iyr(i)));
  end
  y = yu;
  z = z(Iy,:);
end
if (length(Ix) < length(x))
  fprintf('Warning: pcolor2 - x values are not unique.\n');
  fprintf('         Using UNIQUE to make unique.\n');
  I = repeats(x);
  b = min(length(I),10);
  fprintf('pcolor2: First %d (of %d) non-unique values\n',b,length(I));
  for i = 1:b
    fprintf('pcolor2: x(%d) = %f, z(%d) = %f\n',I(i),x(I(i)),I(i),z(I(i)));
  end
  x = xu;
  z = z(Ix,:);
end

if (length(x) == 1)
  x = [x-2,x,x+2];
  z = [repmat(NaN,size(z,1),1),z,repmat(NaN,size(z,1),1)];
  fprintf('pcolor2: Warning: only one x value.  Assuming boundaries at +/- 1\n');
end

if (length(y) == 1)
  y = [y-2;y;y+2];
  z = [repmat(NaN,1,size(z,2));z;repmat(NaN,1,size(z,2))];
  fprintf('pcolor2: Warning: only one y value.  Assuming boundaries at +/- 1\n');
end

if (0)
if (size(x,2) ~= size(z,2))
  x = x';
end
if (size(y,1) ~= size(z,1))
  y = y';
end
end

z = [z,z(:,end)];
z = [z;z(end,:)];

dx       = (x(2)-x(1))/2;
x(end+1) = x(end)+2*dx;
x        = x-dx;

if length(unique(diff(y))) > 1
  fprintf('pcolor2: Warning: dy is not uniform.\n');
end
dy       = (y(2)-y(1))/2;
y(end+1) = y(end)+2*dy;
y        = y-dy;

h = pcolor(x,y,z);
set(gca(),'layer','top');
if (length(x) > 100) || length(y) > 100
  set(h,'EdgeColor','none');
end

