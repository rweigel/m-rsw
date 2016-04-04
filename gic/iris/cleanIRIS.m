function cleanIRIS(sta,start,stop,chas,units)

fname1 = sprintf('../data/iris/%s/data/%s-%s-original.mat',sta,sta,units);
fname2 = sprintf('../data/iris/%s/data/%s-%s-cleaned.mat',sta,sta,units);

fprintf('Reading %s.\n',fname1);
load(fname1);

if strmatch(sta,'WAB05','exact')
  D(1:95000,:) = NaN;
end

if strmatch(sta,'CON21','exact')
  D(1:63000,:) = NaN;
  D(1276912:1276916,2) = NaN;
  D(1276912:1276916,3) = NaN;
  delta1 = nanmean(D(1275000:end,3)) - nanmean(D(1:140000,3));
  D(1276000:end,3) = D(1276000:end,3) - delta1;

  if (0)
    t = [0:size(D,1)-1]/1000;
    plot(t,D(:,3)/1e6);
    grid on;
    keyboard
  end
end

if strmatch(sta,'CON20','exact')
  D(1:86400,:) = NaN;
end

if strmatch(sta,'UTN19','exact')
  D(1:86400,:) = NaN;
  D([1349808:1351450],1:3) = NaN;
end

if strmatch(sta,'ORF03','exact')
  t = [1:size(D,1)]/1000;
  delta1 = nanmean(D(850000:end,3))-nanmean(D(11000:848000,3));
  D(848000:end,3) = D(848000:end,3)-delta1;
  D(1:10400,3) = NaN;
  D(852455,5) = NaN;
  D(852480,5) = NaN;
  D(852486,5) = NaN;
  D(861374:861380,5) = NaN;  
end


if (0)
  t = [0:size(D,1)-1]/1000;
  plot(t,D(:,5)/1e6);
  grid on;
  keyboard
end


for i = 1:size(D,2)
  D(:,i) = D(:,i) - nanmean(D(:,i));
end

save(fname2,'D','sta','start','stop','chas');
fprintf('Wrote %s.\n',fname2);

