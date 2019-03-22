function C = getIRISCatalog(update)

% Does not handle case where multiple instruments at same location and with different
% start/stop (e.g., MBB05)

if (nargin == 0)
  update = false;
end

url    = 'http://service.iris.edu/irisws/fedcatalog/1/query?net=EM';
fname  = 'getIRISCatalog.txt';
fname1 = 'getIRISCatalog1.mat';
fname2 = 'getIRISCatalog2.mat';

if ~exist(fname) || update
    fprintf('Getting %s\n',url);
    urlwrite(url,fname);
end

if ~exist(fname1) || update
	i = 1;
	fid=fopen(fname);
	while 1
	    tline = fgetl(fid);
	    if ~ischar(tline), break, end
	    %fprintf('%s\n',tline);
	    if length(tline) == 0,continue,end
	    c{i} = strsplit(tline,' ');
	    if strmatch('EM',c{i}{1}) 
		    i = i + 1;
		end
	end
	fclose(fid);
    fprintf('Writing %s\n',fname1);    
	save getIRISCatalog1.mat c
else
	load getIRISCatalog1.mat
end

if ~exist(fname2) || update

	C{1}{1} = c{1}{2};
	C{1}{2} = c{1}{5};
	C{1}{3} = c{1}{6};
	C{1}{4} = c{1}{4};

	k = 1;
	for i = 1:length(c)-1
		if length(strmatch(c{i}{2},c{i+1}{2})) > 0
			fprintf('%s %s %s %s\n',c{i+1}{2},c{i+1}{4},c{i+1}{5},c{i+1}{6})
			l = length(C{k});
			C{k}{l+1} = c{i+1}{4};
			start  = datenum(C{k}{2},'yyyy-mm-ddTHH:MM:SS');
			stop   = datenum(C{k}{3},'yyyy-mm-ddTHH:MM:SS');
			startn = datenum(c{i+1}{5},'yyyy-mm-ddTHH:MM:SS');
			stopn  = datenum(c{i+1}{6},'yyyy-mm-ddTHH:MM:SS');
			if (startn < start)
				tmp = datestr(startn,'yyyy-mm-ddTHH:MM:SS');
				fprintf('start of %s (%s) < current start (%s)\ns',C{k}{1},tmp,C{k}{2})
				C{k}{2} = datestr(startn,'yyyy-mm-ddTHH:MM:SS');
			end
			if (stopn > stop)
				tmp = datestr(stopn,'yyyy-mm-ddTHH:MM:SS');
				fprintf('stop of %s (%s) > current stop (%s)\n',C{k}{1},tmp,C{k}{3})
				C{k}{3} = datestr(stopn,'yyyy-mm-ddTHH:MM:SS');
			end
		end
		if length(strmatch(c{i}{2},c{i+1}{2})) == 0
			fprintf('New Station %s\n',c{i+1}{2})
			fprintf('%s %s %s %s\n',c{i+1}{2},c{i+1}{4},c{i+1}{5},c{i+1}{6})
			k = k+1;
			C{k}{1} = c{i+1}{2};
			C{k}{2} = c{i+1}{5}; % Assumes all start/stop same for station instruments.
			C{k}{3} = c{i+1}{6};
			C{k}{4} = c{i+1}{4};
		end
    end
    fprintf('Writing %s\n',fname2);
	save(fname2,'C')
else
	load(fname2)
end
