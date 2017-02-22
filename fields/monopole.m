clear

r = [1,2];
theta = [0:45:335];
for i = 1:length(r)
    Ex(i,:) = cosd(theta)./r(i).^2;
    Ey(i,:) = sind(theta)./r(i).^2;

    x(i,:) = r(i).*cosd(theta);
    y(i,:) = r(i).*sind(theta);
end

figure(1);clf
    plot(x,y,'k.','MarkerSize',10);
    hold on;axis equal;

    q = quiver(x,y,Ex,Ey);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    viscircles([0,0;0,0],r,'EdgeColor','black','LineWidth',1);
    t = text(0,0,'+');
    set(t,'HorizontalAlignment','Center');
    set(t,'FontSize',24);

    t = text(r(1).*cosd(45+45/2),r(1)*sind(45+45/2),'2 J/C');
    set(t,'FontSize',24);
    set(t,'VerticalAlignment','bottom')

    t = text(r(2).*cosd(45+45/2),r(2)*sind(45+45/2),'1 J/C');
    set(t,'FontSize',24);
    set(t,'VerticalAlignment','bottom')

    t = text(0.1,-1.5,'1 N/C');
    set(t,'FontSize',24);
    set(t,'Color','Blue');
    set(t,'HorizontalAlignment','left')

    t = text(0.1,-2.25,'4 N/C');
    set(t,'FontSize',24);
    set(t,'Color','Blue');
    set(t,'HorizontalAlignment','left')


    t = plot(r(2).*cosd(90+45/2),r(2)*sind(90+45/2),'k.','MarkerSize',30);
    t = text(r(2).*cosd(90+45/2),r(2)*sind(90+45/2),'B');
    set(t,'HorizontalAlignment','Center');
    set(t,'VerticalAlignment','bottom')
    set(t,'FontSize',24);

    t = plot(r(1).*cosd(90+45/2),r(1)*sind(90+45/2),'k.','MarkerSize',30);    
    t = text(r(1).*cosd(90+45/2),r(1)*sind(90+45/2),'A');
    set(t,'HorizontalAlignment','Center');
    set(t,'VerticalAlignment','bottom')
    set(t,'FontSize',24);
    
    savefig('monoplole_positive');

figure(2);clf
    plot(x,y,'k.','MarkerSize',10);
    hold on;axis equal;

    q = quiver(x,y,-Ex,-Ey);
    set(q,'AutoScaleFactor',0.4);
    set(q,'MaxHeadSize',0.1)
    set(q,'LineWidth',2);

    viscircles([0,0;0,0],r,'EdgeColor','black','LineWidth',1);
    t = text(0,0,'-');
    set(t,'HorizontalAlignment','Center');
    set(t,'FontSize',24);

    t = text(r(1).*cosd(45+45/2),r(1)*sind(45+45/2),'-2 J/C');
    set(t,'FontSize',24);
    set(t,'VerticalAlignment','bottom')

    t = text(r(2).*cosd(45+45/2),r(2)*sind(45+45/2),'-1 J/C');
    set(t,'FontSize',24);
    set(t,'VerticalAlignment','bottom')

    t = text(0.1,-1.0,'1 N/C');
    set(t,'FontSize',24);
    set(t,'Color','Blue');
    set(t,'HorizontalAlignment','left')

    t = text(0.1,-1.77,'4 N/C');
    set(t,'FontSize',24);
    set(t,'Color','Blue');
    set(t,'HorizontalAlignment','left')


    t = plot(r(2).*cosd(90+45/2),r(2)*sind(90+45/2),'k.','MarkerSize',30);
    t = text(r(2).*cosd(90+45/2),r(2)*sind(90+45/2),'B');
    set(t,'HorizontalAlignment','Center');
    set(t,'VerticalAlignment','bottom')
    set(t,'FontSize',24);

    t = plot(r(1).*cosd(90+45/2),r(1)*sind(90+45/2),'k.','MarkerSize',30);    
    t = text(r(1).*cosd(90+45/2),r(1)*sind(90+45/2),'A');
    set(t,'HorizontalAlignment','Center');
    set(t,'VerticalAlignment','bottom')
    set(t,'FontSize',24);
    
    savefig('monoplole_negative');
    