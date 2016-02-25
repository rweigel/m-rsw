function plotIRIS(sta,start,stop,chas,type)

if (nargin < 5)
  type = 'original';
end

startdn = datenum(start);
stopdn  = datenum(stop);
ds1 = datestr(start,29);
ds2 = datestr(stop,29);

fname = sprintf('../data/iris/%s/%s-%s.mat',sta,sta,type);
fprintf('Reading %s.\n',fname);
load(fname);

for j = 1:5
  figure(j);clf;
  t = startdn + [0:size(D,1)-1]/86400;
  if (i < 4)
    plot(t,D(:,j));
    legend([chas{j},' [Counts]']);
    else
    plot(t,D(:,j));
    legend([chas{j},' [Counts]']);
  end
  set(gca,'XTick',[startdn:1:stopdn])
  datetick('x','mmm dd');
  set(gca,'XTickLabelRotation',45)

  title(sprintf('Station: %s; Start Date: %s',sta,start));
  grid on;
  fname = sprintf('../data/iris/%s/%s_%s-%s.png',...
		  sta,sta,chas{j},type);
  print('-dpng',fname);
  fprintf('Wrote %s.\n',fname);
end

