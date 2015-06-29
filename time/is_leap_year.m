function Q = is_leap_year(year_o)
%IS_LEAP_YEAR Returns 1 if leap year 0 if not
%
%    Q = IS_LEAP_YEAR(year) returns Q = 1 if year is a leap year and Q = 0
%    otherwise.
%
%    From http://scienceworld.wolfram.com/astronomy/LeapYear.html
%  
%    A leap year is a year in which an extra day in added to the calendar in 
%    order to synchronize it with the seasons. Since the tropical year is 
%    365.242190 days long, a leap year must be added roughly once every
%    four years (four times the fractional day gives ). In a leap year, the 
%    extra day (known as a leap day) is added at the end of February, giving 
%    it 29 instead of the usual 28 days. 
%  
%    In the Gregorian calendar currently in use worldwide (except perhaps the
%    Russian and Iranian calendars), there is a 
%    leap year every year divisible by four except for years which are both 
%    divisible by 100 and not divisible by 400. Therefore, the year 2000 
%    will be a leap year, but the years 1700, 1800, and 1900 were not. The
%    complete list of leap years in the first half of the 21st century is 
%    therefore 2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032, 2036,
%    2040, 2044, and 2048.
%  
%    The extra rule involving centuries is an additional correction to make
%    up for the fact that one extra day every four years is slightly too
%    much correction (). This scheme results in the vernal equinox gradually
%    shifting its date between March 19 and 21, being shifted once every
%    leap year, and then being abruptly shifted in non-leap centuries (see
%    figure above).
%
%    See also DAY_NUMBER, NUMBER_DAYS, DOY, and YMD.
  
% This version based on Octave's is_leap_year function.
% (uses ~= instead of != for Matlab compatability).

Q = ((rem (year_o, 4) == 0 & rem (year_o, 100) ~= 0) | rem (year_o, 400) == 0);
