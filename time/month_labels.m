function [XLabels,I] = month_labels(YEARS,DAYS_PLOT,FORMAT,Nright)
%MONTH_LABELS Form string of month labels for labeling plot
%
%  XLabels = MONTH_LABELS(YEARS,FORMAT)
%  
%  YEARS      A vector of years to create month labels for.
%  DAYS_PLOT  Plotted day number relative with Jan 1 of YEARS(1) = 1.
%  FORMAT     See DATESTR for list of formats.
%
%  See also MONTH_LABELS_DEMO, EAXES2.
  
% R.S. Weigel 05/27/2004.  

if (nargin < 2)  
  DAYS_PLOT = [1:number_days(YEARS(1),YEARS(end))]';  
else
  DAYS_PLOT = [DAYS_PLOT(1):DAYS_PLOT(end)]';
end

if (nargin < 3)
  FORMAT = 2;
end

if (nargin < 4)
  Nright = 0;
end

N_days      = [31,28,31,30,31,30,31,31,30,31,30,31]';
N_days      = repmat(N_days,1,length(YEARS));
SHIFT       = is_leap_year(YEARS);

N_days(2,:) = N_days(2,:) + SHIFT';
N_days      = N_days(:);
MO_BOUND    = cumsum(N_days);
DAYS_LABEL  = MO_BOUND + 1; % Labels the first of the month;
DAYS_LABEL  = [1;DAYS_LABEL]; % Add first day of the year
DAYN        = day_number(YEARS(1),1,1);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form labels for x-axis
I       = intersect(DAYS_LABEL,DAYS_PLOT);
XLabels = datestr(DAYN+I-1,FORMAT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
