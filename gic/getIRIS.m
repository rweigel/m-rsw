
% http://service.iris.edu/irisws/fedcatalog/1/query?net=EM
% Get actual last day in archive from bottom of
% http://www.iris.washington.edu/mda/EM/MBB05

sta = 'MBB05';

start = '2009-05-11';
stop  = '2011-05-27';
chas  = {'MFE','MFN','MFZ','MQE','MQN'};

start = '2008-06-02';
stop  = '2011-05-27';
chas  = {'LFE','LFN','LFZ','LQE','LQN'};

url0 = 'http://service.iris.edu/irisws/timeseries/1/query?net=EM&';
url1 = 'sta=%s&loc=--&cha=%s&correct=true&starttime=%sT00:00:00&endtime=%sT23:59:59&output=ascii';

startdn = datenum(start);
stopdn  = datenum(stop);

if ~exist('data')
    mkdir('data')
end

for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        url = sprintf([url0,url1],sta,chas{j},ds,ds);
        fname = sprintf('data/iris/%s/%s_%s_%s.txt',sta,sta,chas{j},ds);
        if (exist(fname))
            fprintf('Found %s. Not re-downloading.\n',fname);
            continue
        end
        fprintf('Downloading %s/%s on %s ... ',sta,chas{j},ds);
        try
            urlwrite(url,fname);
            fprintf('Done. ');
            fname2 = [fname(1:end-4),'.dat'];
            fname3 = [fname(1:end-4),'.mat'];
            com = sprintf('perl -p -e ''s/([0-9])\\-([0-9])/$1 $2/g'' %s | perl -p -e ''s/T|:/ /g'' | perl -p -e ''/^[0-9].*/g'' | grep -e "^[0-9]" > %s',fname,fname2);
            % Faster than using MATLAB fscanf to read.
            % Crate temp file with no non-numeric chars then use MATLAB load.
            system(com);
            X = load(fname2);
            delete(fname2);
            save(fname3,'X');
            fprintf('Saved %s\n',fname3);
        catch
            fprintf('Request failed for %s\n',url);
        end
    end
end
