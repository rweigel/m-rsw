function DOY = season_surround(season,delta)
%SEASON_SURROUND List days of year around equinoxes and soltices
%
%   DOY = SEASON_SURROUND(season,delta) where season = 1,2,3,4 or
%         season = 'spring', 'summer', 'fall', or 'winter'.
%
%         If season = 1 and delta = 2, DOY = [77 78 79 80 81].
%         If season = 1 and delta = 0, DOY = 79.
%
%   Assumes equinoxes and soltices are on days [79,166,264,356].
%   If delta goes into previous or next year, number of days/year
%   is assumed to be 365.

%R.S. Weigel 08/01/2004  
  
S = [79,166,264,356];

if isnumeric(season(1))  
  C = S(season);
end

if (~isnumeric(season(1)))
  if (season(1:3) == 'spr')  
    C = 79;
  end  
  if (season(1:3) == 'sum')    
    C = 166;
  end
  
  if (season(1:3) == 'fal')    
     C = 264;
  end
  
  if (season(1:3) == 'win')    
    C = 356;
  end  
end


fa = [];
fb = [];
a  = (C-delta);
b  = (C+delta);

if (C-delta < 1)
  a  = 1;
  fa = 365-(delta-C);
end
if (C+delta > 365)
  b  = 365;
  fb = (C+delta)-365;
end

DOY = [a:b];

if (~isempty(fa))
  DOY = [[fa:365] DOY];
end

if (~isempty(fb))
  DOY = [DOY [1:fb]];
end
