function prepIRIS(sta,start,stop,chas)

startdn = datenum(start);
stopdn  = datenum(stop);
dir = '../data/iris';

fnameout = sprintf('%s/%s/%s_%s_%s.mat',dir,sta,sta,start,stop);

if exist(fnameout)
  return
end

D = [];
for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        fname = sprintf('%s/%s/%s_%s_%s.mat',dir,sta,sta,chas{j},ds);

	di = repmat(NaN,86400,1);
	ti = [0:86400-1]';

	if ~exist(fname)
	  fprintf('Not found.  Using fills for %s.\n',fname);
	else
	  fprintf('Reading %s. ',fname);
	  load(fname);
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

save(fnameout,'D');
fprintf('Wrote %s.\n',fname);

