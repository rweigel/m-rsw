function Y = rm_doy366(X,Year_o,Npd)
%RM_DOY366 Remove elements of array with day of year labels of 366.
%
%   Y = RM_DOY366(X,Year_o) Removes all values of column vector X with
%   DOY=366, assuming X(1) corresponds to DOY = 1 of integer Year_o and
%   array elements are separated by one day.  X may have multiple columns.
% 
%   Y = RM_DOY366(X,Year_o,Npd) Assumes Npd array elements per day and
%   separation of array elements of one hour.  X(1) corresponds to HR=0
%   on DOY=1 of Year_o.
%
%   See also IS_LEAP_YEAR.
  
if (nargin < 3)  
  Npd    = 1;
end

Nyears = length(X)/(Npd*365);  % Approximate
YEARS  = [Year_o:Year_o+Nyears+1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove 366th day of year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Do(1) = 1;
Y = [];
for i = 1:length(YEARS)

  Df(i)   = Do(i) - 1 + Npd*365 + Npd*is_leap_year(YEARS(i));
  Do(i+1) = Df(i) + 1;

  if (is_leap_year(YEARS(i)))
    Df(i) = Df(i)-Npd;
  end

  if (Df(i) > size(X,1))
    Df(i) = size(X,1);
    Y = [ Y ; X(Do(i):Df(i),:) ];
    return;
  end
  
  Y = [ Y ; X(Do(i):Df(i),:) ];

end

% Each column of D now contains first 365*Npd data points of year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
