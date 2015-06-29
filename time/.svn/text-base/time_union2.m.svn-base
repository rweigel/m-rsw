function [X1u,X2u,T] = time_union2(X1,X2,FLAG,INTERVAL)
%TIME_UNION2 Put inputs on uniform time grid.  Advanced version of TIME_UNION.
%
%  X1u = TIME_UNION2(X1) Puts data on a sorted, uniform time grid spanning
%  the first day of the earliest year to the last year of the latest year
%  with time between data points of one day.  NaN is used as fill values.
%  X1 has columns of [YEAR, MONTH, DAY, DATA] and X1u has columns of DATA
%  only (with the same or greater number of rows as DATA).
%
%  [X1u,T] = TIME_UNION2(X1) returns T with columns of YEAR MONTH and DAY.
%
%  [X1u,T]     = TIME_UNION2(X1,INTERVAL) 
%  [X1u,X2u]   = TIME_UNION2(X1,X2,FLAG,INTERVAL) 
%  [X1u,X2u,T] = TIME_UNION2(X1,X2,FLAG,INTERVAL) 
%
%  Puts data on a sorted, uniform time grid spanning the first INTERVAL of
%  the earliest year to the last INTERVAL of the latest year with time
%  between data points of INTERVAL.  FLAG is used as fill values.
%  
%  INTERVAL can be 'day', 'hour', 'min', or 'sec'.  If not specified,
%  FLAG = NaN, and INTERVAL = 'day'.
%
%  If duplicates for a given INTERVAL, last-occuring common row in matrix
%  is used.
%
%  If INTERVAL = 'day', the first 3 columns of X1 and X2 must be Year,
%  Month, Day; the other columns are treated as data.  If X1 (X2) has 
%  only three columns, X1u (X2u) is an empty array.
%  If INTERVAL = 'hour', column 4 of X1 and X2 must be the Hour;
%  and the other columns are treated as data.
%  If INTERVAL = 'min', columns 4-5 of X1 and X2 must be the Hour and Min;
%  the last column is treated as data.
%  If INTERVAL = 'sec', columns 4-6 of X1 and X2 must be the Hour
%  Min, and Sec.
%
%  [X1u,X2u,T] = TIME_UNION2(X1,X2,FLAG,INTERVAL) Returns the common time
%  vector in [YEAR, MONTH, DAY, HOUR, MIN, SEC] format.
%
%  Other usage: For more unionizing more than two matrices, use 
%  Xu = TIME_UNION2(X,FLAG,INTERVAL), where X and Xu are cell arrays.  If not
%  specified, FLAG = NaN, and INTERVAL = 'day'.
%
%  See also TIME_UNION, TIME_UNION_DEMO.
  
% R.S. Weigel, 04/19/2004

xnargin = nargin;

if (~iscell(X1))

  if (xnargin == 1) 
    Xc       = {X1};
    FLAG     = NaN;
    INTERVAL = 'day';
  end
  if (xnargin == 2)
    Xc       = {X1};
    FLAG     = NaN;
    if ischar(X2)
      INTERVAL = X2;
      xnargin = 1;
    end
  end
  
  if (xnargin > 1)
    if (prod(size(X2))==1)
      Xc = {X1};
    else
      Xc = {X1,X2}; clear X2;
    end
  end

  if (xnargin == 2) & (length(Xc)==1)
    FLAG     = X2;
    INTERVAL = 'day';
  end
  if (xnargin == 2) & (length(Xc)==2)
    INTERVAL = 'day';
  end
  if (xnargin == 3) & (length(Xc)==1)
    INTERVAL = FLAG;
    FLAG     = X2;
  end
  
end

if (iscell(X1))

  Xc = X1;

  if (xnargin < 2)
    FLAG     = NaN;
    INTERVAL = 'day';
  end
  if (xnargin < 3)
    FLAG     = X2;
    INTERVAL = 'day';
  end

end

if (lower(INTERVAL(1:3)) == 'day')
  Npd   = 1;
  a     = 3;
end

if (lower(INTERVAL(1:3)) == 'hou')
  Npd   = 24;
  a     = 4;
end

if (lower(INTERVAL(1:3)) == 'min')
  Npd   = 24*60;
  a     = 5;
end

if (lower(INTERVAL(1:3)) == '5mi')
  Npd   = 24*12;
  a     = 5;
end

if (lower(INTERVAL(1:3)) == 'sec')
  Npd   = 24*60*60;
  a     = 6;
end


for i = 2:length(Xc)
  if (size(Xc{i},2) < a)
    error(...
	sprintf(['time_union2: If interval = %s, inputs must have ',...
		 ' %d or more columns'],INTERVAL,a));
  end
end

for i = 1:length(Xc)
  if isempty(Xc{i})
    error('time_union2: One of the inputs is empty.');
  end
  s1 = size(Xc{1},1);
  si = size(Xc{i},1);
  if (s1 ~= si)
    error('time_union2: All of the inputs must have the same number of rows.');
  end
end
for i = 1:length(Xc)
  low_year(i)  = min(Xc{i}(:,1));
  high_year(i) = max(Xc{i}(:,1));
  Ncolumns(i)  = size(Xc{i},2);
end

minyr = min(low_year);
maxyr = max(high_year);

Do    = 1;
Df    = Npd*number_days(minyr,maxyr);

for i = 1:length(Xc)

  M = size(Xc{i},2);

  if (M > a)
    Xu{i} = FLAG*ones(Df-Do+1,M-a);
    
    IX{i} = day_number(Xc{i}(:,1),Xc{i}(:,2),Xc{i}(:,3)) - ...
	    day_number(minyr,1,1) + 1;

    if (lower(INTERVAL(1:3)) == 'hou')
      IX{i} = 24*(IX{i}-1) + Xc{i}(:,4) + 1;
    end
  
    if (lower(INTERVAL(1:3)) == 'min')
      IX{i} = 24*60*(IX{i}-1) + 60*Xc{i}(:,4) + Xc{i}(:,5) + 1;
    end

    if (lower(INTERVAL(1:3)) == '5mi')
      IX{i} = Npd*(IX{i}-1) + 12*Xc{i}(:,4) + round(Xc{i}(:,5)/5) + 1;
    end

    if (lower(INTERVAL(1:3)) == 'sec')
      IX{i} = 24*60*60*(IX{i}-1) + 60*60*Xc{i}(:,4) + 60*Xc{i}(:,5) + ...
	      Xc{i}(:,6) + 1;
    end
    Xu{i}(IX{i},:) = Xc{i}(:,a+1:M);
  else
    Xu{i} = [];
  end  

end

if (xnargin == 4)
  X1u = Xu{1};
  X2u = Xu{2};
end

if (~iscell(X1))
  X1u = Xu{1};
  if (length(Xu)>1)
    X2u = Xu{2};
  end
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
if (nargout == 2 & (iscell(X1) | length(Xu)==1))
  if (INTERVAL(1:3) == 'day')
    X2u = ymd([1:(Df-Do+1)]',minyr,INTERVAL);
  else
    X2u = ymd([0:(Df-Do)]',minyr,INTERVAL);
  end
end