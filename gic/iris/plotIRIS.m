function plotIRIS(sta,start,stop,chas,units,type,overlay)

if (nargin < 7)
  overlay = 0;
end

if (nargin < 6)
  type = 'original';
end

startdn = datenum(start);
stopdn  = datenum(stop);
ds1 = datestr(start,29);
ds2 = datestr(stop,29);

dir = sprintf('../data/iris/%s',sta);
dir2 = sprintf('../data/iris/%s/figures',sta);

if ~exist(dir2)
    system(sprintf('mkdir -p %s',dir2));
end

Nc = length(chas); % chas input is overwritten by variable in file
fname = sprintf('%s/data/%s-%s-%s.mat',dir,sta,units,type);
fprintf('Reading %s.\n',fname);
load(fname);

for j = 1:Nc
  figurex(j);
  if (overlay == 0)
      clf;
  else
      hold on;
  end
  t = startdn + [0:size(D,1)-1]/86400;
  plot(t,D(:,j),'k');
  legend([chas{j},' [Counts]']);
  datetick('x','mmm dd');
  title(sprintf('%s',sta));
  grid on;
  vertline([startdn:1:stopdn+1],[0.85,0.85,0.85],1,':');
  fname = sprintf('../data/iris/%s/figures/%s_%s-%s-%s.png',...
		  sta,sta,chas{j},units,type);
  print('-dpng',fname);
  fprintf('Wrote %s.\n',fname);
end
