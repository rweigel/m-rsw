clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');
addpath('./misc');

writeimgs = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib Under Wire (SANSA)';
short = 'obibdm';
agent = 'SANSA';
%start = '06-Jul-2013 11:03:00';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib 100m Over from Wire (SANSA)';
short = 'obibmt';
agent = 'SANSA';
%start = '06-Jul-2013 14:15:00';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

base   = 'SPUD_bundle_2016-03-23T17.38.28';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Arlington Heights, WA, USA';
short = 'WAB05';
agent = 'IRIS';
base  = 'SPUD_bundle_2016-03-23T17.38.28';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Kentland Farm, Blacksburg, VA';
short = 'MBB05';
agent = 'IRIS';
base  = 'SPUD_bundle_2016-03-23T17.38.28';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/UNT19
long   = 'Browns Park, UT';
short  = 'UTN19';
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/CON20
long   = 'Nipple Gulch, CO';
short  = 'CON20';
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/CON21
long   = 'Slater Creek, CO';
short  = 'CON21';
agent  = 'IRIS';

% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
long   = '';
short  = 'ORF03';
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('main: Working on %s\n',short);

% Read data
[B,dB,E,dn]  = mainPrepare(short, agent);

% Scale data
for i = 1:size(B,2)
  B(:,i)  = B(:,i)*sfB(i);
  dB(:,i) = dB(:,i)*sfB(i);
  ifB(i) = find(~isnan(B(:,i)),1,'first'); % First non-NaN
  ilB(i) = find(~isnan(B(:,i)),1,'last');  % Last non-NaN
end
for i = 1:size(E,2)
  E(:,i) = E(:,i)*sfE(i); 
  ifE(i) = find(~isnan(E(:,i)),1,'first'); % First non-NaN
  ilE(i) = find(~isnan(E(:,i)),1,'last');  % Last non-NaN
end

io= max([ifB,ifE]);
il = min([ilB,ilE]) - 1; % -1 so dB has no NaNs.

% Remove first and last day (for now).
B  = B([io:il],:);
dB = dB([io:il],:);
E  = E([io:il],:);
dn = dn([io:il]);

% Interpolate over bad points
for i = 1:size(B,2)
  ti = [1:size(B,1)]';
  yi = B(:,i);
  Ig = find(isnan(yi) == 0);
  Nnan = size(B,1)-length(Ig);
  Bnaninfo(1,i) = Nnan;
  Bnaninfo(2,i) = max(diff(Ig));
  fprintf('Found %d NaNs in component %d of B. ',Nnan,i);
  fprintf('Max gap = %d\n',Bnaninfo(2,i));
  Bi(:,i) = interp1(ti(Ig),yi(Ig),ti);
end
for i = 1:size(dB,2)
  ti = [1:size(dB,1)]';
  yi = dB(:,i);
  Ig = find(isnan(yi) == 0);
  dBnaninfo(1,i) = Nnan;
  dBnaninfo(2,i) = max(diff(Ig));
  fprintf('Found %d NaNs in component %d of dB. ',Nnan,i);
  fprintf('Max gap = %d\n',Bnaninfo(2,i));
  dBi(:,i) = interp1(ti(Ig),yi(Ig),ti);
end
for i = 1:size(E,2)
  ti = [1:size(E,1)]';
  yi = E(:,i);
  Ig = find(isnan(yi) == 0);
  Enaninfo(1,i) = length(Ig);
  Enaninfo(2,i) = max(diff(Ig));
  Nnan = size(B,1)-length(Ig);
  Enaninfo(1,i) = Nnan;
  Enaninfo(2,i) = max(diff(Ig));
  fprintf('Found %d NaNs in component %d of E. ',Nnan,i);
  fprintf('Max gap = %d\n',Bnaninfo(2,i));
  Ei(:,i) = interp1(ti(Ig),yi(Ig),ti);
end

B = Bi;
dB = dBi;
E = Ei;

[f,pX,fA,pA,p] = mainCompute(B,dB,E);

fname = sprintf('data/%s/%s/main_%s',lower(agent),short,short);
fprintf('main: Saving %s.mat\n',fname);
save(fname);

mainPlot
mainZ
mainZPlot

