function N = number_days(year_o,year_f)
%NUMBER_DAYS Returns the number of days in year range
%
%    N = NUMBER_DAYS(year_o) Returns the number of days in year_o.
%
%    N = NUMBER_DAYS(year_o,year_f) Returns the number of days
%    in range including day 1 of year_o and the last day of year_f.
%    If year_o < year_f, N=0.
%    
%    See also IS_LEAP_YEAR, DAYS_PER_YEAR, DAY_NUMBER.

if (nargin < 2)
  year_f = year_o;
end

if ischar(year_o)
  year_o = str2num(year_o);
end
if ischar(year_f)
  year_f = str2num(year_f);
end

L = length(year_o);
N = day_number(year_f,repmat(12,L,1),repmat(31,L,1)) - ...
    day_number(year_o,repmat(1,L,1),repmat(1,L,1)) + 1 ; 


% Slow way
if (0)
for j = 1:size(year_o,1)  
  n     = 0;
  years = [year_o:year_f];

  for i = 1:(year_f-year_o+1)
    n = [n;days_per_year(years(i))];
  end

  N(j) = sum(n);
end
end