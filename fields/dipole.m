clear

d = 1;
r = [1];
theta = [0:45:335];
x1 = r.*cosd(theta)-d;
x2 = r.*cosd(theta)+d;
y = r.*sind(theta);
x = [x1,x2];
y = [y,y];
 
r1  = (x-d).^2 + y.^2;
r2  = (x+d).^2 + y.^2;
Ex1 = (x-d)./r1.^(3/2);
Ex2 = (x+d)./r2.^(3/2);

Ey1 = (y)./r1.^(3/2);
Ey2 = (y)./r2.^(3/2);

figure(1);clf
    plot(x,y,'k.','MarkerSize',3);
    hold on;axis equal

    q = quiver(x,y,Ex1,Ey1);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    q = quiver(x,y,Ex2,Ey2);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    t = text(d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'FontSize',18);
    set(t,'Color','blue');

    t = text(-d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'Color','red');
    set(t,'FontSize',18);

    set(gca,'visible','off');

copyobj(gcf,0);
    plot(x,y,'k.','MarkerSize',3);
    hold on;axis equal

    q = quiver(x,y,Ex1+Ex2,Ey1+Ey2);
    set(q,'Color',[0,0,0]);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    set(gca,'visible','off');

figure(3);clf
    plot(x,y,'k.','MarkerSize',3);
    hold on;
    axis equal

    q = quiver(x,y,Ex1+Ex2,Ey1+Ey2);
    set(q,'Color',[0,0,0]);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    t = text(d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'Color','blue');
    set(t,'FontSize',18);

    t = text(-d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'FontSize',18);
    set(t,'Color','red');

    set(gca,'visible','off');

[X,Y] = meshgrid([-2.1:0.1:2.1],[-2.1:0.1:2.1]);
r1 = (X-d).^2 + Y.^2;
r2 = (X+d).^2 + Y.^2;
V1 = 1./r1;
V2 = 1./r2;
figure(4);clf;
    [c,h] = contour(X,Y,V1+V2,[1, 2, 4]);
    clabel(c,h,'LabelSpacing',200);
    axis equal
    
    t = text(d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'FontSize',18);
    set(t,'Color','blue');

    t = text(-d,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'Color','red');
    set(t,'FontSize',18);
    axis([-2.1,2.1,-2.1,2.1]);
    grid on;
    %set(gca,'visible','off');
    