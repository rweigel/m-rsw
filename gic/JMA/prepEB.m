function [tE,E,tB,B] = prepEB(res)

fnamemat = sprintf('prepEB_%s.mat',res);
if exist(fnamemat,'file')
    load(fnamemat);
    return;
end

diary([fnamemat(1:end-3),'log']);

if strcmp(res,'decisecond')
    extE = 'dgef.dsc';
    extB = 'vdsc.dsc';
else
    extE = 'dgef.sec';
    extB = 'dsec.sec';
end    

% Replaces - and - with blank and keeps lines that start with 0 through 9.
GREP = 'grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt';

B = [];
for i = 13:15
    fname = sprintf('data/jma/mmb/B/mmb200612%02d%s',i,extB);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    B = [B;tmp];
end

zerotime = datenum(2006,12,13);
tB = datenum(B(:,1:6)) - zerotime;	 % Seconds since 2006-12-13:00:00:00Z
B  = B(:,8:10);

fill = 88888;
for i = 1:3
    Ig = find(B(:,i) ~= fill);
    Ib = find(B(:,i) == fill);
    B(Ig,i) = B(Ig,i)-mean(B(Ig,i));
    B(Ib,i) = NaN;
end

fprintf('Interpolating over fill values in B.\n');
ti = [1:size(B,1)]';
for i = 1:3
    Ig = find(~isnan(B(:,i))); % Good points.
    N  = size(B,1);
    Nb = N-length(Ig);
    Bg = B(Ig,i);
    tg = ti(Ig);
    Bi(:,i) = interp1(tg,Bg,ti);
    fprintf('Interpolated over %d of %d points in B_%d\n',Nb,N,i)
end

E = [];
for i = 13:15
    fname = sprintf('data/jma/mmb/E/mmb200612%02d%s',i,extE);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    E = [E;tmp];
end

zerotime = datenum(2006,12,13);
tE = datenum(E(:,1:6)) - zerotime;	 % Seconds since 2006-12-13:00:00:00Z
E  = E(:,8:9);

fill = 88888;
for i = 1:2
    Ig = find(E(:,i) ~= fill);
    Ib = find(E(:,i) == fill);
    E(:,i) = E(:,i)-mean(E(Ig,i));
    E(Ib,i) = NaN;
end

fprintf('Interpolating over fill values in E.\n');
ti = [1:size(E,1)]';
for i = 1:2
    Ig = find(~isnan(E(:,i))); % Good points.
    N  = size(E,1);
    Nb = N-length(Ig);
    Eg = E(Ig,i);
    tg = ti(Ig);
    Ei(:,i) = interp1(tg,Eg,ti);
    fprintf('Interpolated over %d of %d points in E_%d\n',Nb,N,i)
end

delete('tmp.txt');

save(fnamemat,'tE','E','tB','B');
diary off
