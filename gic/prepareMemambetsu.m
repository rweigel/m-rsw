function [B_JMA,E_JMA] = prepareData(short)

% 1-second B and E data from http://www.kakioka-jma.go.jp/metadata?locale=en

if strmatch(short,'kak')
    long = 'kakioka';
end
if strmatch(short,'mem')
    long = 'memambetsu';
end

fname = sprintf('./data/%s/JMA_Bfile.mat',long)
if ~exist(fname)
    JMA_Bfile = [];
    for i = 1:31
        fname = sprintf('data/%s/unzip/%s200612%02ddsec.sec',i,long,short);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        JMA_Bfile = [JMA_Bfile;tmp];
    end
    save(fname,'JMA_Bfile')
else
    fprintf('Reading %s\n',fname);
    load(fname)
end

clear Atmp;
fname = sprintf('./data/%s/JMA_Efile.mat',long)
if ~exist(fname)
    JMA_Efile = [];
    for i = 1:31
        fname = sprintf('data/%s/unzip/%s200612%02ddgef.sec',i,long,short);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        JMA_Efile= [JMA_Efile;tmp];
    end
    save(fname,'JMA_Bfile')
else
    fprintf('Reading %s\n',fname);
    load(fname)
end

fprintf('Subtracting off means of non NaN values for B.\n');

t_JMA_B = datenum(JMA_Bfile(1:6));
B_JMA   = JMA_Bfile(:,8:10);

for i = 1:3
    Ig = find(B_JMA(:,i) ~= 88888.00);
    B_JMA(:,i) = B_JMA(:,i)-mean(B_JMA(Ig,i));
    Ib = find(B_JMA(:,i) == 88888.00);
    B_JMA(Ib,i) = NaN;
end

fprintf('Subtracting off means of non NaN values for B.\n');

t_JMA_E = datenum(JMA_Efile(:,1:6));
E_JMA = JMA_Efile(:,8:9);

fprintf('Placing NaNs in bad areas of E.\n');
Ixb = [1755000:1755600];
E_JMA(Ixb,1) = NaN;

Iyb = [1754600:1755100];
E_JMA(Iyb,2) = NaN;

for i = 1:2
    Ig = find(E_JMA(:,i) ~= 88888.00 & ~isnan(E_JMA(:,i)));
    E_JMA(:,i) = E_JMA(:,i)-mean(E_JMA(Ig,i));
    Ib = find(E_JMA(:,i) == 88888.00);
    E_JMA(Ib,i) = NaN;
end