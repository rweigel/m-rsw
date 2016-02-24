
type = 'cleaned';

ds1 = datestr(start,29);
ds2 = datestr(stop,29);

fname = sprintf('../data/iris/%s/%s_%s_%s-%s.mat',sta,sta,ds1,ds2,type);
fprintf('Reading %s.\n',fname);
load(fname);

for i = 1:size(D,2)
  D(:,i) = D(:,i) - nanmean(D(:,i));
  Ig = find(~isnan(D(:,i)));
  tmp = D(Ig,i);
  tmpi = interp1([1:length(tmp)]',tmp,[1:size(D,1)]');
  tmpi(isnan(tmpi)) = 0;
  Di(:,i) = tmpi;
end

% Raw periodograms
ftX = fft(Di);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;
pX  = pX(1:length(f),:);

figure(2);
  loglog(f,pX)
  legend('B_x','B_y','B_z','E_x','E_y');