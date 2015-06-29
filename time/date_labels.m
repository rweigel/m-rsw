function [XLabels,I] = date_labels(DAYS_PLOT,DAYS_LABEL,DAY_0,FORMAT,Nright)
%DATE_LABELS Form string of date labels for labeling plot
%
%  XLabels = DATE_LABELS(DAYS_PLOT,DAYS_LABEL,DAY_0)
%  
%  DAYS_PLOT  A vector of day numbers that are plotted.
%  DAYS_LABEL A vector of day numbers to be labeled.
%  DAY_0      [Year,Month,Day].
%
%  Note that day number is relative to DAY_0, with DAY_0 being
%  day number = 1.
%
%  XLabels has the same number of rows as DAYS_PLOT, with
%  a date string (or blank string) for each element.
%  
%  XLabels = DATE_LABELS(DAYS_PLOT,DAYS_LABEL,DAY_0,FORMAT,Nright)
%  pads XLabels with Nright blanks.  FORMAT is the same used in DATESTR.
%  Default is FORMAT = 2.
%
%  See also DATE_LABELS_DEMO, EAXES2.
  
% R.S. Weigel 05/27/2004.  
  
if (nargin < 5)
  Nright = 0;
end

if (nargin < 4)
  FORMAT = 2;
end

DAYN = day_number(DAY_0(1),DAY_0(2),DAY_0(3));
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form labels for x-axis
I            = intersect(DAYS_LABEL,DAYS_PLOT);
%W            = length(datestr(1,FORMAT));
%XLabels      = repmat(blanks(W),length(DAYS_PLOT),1);
XLabels   = datestr(DAYN+I-1,FORMAT);
XLabels   = [XLabels ; repmat(blanks(length(datestr(1,FORMAT))),Nright,1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







