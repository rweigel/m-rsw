function cleanIRIS(sta,start,stop,chas)

fname1 = sprintf('../data/iris/%s/%s-original.mat',sta,sta);
fname2 = sprintf('../data/iris/%s/%s-cleaned.mat',sta,sta);

fprintf('Reading %s.\n',fname1);
load(fname1);

if strmatch(sta,'WAB05','exact')
  D(1:95000,:) = NaN;
end
%plot(D(:,4))
%keyboard;

save(fname2,'D','sta','start','stop','chas');
fprintf('Wrote %s.\n',fname2);

