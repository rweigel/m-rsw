
figure;
z = cumsum(ones(3,3));
z = cumsum(z,2)
x = [1:3];
y = [1:3];
pcolor2(x,y,z);
xlabel('column number')
ylabel('row number')
colorbar;

z = cumsum(ones(5,5));
x = [1:3,5,8];
y = [1:3,5,8];
pcolor2(x,y,z);
title('Distance from center is 1/2 of separation of previous values');
xlabel('column number')
ylabel('row number')
hold on;
for j = 1:length(y)
for i = 1:length(x)
  plot(x(i),y(j),'*');
end
end