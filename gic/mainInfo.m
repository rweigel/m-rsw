function Info = mainInfo(short)

switch short
 case 'WAB05'    
  long  = 'Arlington Heights, WA, USA';
  short = 'WAB05';
  agent = 'IRIS';
  ppd   = 86400;
  datadir = 'data';
 case 'MBB05'
  long  = 'Kentland Farm, Blacksburg, VA';
  short = 'MBB05';
  agent = 'IRIS';
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'PT';
 case 'IDE11'
  short  = 'IDE11';
  long   = short;
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
 case 'ORG10'
  short  = 'ORG10';
  long   = short;
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
 case 'WAE10'
  short  = 'WAE10';
  long   = short;
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  modelstr = 'CO1';
 case 'WAE09'
  long   = '';
  short  = 'WAE09';
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  modelstr = 'CO1';
 case 'grassridge'
  long  = 'Grassridge';
  short = 'grassridge';
  agent = 'SANSA';
  sfB   = [1,1,1];
  sfE   = [1,1]; 
  datadir = 'data-private';
  ppd = 24*60;
  modelstr = 'Q3';
  modelsf  = 100;
 case 'obidm'
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
 case 'obibmt'
  long  = 'Obib 100m Over from Wire';
  short = 'obibmt';
  agent = 'SANSA';
  % See labels used in data-private/Pierre/Software/MT_data_read.m
  sfB   = [1,1,1];
  sfE   = [1,1]; 
  modelstr = 'Q3';
  modelsf  = 10;
  ppd   = 86400;
 case 'kak'
  long  = 'Kakioka';
  short = 'kak';
  agent = 'JMA';
  sfB   = [1,1,1];
  sfE   = [1,1]; 
  modelstr = 'Q3';
  modelsf  = 1;
  ppd   = 86400;
 case 'mmb'
  long  = 'Memambetsu';
  short = 'mmb';
  agent = 'JMA';
  sfB   = [1,1,1];
  sfE   = [1,1]; 
  modelstr = 'Q3';
  modelsf  = 1;
  ppd   = 86400;
 case 'CON20'
  long   = 'Nipple Gulch, CO';
  short  = 'CON20';
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CL1';
 case 'ORF10'
  short  = 'ORF10';
  long   = short;
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  modelstr = 'CO1';
  Ikeep = [1:86400*5];
  hpNf = 1e4;
 case 'UTN19'
  long   = 'Browns Park, UT';
  short  = 'UTN19';
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CL1';
  Ikeep = [86400+1:86400*4];
  hpNf = 1e4;
 case 'MNF35'
  % Data does not look right
  long   = 'Buckhead Lake, MN';
  short  = 'MNF35';
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'IP1';
  Ikeep = [86400*2+1:86400*5];
  hpNf = 1e4;
 case 'NCS58'
  long   = 'Shocco Creek, NC';
  short  = 'NCS58';
  agent  = 'IRIS';
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'PT1';
  Ikeep = [86401:86400*6];
  hpNf = 1e4;
  hpNf = 0;
 case 'ORF09'
  % Use for paper
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
  Ikeep = [86400*2+1:86400*8];
  %Ikeep = [];
  hpNf = 1e4;
 case 'MNG35'
  % http://www.iris.washington.edu/mda/EM/MBB03
  % Use for paper?
  long   = 'Tyrone Prairie, MN';
  short  = 'MNG35';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'IP1';
  Ikeep = [86400*2+1:86400*6];
  hpNf = 1e4;
 case 'CON21'
  % http://www.iris.washington.edu/mda/EM/CON21
  % http://ds.iris.edu/spud/emtf
  % http://ds.iris.edu/spud/emtf/1349196
  % Use for paper
  long   = 'Slater Creek, CO';
  short  = 'CON21';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CL1';
  Ikeep = [86400*5+1:86400*9];
  hpNf = 1e4;
  % No data available for second link.
  % http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=CON21&loc=--&cha=LQE&starttime=2011-07-21T00:00:00&endtime=2011-07-21T23:59:59&output=plot
  % http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=CON21&correct=true&loc=--&cha=LQE&starttime=2011-07-21T00:00:00&endtime=2011-07-21T23:59:59&output=plot
 case 'RET54'
  % Use for paper
  % http://www.iris.washington.edu/mda/EM/RET54
  % http://ds.iris.edu/spud/emtf
  % http://ds.iris.edu/spud/emtf/11455474  
  short  = 'RET54';
  long   = 'Buffalo Cove, NC';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  % http://service.iris.edu/irisws/sacpz/1/query?net=EM&sta=RET54&loc=*&cha=*&starttime=2015-12-07T21:16:03&endtime=2015-12-19T18:40:44
  sfE   = [3.014e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'PT1';
  Ikeep = [86400*2+1:86400*6];
  hpNf = 1e4;
% Second link did not work 
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=RET54&loc=--&cha=LQE&starttime=2015-12-09T00:00:00&endtime=2015-12-09T23:59:59&output=plot
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=RET54&loc=--&correct=true&cha=LQE&starttime=2015-12-09T00:00:00&endtime=2015-12-09T23:59:59&output=plot
 case 'ORF03'
  % http://www.iris.washington.edu/mda/EM/ORF03
  % http://ds.iris.edu/spud/emtf
  % http://ds.iris.edu/spud/emtf/1422890
  % Use for paper
  short  = 'ORF03';
  long   = 'Jewell, OR';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'PB2';
  Ikeep = [86400*12+1:86400*16];
  hpNf = 1e4;
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&correct=true&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot
 case 'GAA54'
  % http://www.iris.washington.edu/mda/EM/GAA54
  % http://ds.iris.edu/spud/emtf
  % http://ds.iris.edu/spud/emtf/11444610
  % Use for paper
  long   = 'Gator Slide, GA';
  short  = 'GAA54';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CP2';
  Ikeep = [86400*2+1:86400*6];
  hpNf = 1e4;
 case 'IAK39'
  % http://www.iris.washington.edu/mda/EM/CON21
  % Use for paper
  long   = 'Ham Marsh, IA';
  short  = 'IAK39';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'IP-1';
  Ikeep = [86400*10+1:86400*14];
  hpNf = 1e4;
 case 'WII42'
  % http://www.iris.washington.edu/mda/EM/CON21
  % Use for paper
  long   = 'Lawrence Creek, WI';
  short  = 'WII42';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'IP-1';
  Ikeep = [86400*6+1:86400*10];
  hpNf = 1e4;
 case 'WII40'
  % http://www.iris.washington.edu/mda/EM/CON21
  % Use for paper
  long   = 'Moore Creek, WI';
  short  = 'WII40';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'IP-1';
  Ikeep = [86400*1+1:86400*4];
  hpNf = 1e4;
 case 'COO20'
  % http://www.iris.washington.edu/mda/EM/CON21
  % Use for paper
  long   = 'Sagebrush Draw, CO';
  short  = 'COO20';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CL-1';
  Ikeep = [86400*5+1:86400*9];
  hpNf = 1e4;
 case 'UTP17'
  % http://www.iris.washington.edu/mda/EM/UTP17
  % Use for paper
  long   = 'The Cove, UT';
  short  = 'UTP17';
  agent  = 'IRIS';
  % 1e-11 to go from counts to T; 1e9 to convert from T to nT.
  sfB   = [1e-11,1e-11,1e-11]*1e9;
  % 3.0e-5 to go from counts to mV/km from iris/scale/scalefactor.m analysis.
  sfE   = [3.0e-5,3.0e-5];
  sfE   = [2.44e-5,2.44e-5];
  ppd   = 86400;
  datadir = 'data';
  modelstr = 'CL-1';
  Ikeep = [86400*1+1:86400*5];
  hpNf = 1e4;
 otherwise
  error(sprintf('Site with ID = %s not found',short));
end


Info = struct(...
    'long',long,...
    'short',short,...
    'agent',agent,...
    'sfB',sfB,...
    'sfE',sfE,...
    'ppd',ppd,...
    'datadir',datadir,...
    'modelstr',modelstr,...
    'Ikeep',Ikeep,...
    'hpNf',hpNf);
