function figurex(h)
% FIGUREX Prevent focus stealing when FIGURE called
% 
%    FIGUREX(h)
%
%    Code is equivalent to
%        figure(1);
%        set(0,'CurrentFigure',1);
%
%    From http://stackoverflow.com/questions/8488758/inhibit-matlab-window-focus-stealing

set(0,'CurrentFigure',h)
