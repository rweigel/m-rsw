function plotIRIS(sta,start,stop,chas)

startdn = datenum(start);
stopdn  = datenum(stop);

for j = 1:5
  ds1 = datestr(start,29);
  ds2 = datestr(stop,29);
  fname = sprintf('../data/iris/%s/%s_%s_%s.mat',sta,sta,ds1,ds2);
  load(fname);
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

  title(sprintf('Start Date: %s',start));
  grid on;
  fname = sprintf('../data/iris/%s/%s_%s_%s_%s.png',sta,sta,chas{j},ds1,ds2);
  print('-dpng',fname);
  fprintf('Wrote %s.\n',fname);
end

