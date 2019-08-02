clear;
load('../mat/main_options-1-v1-o0.mat','GE','GE_avg','GEo');

sf = (180/pi);

Ex = [];
Ey = [];
G  = [];
for d = 1:size(GE.In,3)
    Ex = [Ex;GE.In(:,1,d)];
    Ey = [Ey;GE.In(:,2,d)];
    G  = [G;GE.Out(:,2,d)];
end

figure(1);clf
    aE = sf*atan2(Ex,Ey);
    hist(aE,100)
    ylabel('\# in bin');
    xlabel('Angle relative to East; 90$^{\circ}$ = North');
    grid on;
    set(gca,'XTick',[-180:30:180]);

orient tall;    
print -dpdf eangle.pdf
