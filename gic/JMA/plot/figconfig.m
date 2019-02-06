function figconfig(lh,lo)

set(0,'DefaultAxesFontSize',12);
legend boxoff

set(lh,'FontSize',10); % Legend

if nargin == 2
    %set(lh,'FontSize',12); % Legend
    
    all1 = 1;
    for i = 1:length(lo)
        if lo(i).LineWidth ~= 1
            all1 = 0;
            break
        end
    end
    % If all linewidths = 1
    if all1 == 1
        set(lo,'LineWidth',2);
    end
end

set(gcf, 'PaperSize', [6.25 3.5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 3.5]);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 3.5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 3.5]);

%set(gcf, 'renderer', 'painters');

if 0 && png %|| exist('nodock','var')
    pbaspect([3,1,1]);
    set(0,'DefaultAxesFontSize',16);
    set(gcf,'position',[0 0 1200 400]);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperSize',[16.7,5.5])
end
