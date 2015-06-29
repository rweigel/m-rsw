function h2 = vertline(X,lc,lw,lsz)
%VERTLINE  Plot vertical lines on current figure.
%
%    h = VERTLINE(X) Plots a vertical line at the positions in the
%    vector X on the current graph.  For 2D plots only.
%
%    h = VERTLINE(X,lc,lw,ls) uses the line color specifed by the string 
%    lc, with width of lw, and style ls.
%
%    Default of vertline(X) is vertline(X,'r',1,'--').
%
%    See also PLOTFORMAT.   

if (size(X,1) == 1)
  X = X';
end
  
if ~exist('lc'),lc = 'r';,end;
if ~exist('lw'),lw = 1;,end;
if ~exist('lsz'),lsz = '--';,end;


h_1  = gca;                         % Get the current axes handle
xlim = get( h_1, 'XLim' );          % Get the axes limits.
ylim = get( h_1, 'YLim' );

I    = find( X > xlim(1) & X < xlim(2) );
X    = [X(I) X(I)];                 % Only plot those within axis limits
Y    = repmat(ylim,size(X,1),1);

hold on;
h2   = line(X',Y');
set(h2, 'Color', lc );
set(h2, 'LineWidth', lw );
set(h2, 'LineStyle', lsz );
  
