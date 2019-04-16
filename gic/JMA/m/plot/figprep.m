function figprep(png,w,h)

set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultLegendInterpreter','latex')
set(0,'DefaultAxesTickLabelInterpreter','latex');

if png
    %close all
    % Open each figure in new window
    set(0,'defaultFigureWindowStyle','normal');
    % Next line needed because when last plot was docked, first plot
    % will be docked in spite of previous line. 
    % Otherwise first is docked if last state undock may need to change to close all
    set(0,'defaultFigurePosition', [0 0 w h]);
    set(0,'defaultFigureColor', [1,1,1]);
else
    % Dock figure windows
    %figure();close all; % Otherwise first is undocked if last state docked
    set(0,'defaultFigureWindowStyle','docked');
end
