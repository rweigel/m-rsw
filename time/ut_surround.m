function DOY = ut_surround(UT,delta,Npd)
%UT_SURROUND List hours around a given UT
%
%   UTs = UT_SURROUND(UT,delta)
%
%   Example: If UT = 1, and delta = 3, UTs = UT_SURROUND(UT,delta)
%   gives UTs = [22, 23, 0, 1, 2, 3, 4]
%
%   UTs = UT_SURROUND(UT,delta,Npd) sets the number of points per day to
%   Npd.
%
%   Example: If UT = 1, and delta = 3, Npd = 1440, 
%   UTs = UT_SURROUND(UT,delta,Npd) gives 
%   UTs = [1438 1439 0 1 2 3 4]
%
%   See also SEASON_SURROUND, DOY_SURROUND.

% R.S. Weigel, January 31, 2004.  

if (nargin < 3)
  Npd = 24;
end
  
a   = (UT-delta);
b   = (UT+delta);
DOY = mod([a:b],Npd);