function [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles)

dirmat = sprintf('mat/%s',dateo);

fnamemat = sprintf('%s/prepEB_%s-%s.mat',dirmat,dateo,datef);
if ~regenfiles && exist(fnamemat,'file')
    load(fnamemat);
    return;
end

extE = 'dgef.sec';
extB = 'dsec.sec';

% Replaces - and - with blank and keeps lines that start with 0 through 9.
GREP = 'grep "^[0-9]" %s | sed "s/-/ /g" | sed "s/:/ /g" > tmp.txt';

do = datenum(dateo,'yyyymmdd');
df = datenum(datef,'yyyymmdd');

B = [];
% -1 due to shift in GIC data by 9 hours
for i = do-1:df
    ds = datestr(i,'yyyymmdd');
    fname = sprintf('data/jma/mmb/B/mmb%s%s',ds,extB);
    fprintf('Reading %s\n',fname);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    B = [B;tmp];
end


tB = datenum(B(:,1:3)) - do;
tB = 86400*tB + 60*60*B(:,4) + 60*B(:,5) + B(:,6); 
B = B(:,8:10);

fill = 88888;
for i = 1:3
    Ig = find(B(:,i) ~= fill);
    Ib = find(B(:,i) == fill);
    B(Ig,i) = B(Ig,i)-mean(B(Ig,i));
    B(Ib,i) = NaN;
end

I = find(B > 5.7e4);
if ~isempty(I)
    fprintf('Removing %d values of B > 5.7e4 as likey missed spikes\n',length(I));
    B(I) = NaN;
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
    fname = sprintf('data/jma/mmb/E/mmb%s%s',ds,extE);
    fprintf('Reading %s\n',fname);
    com = sprintf(GREP,fname);
    system(com);
    load tmp.txt
    E = [E;tmp];
end

% Compute seconds since dateo
tE = datenum(E(:,1:3)) - do;
tE = 86400*tE + 60*60*E(:,4) + 60*E(:,5) + E(:,6); 
E  = E(:,8:9);

fill1 = 88888;
fill2 = 99999;

for i = 1:2
    Ig = find(E(:,i) ~= fill1 & E(:,i) ~= fill2);
    Ib = find(E(:,i) == fill1 | E(:,i) == fill2);
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
E = Ei;

% Remove spike
if strcmp(dateo,'20060402')
    %fprintf('Removing spike in Ey at index 882230\n');
    %E(882230,2) = E(882229,2);
end
delete('tmp.txt');

save(fnamemat,'tE','E','tB','B');
