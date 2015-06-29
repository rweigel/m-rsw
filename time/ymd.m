function [Y,M,D,H,MIN,S] = ymd(DOY,Y,TIME_SCALE)
%YMD Yr, Mo, and Day given either the day number or the day of year and year
%
%   [Y,M,D] = ymd(day_number), day_number, where ymd(1) = [0,1,1].
%
%   [Y,M,D] = ymd(DOY,Y,'day'), DOY is the day of year Y where DOY=1==Jan 1
%   [Y,M,D,H] = ymd(HOY,Y,'hour'), HOY = hour relative to hour 0, of year Y
%   [Y,M,D,H,MIN] = ymd(MOY,Y,'min'), MOY = minute relative to min 0, of year Y
%   [Y,M,D,H,MIN,S] = ymd(SOY,Y,'sec'), SOY = sec. relative to sec 0, of year Y
% 
%   DOY, HOY, etc. can be greater than 1 year.  For example,
%   ymd(367,2000) = [2001 1 1].
%   ymd(366*24,2000,'hour') = [2001 1 1 0].
%   ymd(0,2001,'hour') = [2001 1 1 0].
%
%   DOY and Y are vectors with the same number of elements.  If DOY,
%   HOY, MOY, or day_number is fractional, S will be fractional.
%
%   Other usage:
%
%   V = ymd(day_number), where V = [Y,M,D] if day_number is integer, and
%                        V = [Y,M,D,H,M,S] if day_number is fractional. 
%
%   V = ymd(DOY,Y, ... ) where V = [Y,M,D], [Y,M,D,H], [Y,M,D,H,M],
%                        or [Y,M,D,H,M,S] depending on TIME_SCALE.  
%
%   See also DOY, DAY_NUMBER, NUMBER_DAYS, DAYS_PER_YEAR, TIME_UNION,
%   IS_LEAP_YEAR.

if (nargin < 3)
  TIME_SCALE = 'day';
end  

if (size(DOY,2) > 1)
  DOY = DOY';
end

if (nargin > 1)
  if (size(Y,2) > 1)
    Y = Y';
  end
end

TIME_SCALE = lower(TIME_SCALE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin == 1)
  
    % DOY input = day_number since 0000.
    temp    = 24*(DOY-floor(DOY));
    H       = floor(temp);
    temp    = 60*(temp-H);
    MIN     = floor(temp);
    temp    = 60*(temp-MIN);
    S       = round(temp);

    Is = find( (S==60) );
    S(Is) = 0;
    MIN(Is) = MIN(Is) + 1;

    Im = find( (MIN>=60) );
    MIN(Im) = MIN(Im)-60;
    H(Im) = H(Im)+1;
    
    Ih = find( (H>=24) );
    H(Ih) = 0;
    DOY(Ih) = DOY(Ih)+1;
    
    Y       = floor(floor(DOY)/365.2425);
    Yo      = Y-1;
    DOYo    = DOY - (365.0*Yo + ceil(0.25*Yo)-ceil(0.01*Yo)+ceil(0.0025*Yo)); 
    DOY     = DOY - (365.0*Y + ceil(0.25*Y)-ceil(0.01*Y)+ceil(0.0025*Y));
    Iz      = find(DOY <= 0);
    DOY(Iz) = DOYo(Iz);
    Y(Iz)   = Yo(Iz);
    [Y,M,D] = ymd(DOY,Y);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin > 1) 
  
  if ( (length(DOY) > 1) & (length(Y) == 1) )
    % Figure out what Y vector should be if only initial year was given
    Y = repmat(Y,length(DOY),1);
  end

  I                 = is_leap_year(Y);
  II                = [zeros(size(DOY,1),2) , repmat(I,1,10)]; 
  day_sum           = [0 31 59 90 120 151 181 212 243 273 304 334];
  delta             = repmat(DOY,1,12)-(repmat(day_sum,size(DOY,1),1) + II);
  delta(delta <= 0) = 32; 
  [D,M]             = min(delta');
  M                 = M';
  D                 = floor(D');

  if (max(M) >= 12)
    if (max(D) > 31)
      if (TIME_SCALE(1:3) == 'day')
	DNo     = number_days(repmat(0,length(Y),1),Y-1) + DOY;
	DN      = DNo;
%	DN      = DNo + [0:length(DOY)-1]';
	[Y,M,D] = ymd(DN);
      end
    end  
  end
  
  if (TIME_SCALE(1:3) == 'day')
    if (DOY(1) < 1)
      error('DOY must be greater than 0');
    end
    temp      = 24*(DOY-floor(DOY));
    H         = floor(temp);
    temp      = 60*(temp-H);
    MIN       = floor(temp);
    temp      = 60*(temp-MIN);
    S         = round(temp);
  end
  if (TIME_SCALE(1:3) == 'hou')
    [Y,M,D]   = ymd(floor(DOY/24)+1,Y);
    H         = mod(floor(DOY),24);
    temp      = 60*(DOY-floor(DOY));
    MIN       = floor(temp);
    temp      = 60*(temp-MIN);
    S         = round(temp);
  end
  if (TIME_SCALE(1:3) == 'min')
    [Y,M,D,H] = ymd(floor(DOY/60),Y,'hour');
    MIN       = mod(floor(DOY),60);
    temp      = 60*(DOY-floor(DOY));
    S         = round(temp);
  end
  if (TIME_SCALE(1:3) == 'sec')
    [Y,M,D,H,MIN] = ymd(floor(DOY/60),Y,'min');
    S             = mod(floor(DOY),60);
  end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargout < 2)
  if (TIME_SCALE(1:3) == 'day')
    if (floor(DOY) == DOY)
      Y = [Y,M,D];
    else    
      Y = [Y,M,D,H,MIN,S];
    end
  end
  if (TIME_SCALE(1:3) == 'hou')
    Y = [Y,M,D,H];
  end
  if (TIME_SCALE(1:3) == 'min')
    Y = [Y,M,D,H,MIN];
  end
  if (TIME_SCALE(1:3) == 'sec')
    Y = [Y,M,D,H,MIN,S];
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

