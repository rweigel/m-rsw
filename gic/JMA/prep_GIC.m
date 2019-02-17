function [tGIC,GIC] = prep_GIC(dateo,datef,regenfiles)

dirmat = sprintf('mat/%s',dateo);
dirtxt = 'data/watari/GICall';

if ~exist(dirmat,'dir')
    mkdir(dirmat);
end

fnamemat = sprintf('%s/prepGIC_%s.mat',dirmat,dateo);
if regenfiles == 0 && exist(fnamemat,'file')
    load(fnamemat)
    return;
end

do = datenum(dateo,'yyyymmdd');
df = datenum(datef,'yyyymmdd');

GIC = [];

for i = do:df
    ds = datestr(i,'yyyymmdd');
    file = sprintf('%s/%s.txt',dirtxt,ds);
    fprintf('prep_GIC.m: Reading %s\n',file);
    fid=fopen(file);
    tmp = fscanf(fid,'%f,%f\n');
    fclose(fid);
    if length(tmp) == 86400*2
        tmp = reshape(tmp,2,86400)';
    else
        fprintf('prep_GIC.m: GIC file %s.txt is missing data. Using NaNs for day\n',ds)
        tmp = NaN*ones(86400,2);
    end
    GIC = [GIC;tmp];
end

% GIC files do not have time.  Rows are seconds since file date JST.
% JST is UT + 9 hours. 
tGIC = -3600*9 + [0:size(GIC,1)-1]'; % # of seconds relative to dateo UT

dayoffset = datenum(dateo,'yyyymmdd') - datenum('1970-01-01');

tGIC = tGIC*1000 + dayoffset*86400*1000; % Convert to milliseconds since 1970 (Unix Time).

save(fnamemat,'tGIC','GIC');
