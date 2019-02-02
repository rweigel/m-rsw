function figprep(png,w,h)

if png
    % Open each figure in new window
    set(0,'defaultFigureWindowStyle','normal');
    % Next line needed because when last plot was docked, first plot
    % will be docked in spite of previous line. 
    figure();close; 
    set(0,'defaultFigurePosition', [0 0 w h]);
    set(0,'defaultFigureColor', [1,1,1]);
else
    % Dock figure windows
    set(0,'defaultFigureWindowStyle','docked');
end
