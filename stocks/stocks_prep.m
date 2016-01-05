function D = stocks_prep(symbol)
% Returns 
% Datenum,Open,High,Low,Close,Volume,Adj Close

% DJI.csv contains
% Date,Open,High,Low,Close,Volume
% Manually downloaded from
% https://research.stlouisfed.org/fred2/series/DJIA/downloaddata

% Yahoo data contains
% Date,Open,High,Low,Close,Volume,Adj Close
base = 'http://real-chart.finance.yahoo.com/table.csv';

fnameI = ['./data/',symbol,'.csv'];
fnameO = ['./data/',symbol,'.mat'];

if ~exist(fnameO)
  
    if ~exist(fnameI)
      url = sprintf('%s?s=%s&ignore=.csv',base,symbol);
      fprintf('Downloading %s ... ',url);
      urlwrite(url,fnameI);
      fprintf('Done.\n');
    end
  
    fid = fopen(fnameI);
    fprintf('Reading %s ...',fnameI);
    tline = fgetl(fid);
    k = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        tline = regexprep(tline,'([0-9])-','$1,');
        tmp = str2num(tline);
        D(k,1) = datenum(tmp(1:3));
        if strmatch(symbol,'DJI','exact')
            if (length(tmp) == 7)
                D(k,2:5) = tmp(4:end);
            else
                D(k,2:6) = tmp(4:end);
            end
        else
            D(k,2:7) = tmp(4:end);
        end
        k = k+1;
    end
    fclose(fid);
    fprintf('Done.\n');
    fprintf('Saving %s ...',fnameO);
    save(fnameO,'D');
    fprintf('Done.\n');
else
    load(fnameO);
end

if isempty(strmatch(symbol,'DJI','exact'))
    D = flipud(D);
end