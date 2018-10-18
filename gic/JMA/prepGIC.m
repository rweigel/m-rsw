function [tGIC,GIC] = prepGIC(dateo,datef,regenfiles)

dirmat = sprintf('mat/%s',dateo);

fnamemat = sprintf('%s/prepGIC_%s_%s.mat',dirmat,dateo);
if ~regenfiles && exist(fnamemat,'file')
    load(fnamemat)
    return;
end

GIC = [];

if strcmp(dateo,'20061213')
    for i = 14:15
        fid=fopen(sprintf('data/jma/mmb/GIC/200612%02d.txt',i));
        tmp = fscanf(fid,'%f,%f\n');
        fclose(fid);
        tmp = reshape(tmp,2,86400)';
        GIC = [GIC;tmp];
    end

    % GIC files do not have time.  Rows are seconds since file date JST.
    % JST is UT + 9 hours. 
    tGIC = 3600*(24-9) + [0:size(GIC,1)-1]'; % Seconds since 2006-12-13:00:00:00Z
    tGIC = tGIC + 66; % IRFs have peaks at t = -66 s.  Clearly a clock shift issue.
    tGIC = tGIC/86400;
end

do = 1+datenum(dateo,'yyyymmdd');
df = datenum(datef,'yyyymmdd');

B = [];

% Directory names are associated with date somewhere in middle of interval.

% Don't use data for the 17th b/c E field has large gap.
if strcmp(dateo,'20060818')
    for i = do:df
        ds = datestr(i,'yyyymmdd');
        fname = sprintf('data/jma/mmb/GIC2/20060819/%s.txt',ds);
        fid=fopen(fname);
        tmp = fscanf(fid,'%f,%f\n');
        fclose(fid);
        tmp = reshape(tmp,2,86400)';
        GIC = [GIC;tmp];
    end

    % GIC files do not have time.  Rows are seconds since file date JST.
    % JST is UT + 9 hours. 
    tGIC = 3600*(24-9) + [0:size(GIC,1)-1]'; % Seconds since
    tGIC = tGIC + 17; % Clock shift
    tGIC = tGIC/86400;
end

% Don't use data from 17th (again) b/c E field has large gap
if strcmp(dateo,'20060402')
    for i = do:df
        ds = datestr(i,'yyyymmdd');
        fname = sprintf('data/jma/mmb/GIC2/2006Apr/%s.txt',ds);
        fid=fopen(fname);
        tmp = fscanf(fid,'%f,%f\n');
        fclose(fid);
        tmp = reshape(tmp,2,86400)';
        GIC = [GIC;tmp];
    end

    % GIC files do not have time.  Rows are seconds since file date JST.
    % JST is UT + 9 hours. 
    tGIC = 3600*(24-9) + [0:size(GIC,1)-1]'; % Seconds since
    tGIC = tGIC - 70; % Clock shift
    tGIC = tGIC/86400;
end

save(fnamemat,'tGIC','GIC');