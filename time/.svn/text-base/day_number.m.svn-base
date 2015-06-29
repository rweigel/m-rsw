function N = day_number(y,m,d)
%DAY_NUMBER The number of days since Jan 1, 0000.
%
%    N = DAY_NUMBER(y,m,d) or 
%    N = DAY_NUMBER([y,m,d])
%
%    See also IS_LEAP_YEAR, DAYS_PER_YEAR, DATENUM.

% R.S. Weigel, 08/01/2004
  
if (nargin == 1)
  N = 365*y(:,1) + ceil(y(:,1)/4) - ceil(y(:,1)/100) + ceil(y(:,1)/400) + ...
      doy([y(:,1),y(:,2),y(:,3)]);
else
  N = 365*y + ceil(y/4) - ceil(y/100) + ceil(y/400) + doy([y,m,d]);
end
