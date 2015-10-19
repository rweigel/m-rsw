function [Symbol,Start] = stocks_info(symbolref,symbol)

if strmatch(symbolref,'DJI','exact')
    fid = fopen('info/DJIA.csv','r');
    tline = fgetl(fid);
    k = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline),break,end;
        I = find(tline == ',');
        Symbols{k} = tline(1:I(1)-1);
        D = stocks_prep(Symbols{k});
        Starts{k} = D(1,1);
        k = k+1;
    end
    fclose(fid);
end

if strmatch(symbolref,'QQQ','exact')
    fid = fopen('info/nasdaq100list.csv','r');
    tline = fgetl(fid);
    k = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline),break,end;
        I = find(tline == ',');
        Symbols{k} = tline(1:I(1)-1);
        D = stocks_prep(Symbols{k});
        Starts{k} = D(1,1);
        k = k+1;
    end
    fclose(fid);
    D = stocks_prep('QQQ');
end

if nargin > 1
    symbol
    I = strncmp(symbol,Symbols,length(symbol));
    Symbol = Starts{I};
else
    Symbol = Symbols;
    Start = Starts;
end

