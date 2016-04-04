function prepIRIS(sta,start,stop,chas,units)

startdn = datenum(start);
stopdn  = datenum(stop);
dir = '../data/iris';

fnameout = sprintf('%s/%s/data/%s-%s-original.mat',dir,sta,sta,units);

if exist(fnameout)
  return
end

D = [];
for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        fname = sprintf('%s/%s/data/%s_%s_%s-%s.mat',dir,sta,sta,chas{j},ds,units);

	di = repmat(NaN,86400,1);
	ti = [0:86400-1]';
	
	if ~exist(fname)
	  fprintf('Not found.  Using fills for %s.\n',fname);
	else
	  fprintf('Reading %s. ',fname);
	  load(fname);
	  dnx = datenum(X(:,1:3));
	  I = find(dnx == i);
	  X = X(I,:);
	  % 1 + second of day
	  t = 1 + X(:,4)*60*60+X(:,5)*60+X(:,6);
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

save(fnameout,'D','start','stop','chas','units');
fprintf('Wrote %s.\n',fnameout);

