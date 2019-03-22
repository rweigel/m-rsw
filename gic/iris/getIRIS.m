function getIRIS(sta,start,stop,chas,units)

% Web service API:
% http://service.iris.edu/irisws/
% http://service.iris.edu/irisws/timeseries/1/

% http://service.iris.edu/irisws/fedcatalog/1/query?net=EM
% Get actual last day in archive from bottom of, e.g.,
% http://www.iris.washington.edu/mda/EM/MBB05

if strcmp('2100-01-01',stop)
    error('Invalid stop time of 2100-01-01');
end

force = 0; % Try to download file even if previous failure.

url0 = 'http://service.iris.edu/irisws/timeseries/1/query?net=EM&';

if strcmp(units,'counts')
  url1 = 'sta=%s&loc=--&cha=%s&starttime=%sT00:00:00&endtime=%sT23:59:59&output=ascii';
else
  url1 = 'sta=%s&loc=--&cha=%s&correct=true&units=DEF&starttime=%sT00:00:00&endtime=%sT23:59:59&output=ascii';
  url1 = 'sta=%s&loc=--&cha=%s&correct=true&units=DEF&starttime=%sT23:00:00&endtime=%sT01:00:00&output=ascii';
end

startdn = datenum(start);
stopdn  = datenum(stop);
dir = sprintf('../data/iris/%s',sta);
dir2 = sprintf('../data/iris/%s/data',sta);

if ~exist(dir2)
  system(sprintf('mkdir -p %s',dir2));
end

for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        url = sprintf([url0,url1],sta,chas{j},ds,ds);
        fname = sprintf('%s/data/%s_%s_%s-%s.txt',dir,sta,chas{j},ds,units);
        if ~force && exist([fname,'.failed'])
            fprintf('Skipping %s because previous download failed.\n',fname);
            % Other channels probably not available if first is not, so
            % abort data for this day.
            break;
        end
        if exist(fname) || exist([fname,'.gz'])
            fprintf('Found %s. Not re-downloading.\n',fname);
            continue
        end
        fprintf('%s\n',url);
        fprintf('Downloading %s/%s on %s ...\n',sta,chas{j},ds);
        try
            [f,s] = urlwrite(url,fname);
            fprintf('Done. ');

            fname2 = [fname(1:end-4),'.dat'];
            fname3 = [fname(1:end-4),'.mat'];
            if ~exist(fname)
                fprintf('No data for %s.\n',fname);
                failed = 1;                
            else
                com = sprintf('perl -p -e ''s/([0-9])\\-([0-9])/$1 $2/g'' %s | perl -p -e ''s/T|:/ /g'' | perl -p -e ''/^[0-9].*/g'' | grep -e "^[0-9]" > %s',fname,fname2);
                % Faster than using MATLAB fscanf to read.
                % Crate temp file with no non-numeric chars then use MATLAB load.
                system(com);
                X = load(fname2);
                delete(fname2);
                save(fname3,'X');
                fprintf(' Saved %s\n',fname3);
                failed = 0;
            end
        catch
            fprintf('  Request failed for %s\n',url);
            failed = 1;
        end
        if failed
            fid = fopen([fname,'.failed'],'w');
            fprintf('Download failed on %s. Writing .failed file.\n',datestr(now));
            fprintf(fid,'Download failed on %s. Writing .failed file.\n',datestr(now));
            fclose(fid);
            break;
        end
    end
end
