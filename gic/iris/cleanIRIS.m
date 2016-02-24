function cleanIRIS(sta,start,stop,chas)

startdn = datenum(start);
stopdn  = datenum(stop);
ds1 = datestr(start,29);
ds2 = datestr(stop,29);

fname = sprintf('../data/iris/%s/%s_%s_%s-original.mat',sta,sta,ds1,ds2);
fname2 = sprintf('../data/iris/%s/%s_%s_%s-cleaned.mat',sta,sta,ds1,ds2);

fprintf('Reading %s.\n',fname);
load(fname);

if strmatch(sta,'WAB05','exact')
  D(1:95000,:) = NaN;
end
%plot(D(:,4))
%keyboard;

save(fname2,'D','sta','start','stop','chas');
fprintf('Wrote %s.\n',fname2);

