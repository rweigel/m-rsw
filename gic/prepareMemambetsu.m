function [B_MMB_JMA,E_MMB_JMA] = prepareMemambetsu(quantity)

% 1-second B and E data from MEM from
% http://www.kakioka-jma.go.jp/metadata?locale=en

if ~exist('./data/memambetsu/MMB_JMA_Bfile.mat')
    MMB_JMA_Bfile = [];
    for i = 1:31
        fname = sprintf('data/memambetsu/unzip/mmb200612%02ddsec.sec',i);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        MMB_JMA_Bfile = [MMB_JMA_Bfile;tmp];
    end
    save ./data/memambetsu/MMB_JMA_Bfile.mat MMB_JMA_Bfile
else
    fprintf('Reading MMB_JMA_Bfile.mat\n');
    load ./data/memambetsu/MMB_JMA_Bfile.mat    
end

clear Atmp;
if ~exist('./data/memambetsu/MMB_JMA_Efile.mat')
    MMB_JMA_Efile = [];
    for i = 1:31
        fname = sprintf('data/memambetsu/unzip/mmb200612%02ddgef.sec',i);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        MMB_JMA_Efile= [MMB_JMA_Efile;tmp];
    end
    save ./data/memambetsu/MMB_JMA_Efile.mat MMB_JMA_Efile
else
    fprintf('Reading MMB_JMA_Efile.mat\n');
    load ./data/memambetsu/MMB_JMA_Efile.mat
end

fprintf('Subtracting off means of non NaN values for B.\n');

t_MMB_JMA_B = datenum(MMB_JMA_Bfile(1:6));
B_MMB_JMA   = MMB_JMA_Bfile(:,8:10);

for i = 1:3
    Ig = find(B_MMB_JMA(:,i) ~= 88888.00);
    B_MMB_JMA(:,i) = B_MMB_JMA(:,i)-mean(B_MMB_JMA(Ig,i));
    Ib = find(B_MMB_JMA(:,i) == 88888.00);
    B_MMB_JMA(Ib,i) = NaN;
end

fprintf('Subtracting off means of non NaN values for B.\n');

t_MMB_JMA_E = datenum(MMB_JMA_Efile(:,1:6));
E_MMB_JMA = MMB_JMA_Efile(:,8:9);

fprintf('Placing NaNs in bad areas of E.\n');
Ixb = [1755000:1755600];
E_MMB_JMA(Ixb,1) = NaN;

Iyb = [1754600:1755100];
E_MMB_JMA(Iyb,2) = NaN;

for i = 1:2
    Ig = find(E_MMB_JMA(:,i) ~= 88888.00 & ~isnan(E_MMB_JMA(:,i)));
    E_MMB_JMA(:,i) = E_MMB_JMA(:,i)-mean(E_MMB_JMA(Ig,i));
    Ib = find(E_MMB_JMA(:,i) == 88888.00);
    E_MMB_JMA(Ib,i) = NaN;
end