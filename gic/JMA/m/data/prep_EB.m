function [tE,E,tB,B] = prep_EB(dateo,datef,station,regenfiles,codever)

dirbase = [fileparts(mfilename('fullpath')),'/../..'];
dirmat = sprintf('%s/data/jma/mat',dirbase);

if ~exist(dirmat,'dir')
    mkdir(dirmat);
end

fprintf('prep_EB.m: Called with dateo/datef = %s/%s, station = %s, regenfiles = %d\n',...
            dateo,datef,station,regenfiles);
fnamemat = sprintf('%s/prepEB_%s_%s-%s-v%d.mat',dirmat,station,dateo,datef,codever);
if regenfiles == 0
    if exist(fnamemat,'file')
        fprintf('prep_EB.m: Loading %s\n',fnamemat);
        load(fnamemat);
        fprintf('prep_EB.m: Done.\n');
        return;
    else
        fprintf('prep_EB.m: Did not find %s.\n',fnamemat);    
        fprintf('prep_EB.m: Will create it.\n');
    end
else
    %fprintf('prep_EB.m: Creating %s.\n',fnamemat);
end

extE = 'dgef.sec';
extB = 'dsec.sec';

% Much faster read using grep/sed modification of file so MATLAB load
% can be used.
if codever == 0
    % Incorrect code that leads to sign error for By.
    GREP = 'grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt';
else
    % Replaces [0-9]- and [0-9]: with space and keeps lines that start with 0 through 9.
    GREP = 'grep "^[0-9]" %s | sed "s/\\([0-9]\\)-/\\1 /g" | sed "s/:/ /g" > tmp.txt';    
end

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
    meanB(1,i) = mean(B(Ig,i));
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
    meanE(1,i) = mean(E(Ig,i));
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
