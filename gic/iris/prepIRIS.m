function prepIRIS(sta,start,stop,chas,units)

startdn = datenum(start);
stopdn  = datenum(stop);
dir = '../data/iris';

fnameout = sprintf('%s/%s/data/%s-%s-original.mat',dir,sta,sta,units);

if exist(fnameout)
    load(fnameout);
    return
end

D = [];
for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        fname = sprintf('%s/%s/data/%s_%s_%s-%s.mat',...
			dir,sta,sta,chas{j},ds,units);

	di = repmat(NaN,86400,1);
	ti = [0:86400-1]';
	
	if ~exist(fname) && ~exist([fname,'.gz'])
	  fprintf('Not found.  Using fills for %s.\n',fname);
	else
	    if ~exist(fname) && exist([fname,'.gz'])
		com = sprintf('gunzip %s',[fname,'.gz']);
		system(com);
	    end
	    fprintf('Reading %s. ',fname);
	    load(fname);
	    dnx = datenum(X(:,1:3));
	    I = find(dnx == i);
	    X = X(I,:);
	    % 1 + second of day
	    m = floor(X(:,6));
	    s = (X(:,6) - m)*60;
	    if ~all(s == 0)
		fprintf('\n\nWarning: Sub-second data in file.\n');
		fprintf('  Rounding to nearest second.\n');
		fprintf('  Using last value when multiple records have\n');
		fprintf('  same second value.\n\n');
	    end
	    t = 1 + X(:,4)*60*60 + X(:,5)*60 + m;
	    % Data
	    d = X(:,7);
	    % Fill array
	    % Replace fill with valid points.
	    di(t) = d;
	    fprintf('%d values.\n',length(t));
	end
	tmp(:,j) = di;
    end
    
    D = [D;tmp];
end

fprintf('Writing %s.\n',fnameout);
save(fnameout,'D','start','stop','chas','units');
fprintf('Wrote %s.\n',fnameout);

