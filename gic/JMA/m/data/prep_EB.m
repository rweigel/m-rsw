function [tE,E,tB,B] = prep_EB(dateo,datef,station,regenfiles)

% Note that automated downloads of JMA data can be made using
% using
  
dirbase = '/home/weigel/git/m-rsw/gic';
dirmat = sprintf('%s/mat/%s',dirbase,dateo);

if ~exist(dirmat,'dir')
    mkdir(dirmat);
end

fnamemat = sprintf('%s/prepEB_%s_%s-%s.mat',dirmat,station,dateo,datef);
if regenfiles == 0 && exist(fnamemat,'file')
    load(fnamemat);
    return;
end

extE = 'dgef.sec';
extB = 'dsec.sec';

% Replaces - and : with space and keeps lines that start with 0 through 9.
% Much faster read.
GREP = 'grep "^[0-9]" %s | sed "s/\\([0-9]\\)-/\\1 /g" | sed "s/:/ /g" > tmp.txt';

do = datenum(dateo,'yyyymmdd');
df = datenum(datef,'yyyymmdd');

B = [];
% -1 due to shift in GIC data by 9 hours
for i = do-1:df
    ds = datestr(i,'yyyymmdd');
    fname = sprintf('%s/data/jma/%s/B/%s%s%s',dirbase,station,station,ds,extB);
    fprintf('Reading %s\n',fname);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    B = [B;tmp];
end

tB = datenum(B(:,1:6));

B = B(:,8:10);

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
B = Bi;


E = [];
% -1 due to shift in GIC data by 9 hours
for i = -1+do:df
    ds = datestr(i,'yyyymmdd');
    fname = sprintf('%s/data/jma/%s/E/%s%s%s',dirbase,station,station,ds,extE);
    fprintf('Reading %s\n',fname);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    E = [E;tmp];
end

% Compute seconds since dateo
tE = datenum(E(:,1:6));
E  = E(:,8:9);

fill1 = 88888;
fill2 = 99999;

for i = 1:2
    Ig = find(E(:,i) ~= fill1 & E(:,i) ~= fill2); % "good" values
    Ib = find(E(:,i) == fill1 | E(:,i) == fill2); % "bad" values
    E(:,i) = E(:,i)-mean(E(Ig,i));
    E(Ib,i) = NaN;
end

fprintf('Interpolating over fill values in E.\n');
ti = [1:size(E,1)]';
for i = 1:2
    Ig = find(~isnan(E(:,i))); % "good" values.
    N  = size(E,1);
    Nb = N-length(Ig);
    Eg = E(Ig,i);
    tg = ti(Ig);
    Ei(:,i) = interp1(tg,Eg,ti);
    fprintf('Interpolated over %d of %d points in E_%d\n',Nb,N,i)
end
E = Ei;

delete('tmp.txt');

fprintf('Writing %s\n',fnamemat);
save(fnamemat,'tE','E','tB','B');
