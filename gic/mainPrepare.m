function [Bi,dBi,Ei,T] = prepareData(short,long)

s = dbstack;
n = s(1).name;

if strcmp('obibmt',short)
    if ~exist('data/Pierre','dir')
        fprintf('%s: Directory data/Pierre required. See Google Drive/Presentation/2015-SANSA.\n',n);
    end
    load('data/Pierre/Data/MT/Obib/Obib_MT_20130706141500.mat')

end
if strcmp('obibdm',short)
    if ~exist('data/Pierre','dir')
        fprintf('%s: Directory data/Pierre required. See Google Drive/Presentation/2015-SANSA.\n',n);
    end
    load('data/Pierre/Data/MT/Obib/Obib_DM_20130706110300.mat')

end
if strcmp('obibdm',short) || strcmp('obibmt',short)
    for i = 1:3
        B(:,i) = B(:,i) - mean(B(:,i));
    end
    Nd = ceil(size(B,1)/86400)*86400;
    Np = Nd - size(B,1);
    if (Np > 0) && (Np < 0.2*86400)
        fprintf('%s: Padding time series by %d points (to get full day).\n',n,Np);
    end
    Bp = repmat(B(end,:),Np,1);
    Ep = repmat(E(end,:),Np,1);
    B = [B;Bp];
    E = [E;Ep];

    dBi = diff(B);
    dBi = [dBi;dBi(end,:)];
    Bi = B;
    Ei = E;
    return
end

% 1-second B and E data from http://www.kakioka-jma.go.jp/metadata?locale=en

bname  = sprintf('data/%s/Bfile1.mat',long);
bname2 = sprintf('data/%s/Bfile2.mat',long);

ename  = sprintf('data/%s/Efile1.mat',long);
ename2 = sprintf('data/%s/Efile2.mat',long);

base  = 'http://mag.gmu.edu/git-data/m-rsw/gic/';

d = sprintf('data/%s',long);
if ~exist(d,'dir')
    mkdir(d)
end

if ~exist(bname2)
    fprintf('%s: Downloading %s\n',n,[base,bname]);
    [f,s] = urlwrite([base,bname],bname);
    if ~exist(bname)
        % Need to download zip files here.
        % wget -r -l1 http://mag.gmu.edu/git-data/m-rsw/gic/data/memambetsu/zip/
        % mkdir data/memambetsu/zip/
        % mkdir data/memambetsu/unzip/
        % mv mag.gmu.edu/git-data/m-rsw/gic/data/memambetsu/zip data/memambetsu/zip/
        % cd data/memambetsu/unzip/; unzip ../zip/*.zip
        Bfile = [];
        for i = 1:31
            fname = sprintf('data/%s/unzip/%s200612%02ddsec.sec',long,short,i);
            fprintf('%s: Reading %s\n',n,fname);
            com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
            system(com);
            load tmp.txt
            Bfile = [Bfile;tmp];
        end
        save(bname,'Bfile')
    else
        fprintf('%s: Reading %s\n',n,bname);
        load(bname)
    end
end

if ~exist(ename2)
    fprintf('Downloading %s\n',[base,ename]);
    [f,s] = urlwrite([base,ename],ename);
    if ~exist(ename)
        % Need to download zip files here.
        Efile = [];
        for i = 1:31
            fname = sprintf('data/%s/unzip/%s200612%02ddgef.sec',long,short,i);
            fprintf('%s: Reading %s\n',n,fname);
            com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
            system(com);
            load tmp.txt
            Efile= [Efile;tmp];
        end
        save(ename,'Efile')
    else
        fprintf('%s: Reading %s\n',n,ename);
        load(ename)
    end
end

if ~exist(bname2)
    fprintf('Subtracting off means of non NaN values for B.\n');

    t_B = datenum(Bfile(1:6));
    B   = Bfile(:,8:10);

    if strmatch(short,'mmb')
        fill = 88888.00;
    end
    if strmatch(short,'kak')
        fill = 99999.00;
    end

    for i = 1:3
        Ig = find(B(:,i) ~= fill);
        Ib = find(B(:,i) == fill);
        B(Ig,i) = B(Ig,i)-mean(B(Ig,i));
        B(Ib,i) = NaN;
    end
    
    fprintf('Interpolating over NaNs values in B.\n');
    ti = [1:size(B,1)]';
    for i = 1:3
        Ig = find(~isnan(B(:,i))); % Good points.
        N  = size(B,1);
        Nb = N-length(Ig);
        Bg = B(Ig,i);
        tg = ti(Ig);
        Bi(:,i) = interp1(tg,Bg,ti);
        fprintf('%s: Interpolated over %d of %d points in component %d\n',n,Nb,N,i)
    end

    dB = diff(B);
    dB(end+1,:) = dB(end,:); % Repeat last value so length is same as B
    fprintf('%s: Interpolating over NaNs values in dB/dt.\n',n);
    ti = [1:size(dB,1)]';
    for i = 1:3
        Ig = find(~isnan(dB(:,i))); % Good points.
        N  = size(dB,1);
        Nb = N-length(Ig);
        dBg = dB(Ig,i);
        tg = ti(Ig);
        dBi(:,i) = interp1(tg,dBg,ti);
        fprintf('%s: Interpolated over %d of %d points in component %d\n',n,Nb,N,i)
    end

    B   = B(1:86400*25,:);
    Bi  = Bi(1:86400*25,:);
    dBi = dBi(1:86400*25,:);
    dB  = dB(1:86400*25,:);

    for i = 1:size(dBi,2)
        I = find(abs(dBi(:,i)>2));
        dB(I,i) = 0;
        fprintf('%s: Set %d of %d values of |dB_%d| > 2 to zero.\n',...
            n,length(I),size(dBi,1),i);
    end

    save(bname2,'B','Bi','dB','dBi')
else
    fprintf('%s: Reading %s\n',n,bname2);
    load(bname2)
end

if ~exist(ename2)

    t_E = datenum(Efile(:,1:6));
    E = Efile(:,8:9);

    fprintf('%s: Placing NaNs in bad areas of E.\n',n);
    if strmatch(short,'kak')
        E(E > 8e4) = NaN;
    end
    if strmatch(short,'mmb')
        Ixb = [1755000:1755600];
        E(Ixb,1) = NaN;

        Iyb = [1754600:1755100];
        E(Iyb,2) = NaN;
    end

    fprintf('%s: Subtracting off means of non NaN values for E.\n',n);

    for i = 1:2
        Ig = find(E(:,i) ~= 88888.00 & ~isnan(E(:,i)));
        E(:,i) = E(:,i)-mean(E(Ig,i));
        Ib = find(E(:,i) == 88888.00);
        E(Ib,i) = NaN;
    end

    fprintf('%s: Interpolating over NaNs values in E.\n',n);
    ti = [1:size(E,1)]';
    for i = 1:2
        Ig = find(~isnan(E(:,i))); % Good points.
        N  = size(E,1);
        Nb = N-length(Ig);
        Eg = E(Ig,i);
        tg = ti(Ig);
        Ei(:,i) = interp1(tg,Eg,ti);
        fprintf('%s: Interpolated over %d of %d points in component %d\n',n,Nb,N,i)
    end

    E  = E(1:86400*25,:);
    Ei = Ei(1:86400*25,:);

    save(ename2,'E','Ei')
else
    fprintf('%s: Reading %s\n',n,ename2);
    load(ename2)
end


