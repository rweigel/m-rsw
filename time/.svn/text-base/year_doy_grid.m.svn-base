function Dg = year_doy_grid(X,Years,ppd)
%YEAR_DOY_GRID Reshape a time series by day of year and year
%
%   Dg = YEAR_DOY_AVE(X,Years) X is a single column array with rows
%   separated by one day with the first element corresponding to data in on
%   day 1 of Years(1) and ending on the last day of Years(2).
%
%   Dg has rows of day of year (D(1,:)=first day of each year) and columns
%   of year.  The 366th day is omitted removed for leap years.  
%
%   See also 

% R.S. Weigel, 07/01/2004  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if (length(X) > ppd*number_days(Years(1),Years(end)))
  error('Input vector should have length = number_days(Years(1),Years(2))');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if (length(Years) ~= 2)
  error('Input Years must be a two element array');
end

Npy = 365*ppd;

YEARS = [Years(1):Years(2)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove 366th day of year
for i = 1:length(YEARS)
  if is_leap_year(YEARS(i))
    delta = 1;
  else
    delta = 0;
  end
  a      = 1 + Npy*(i-1)  + delta;
  b      = a + Npy - 1;
  Dg(:,i) = X(a:b,1);
end
% Each column of Dg now contains first 365 data points of year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

