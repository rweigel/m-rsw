function [Bi,dBi,Ei] = prepareData(short,long)

% 1-second B and E data from http://www.kakioka-jma.go.jp/metadata?locale=en

bname = sprintf('./data/%s/Bfile.mat',long);
ename = sprintf('./data/%s/Efile.mat',long);
bname2 = sprintf('./data/%s/Bfile2.mat',long);
ename2 = sprintf('./data/%s/Efile2.mat',long);

if ~exist(bname2)
if ~exist(bname)
    Bfile = [];
    for i = 1:31
        fname = sprintf('data/%s/unzip/%s200612%02ddsec.sec',long,short,i);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        Bfile = [Bfile;tmp];
    end
    save(bname,'Bfile')
else
    fprintf('Reading %s\n',bname);
    load(bname)
end
end

if ~exist(ename2)
if ~exist(ename)
    Efile = [];
    for i = 1:31
        fname = sprintf('data/%s/unzip/%s200612%02ddgef.sec',long,short,i);
        fprintf('Reading %s\n',fname);
        com = sprintf('grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt',fname);
        system(com);
        load tmp.txt
        Efile= [Efile;tmp];
    end
    save(ename,'Efile')
else
    fprintf('Reading %s\n',ename);
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
        fprintf('Interpolated over %d of %d points in component %d\n',Nb,N,i)
    end

    dB = diff(B);
    dB(end+1,:) = dB(end,:); % Repeat last value so length is same as B
    fprintf('Interpolating over NaNs values in dB/dt.\n');
    ti = [1:size(dB,1)]';
    for i = 1:3
        Ig = find(~isnan(dB(:,i))); % Good points.
        N  = size(dB,1);
        Nb = N-length(Ig);
        dBg = dB(Ig,i);
        tg = ti(Ig);
        dBi(:,i) = interp1(tg,dBg,ti);
        fprintf('Interpolated over %d of %d points in component %d\n',Nb,N,i)
end
    save(bname2,'B','Bi','dB','dBi')
else
    fprintf('Reading %s\n',bname2);
    load(bname2)
end

if ~exist(ename2)

    t_E = datenum(Efile(:,1:6));
    E = Efile(:,8:9);

    fprintf('Placing NaNs in bad areas of E.\n');
    if strmatch(short,'kak')
        E(E > 8e4) = NaN;
    end
    if strmatch(short,'mmb')
        Ixb = [1755000:1755600];
        E(Ixb,1) = NaN;

        Iyb = [1754600:1755100];
        E(Iyb,2) = NaN;
    end

    fprintf('Subtracting off means of non NaN values for E.\n');

    for i = 1:2
        Ig = find(E(:,i) ~= 88888.00 & ~isnan(E(:,i)));
        E(:,i) = E(:,i)-mean(E(Ig,i));
        Ib = find(E(:,i) == 88888.00);
        E(Ib,i) = NaN;
    end

    fprintf('Interpolating over NaNs values in E.\n');
    ti = [1:size(E,1)]';
    for i = 1:2
        Ig = find(~isnan(E(:,i))); % Good points.
        N  = size(E,1);
        Nb = N-length(Ig);
        Eg = E(Ig,i);
        tg = ti(Ig);
        Ei(:,i) = interp1(tg,Eg,ti);
        fprintf('Interpolated over %d of %d points in component %d\n',Nb,N,i)
    end
    save(ename2,'E','Ei')
else
    fprintf('Reading %s\n',ename2);
    load(ename2)
end

