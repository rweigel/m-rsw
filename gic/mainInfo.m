%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Arlington Heights, WA, USA';
short = 'WAB05';
agent = 'IRIS';
ppd   = 86400;
datadir = 'data';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Kentland Farm, Blacksburg, VA';
short = 'MBB05';
agent = 'IRIS';
ppd   = 86400;
datadir = 'data';
modelstr = 'PT';
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
ppd   = 86400;
datadir = 'data';
modelstr = 'CL1';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
short  = 'IDE11';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
short  = 'ORG10';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
short  = 'WAE10';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
modelstr = 'CO1';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
long   = '';
short  = 'WAE09';
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
modelstr = 'CO1';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
short  = 'ORF03';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
modelstr = 'PB2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Grassridge';
short = 'grassridge';
agent = 'SANSA';
% See labels used in data-private/Pierre/Software/MT_data_read.m
sfB   = [1,1,1];
% Labels claim mu V/m (seems it should be mV/km, which I used)
sfE   = [1,1]; 
datadir = 'data-private';
ppd = 24*60;
modelstr = 'Q3';
modelsf  = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib Under Wire';
short = 'obibdm';
agent = 'SANSA';
% See labels used in data-private/Pierre/Software/MT_data_read.m
sfB   = [1,1,1];
sfE   = [1,1]; 
datadir = 'data';
modelstr = 'Q3';
modelsf  = 10;
ppd   = 86400;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Obib 100m Over from Wire';
short = 'obibmt';
agent = 'SANSA';
% See labels used in data-private/Pierre/Software/MT_data_read.m
sfB   = [1,1,1];
sfE   = [1,1]; 
modelstr = 'Q3';
modelsf  = 10;
ppd   = 86400;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Kakioka';
short = 'kak';
agent = 'JMA';
sfB   = [1,1,1];
sfE   = [1,1]; 
modelstr = 'Q3';
modelsf  = 1;
ppd   = 86400;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long  = 'Memambetsu';
short = 'mmb';
agent = 'JMA';
sfB   = [1,1,1];
sfE   = [1,1]; 
modelstr = 'Q3';
modelsf  = 1;
ppd   = 86400;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/IDF11
short  = 'IDF11';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF03
short  = 'ORF03';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
modelstr = 'PB2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&correct=true&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-10T23:59:59&output=plot
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-10T23:59:59&output=plot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/CON20
long   = 'Nipple Gulch, CO';
short  = 'CON20';
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
modelstr = 'CL1';
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
ppd   = 86400;
datadir = 'data';
modelstr = 'CL1';
Ikeep = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF10
short  = 'ORF10';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
modelstr = 'CO1';
%Ikeep = [1:86400*6];
Ikeep = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.iris.washington.edu/mda/EM/ORF09
short  = 'ORF09';
long   = short;
agent  = 'IRIS';
% 1e-11 to go from counts to T; 1e9 to convert from T to nT.
sfB   = [1e-11,1e-11,1e-11]*1e9;
% 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
sfE   = [3.0e-5,3.0e-5];
ppd   = 86400;
datadir = 'data';
modelstr = 'CO1';
%Ikeep = [1:86400*5];
Ikeep = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
