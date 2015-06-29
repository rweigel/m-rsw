function DOY = doy_surround(DOY,delta,year)
%DOY_SURROUND List day numbers around a given DOY
%
%   DOYs = DOY_SURROUND(DOY,delta)
%
%   If delta goes into previous or next year, number of days/year
%   is assumed to be 365.
%   
%   Example: If DOY = 1, and delta = 5, DOYs = doy_surround(DOY,delta)
%   gives DOYs = [360, 361, 362, 363, 364, 365, 1, 2, 3, 4, 5, 6]
%
%   DOYs = DOY_SURROUND(DOY,delta,YEAR) Sets the number of days to
%   that in YEAR.  
%
%   Example: If DOY = 1, and delta = 3, DOYs = doy_surround(DOY,delta,2004)
%   gives DOYs = [364, 365, 366, 1, 2, 3, 4]
%
%   See also SEASON_SURROUND, UT_SURROUND.

% R.S. Weigel, January 31, 2004.  
  
if (nargin < 3)
  Ndays = 365;
else
  Ndays = number_days(year);
end
  
fa = [];
fb = [];
a  = (DOY-delta);
b  = (DOY+delta);

if (DOY-delta < 1)
  a  = 1;
  fa = Ndays-(delta-DOY);
end
if (DOY+delta > Ndays)
  b  = Ndays;
  fb = (DOY+delta)-Ndays;
end

DOY = [a:b];

if (~isempty(fa))
  DOY = [[fa:Ndays] DOY];
end

if (~isempty(fb))
  DOY = [DOY [1:fb]];
end
