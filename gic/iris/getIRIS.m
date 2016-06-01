function getIRIS(sta,start,stop,chas,units)

% Web service API:
% http://service.iris.edu/irisws/
% http://service.iris.edu/irisws/timeseries/1/

% http://service.iris.edu/irisws/fedcatalog/1/query?net=EM
% Get actual last day in archive from bottom of, e.g.,
% http://www.iris.washington.edu/mda/EM/MBB05

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

if (0)
for j = 1:length(chas)
  url = sprintf([url0,url1],sta,chas{j},datestr(start,29),datestr(stop,29))
  fname = sprintf('%s/data/%s_%s-%s.txt',dir,sta,chas{j},units);
  if (exist(fname))
    fprintf('Found %s. Not re-downloading.\n',fname);
    continue
  end
  try
    [f,s] = urlwrite(url,fname);
    fprintf('Done. ');
    
    fname2 = [fname(1:end-4),'.dat'];
    fname3 = [fname(1:end-4),'.mat'];
    if ~exist(fname)
      fprintf('No data for %s.\n',fname);
    else
      com = sprintf('perl -p -e ''s/([0-9])\\-([0-9])/$1 $2/g'' %s | perl -p -e ''s/T|:/ /g'' | perl -p -e ''/^[0-9].*/g'' | grep -e "^[0-9]" > %s',fname,fname2);
      % Faster than using MATLAB fscanf to read.
      % Crate temp file with no non-numeric chars then use MATLAB load.
      system(com);
      X = load(fname2);
      delete(fname2);
      save(fname3,'X');
      fprintf(' Saved %s\n',fname3);
    end
  catch
    fprintf('  Request failed for %s\n',url);
  end
end
end


for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        %ds1 = datestr(i-1,29);
        %ds2 = datestr(i+1,29);
        %url = sprintf([url0,url1],sta,chas{j},ds1,ds2);
	url = sprintf([url0,url1],sta,chas{j},ds,ds);
        fname = sprintf('%s/data/%s_%s_%s-%s.txt',dir,sta,chas{j},ds,units);
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
            else
                com = sprintf('perl -p -e ''s/([0-9])\\-([0-9])/$1 $2/g'' %s | perl -p -e ''s/T|:/ /g'' | perl -p -e ''/^[0-9].*/g'' | grep -e "^[0-9]" > %s',fname,fname2);
                % Faster than using MATLAB fscanf to read.
                % Crate temp file with no non-numeric chars then use MATLAB load.
                system(com);
                X = load(fname2);
                delete(fname2);
                save(fname3,'X');
                fprintf(' Saved %s\n',fname3);
            end
        catch
            fprintf('  Request failed for %s\n',url);
        end
    end
end
