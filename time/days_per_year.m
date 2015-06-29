function N = days_per_year(year_o)
%DAYS_PER_YEAR Returns the number of days in a year.
%
%    N = DAYS_PER_YEAR(year) returns 366 on leap years, 365 otherwise.
%    
%    See also IS_LEAP_YEAR.
  
if (is_leap_year(year_o))
  N = 366;
else
  N = 365;
end
  