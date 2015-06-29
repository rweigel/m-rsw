function [XLabels,I] = year_labels(Ndays,StartDay,FORMAT)
%YEAR_LABELS Form strings for year labels
%
%  XLabels = YEARS_LABELS(Ndays,StartDay)
%  
%  Ndays
%  StartDay
%  
%  Example:
%  [XLabels,I] = year_labels(367,[2000,1,1]) returns
%  XLabels     = ['2000','2001']
%  I           = [1,367]
%
%  [XLabels,I] = year_labels(364,[2000,1,2]) returns
%  XLabels     = ['2000']
%  I           = [1]
%  
%  See also YEAR_LABELS_DEMO, DATE_LABELS.
  
% R.S. Weigel 05/27/2004.  

if (nargin < 3)
  FORMAT = 2;
end

I       = [366:365:Ndays];
I       = I + cumsum(is_leap_year(StartDay(1):StartDay(1)+length(I)-1));
I       = [1,I];
I       = I + doy(StartDay) - 1;

[XLabels,I] = date_labels(I',I',StartDay,10);

I       = I - doy(StartDay) + 1;

dY = 0;
if (dY > 1)

  K        = [1:dY:length(I)];
  I        = I(K);
  XLabels  = XLabels(K,:);

  if (K(end) ~= length(I))
    Yf = str2num(XLabels(end,:));
    Nd = number_days(Yf,Yf+dY)+1;
    I  = [I;I(end)+Nd];
    K  = [K,K(end)+dY];
    XLabels = [XLabels ; num2str(Yf+dY)];
  end
  

  
end
