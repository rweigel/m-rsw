pbaspect([3,1,1]);

set(0,'DefaultAxesFontSize',16);
set(lh,'FontSize',16); % Legend
set(lo,'LineWidth',2); % Legend
set(gcf,'position',[0 0 1200 400]);

if png || exist('nodock','var')
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperSize',[16.7,5.5])
end
 