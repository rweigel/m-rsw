function [X1u,X2u,T] = time_union(X1,X2,FLAG,INTERVAL)
%TIME_UNION Put inputs on uniform time grid
%
%  [X1u,X2u] = TIME_UNION(X1,X2,FLAG,INTERVAL) Puts data on a sorted,
%  uniform time grid spanning the first INTERVAL of the earliest year to the
%  last INTERVAL of the latest year with time between data points of
%  INTERVAL.  FLAG is used as fill values.  
%
%  INTERVAL can be 'day', 'hour', 'min', or 'sec'.  If not specified,
%  FLAG = NaN, and INTERVAL = 'day'.
%  
%  The first 6 columns of X1 and X2 must be Year, Month, Day, Hour, Min,
%  Sec.  If INTERVAL = 'Day', the Hour, Min, and Sec columns are ignored.
%  If INTERVAL = 'Hour', the Min and Sec columns are ignored.  If INTERVAL =
%  'Min', the Sec column is ignored.  X1 and X2 may have differing number of
%  columns.  (TIME_UNION2 does not required redundant columns.)
%
%  [X1u,X2u,T] = TIME_UNION(X1,X2,FLAG,INTERVAL) Returns the time vector
%  in [YEAR, MONTH, DAY, HOUR, MIN, SEC] format.
%     
%  For unionizing more than two matrices, use 
%  Xu = TIME_UNION(X,FLAG,INTERVAL), where X and Xu are cell arrays.
%  If not specified, FLAG = NaN, and INTERVAL = 'day'.
%  
%  If duplicates for a given INTERVAL, last-occuring common row in matrix
%  is used.
%
%  See also TIME_UNION_DEMO, TIME_UNION2.
  
% R.S. Weigel, 04/19/2004

if (~iscell(X1))
  Xc = {X1,X2};

  if (nargin < 3)
    FLAG     = NaN;
    INTERVAL = 'day';
  end
  if (nargin < 4)
    INTERVAL = 'day';  
  end
end

if (iscell(X1))
  Xc       = X1;

  if (nargin < 2)
    FLAG     = NaN;
    INTERVAL = 'day';
  end
  if (nargin < 3)
    FLAG     = X2;
    INTERVAL = 'day';
  end
end

if (lower(INTERVAL(1:3)) == 'day')
  Npd   = 1;
end

if (lower(INTERVAL(1:3)) == 'hou')
  Npd   = 24;
end

if (lower(INTERVAL(1:3)) == 'min')
  Npd   = 24*60;
end

if (lower(INTERVAL(1:3)) == 'sec')
  Npd   = 24*60*60;
end

for i = 1:length(Xc)
  low_year(i)  = Xc{i}(1,1);
  high_year(i) = Xc{i}(end,1);
  Ncolumns(i)  = size(Xc{i},2);
end

if ( sum(diff(Ncolumns)) ~= 0)
%  error('All elements of input cell array must have the same number of columns\n');
end

minyr = min(low_year);
maxyr = max(high_year);

Do    = 1;
Df    = Npd*number_days(minyr,maxyr);

for i = 1:length(Xc)
  
  M = size(Xc{i},2);

  Xu{i} = FLAG*ones(Df-Do+1,M-6);
  
  IX{i} = day_number(Xc{i}(:,1),Xc{i}(:,2),Xc{i}(:,3)) - ...
	  day_number(minyr,1,1) + 1;
  
  if (lower(INTERVAL(1:3)) == 'hou')
    IX{i} = 24*(IX{i}-1) + Xc{i}(:,4) + 1;
  end
  
  if (lower(INTERVAL(1:3)) == 'min')
    IX{i} = 24*60*(IX{i}-1) + 60*Xc{i}(:,4) + Xc{i}(:,5) + 1;
  end
  
  if (lower(INTERVAL(1:3)) == 'sec')
    IX{i} = 24*60*60*(IX{i}-1) + 60*60*Xc{i}(:,4) + 60*Xc{i}(:,5) + Xc{i}(:,6)+ 1;
  end
  
  Xu{i}(IX{i},:) = Xc{i}(:,7:M);

end

if (nargin == 4)
  X1u = Xu{1};
  X2u = Xu{2};
end

if (~iscell(X1))
  X1u = Xu{1};
  X2u = Xu{2};
end

if (iscell(X1))
  X1u = Xu;
end
if (nargout == 3 & ~iscell(X1))
  if (INTERVAL(1:3) == 'day')
    T = ymd([1:(Df-Do+1)]',minyr,INTERVAL);
  else
    T = ymd([0:(Df-Do)]',minyr,INTERVAL);
  end
end
if (nargout == 2 & iscell(X1))
  if (INTERVAL(1:3) == 'day')
    X2u = ymd([1:(Df-Do+1)]',minyr,INTERVAL);
  else
    X2u = ymd([0:(Df-Do)]',minyr,INTERVAL);
  end
end