pbaspect([3,1,1]);

set(0,'DefaultAxesFontSize',16);

hLegend = findobj(gcf, 'Type', 'Legend');
if ~isempty(hLegend)
    set(lh,'FontSize',16); % Legend
    set(lo,'LineWidth',2); % Legend
end

if png %|| exist('nodock','var')
    set(gcf,'position',[0 0 1200 400]);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperSize',[16.7,5.5])
end
 