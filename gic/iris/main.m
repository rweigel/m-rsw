% Instrument information: http://www.iris.washington.edu/mda/EM/MBB05
addpath('../../plot/')

if (0)
sta = 'MBB05';
start = '2008-06-02';
stop  = '2011-05-27';
chas  = {'LFE','LFN','LFZ','LQE','LQN'};

sta = 'MBB05';
start = '2009-05-11';
stop  = '2011-05-27';
chas  = {'MFE','MFN','MFZ','MQE','MQN'};
end

% http://ds.iris.edu/gmap/_US-MT-TA

sta = 'WYM20';
sta = 'WAB05';
sta = 'CAM05';
sta = 'NVN08';
sta = 'UTN19';
sta = 'CON20';
sta = 'CON21';
sta = 'ORF03';

sta = 'ORF09';
sta = 'ORF10';
sta = 'MBB03';
sta = 'ORK02';
sta = 'CAQ03';
sta = 'NCS58';
sta = 'MNG35';
sta = 'GAA54';
sta = 'IAK39';
sta = 'WII42';
sta = 'WII41';
sta = 'WII40';
sta = 'UTP18'; % http://ds.iris.edu/spud/emtf/1362488
sta = 'COO20'; % http://ds.iris.edu/spud/emtf/1349640
sta = 'UTP17'; 
sta = 'RET54';


sta = 'NEK25'; % http://ds.iris.edu/spud/emtf/17328740
sta = 'NEK26'; % http://ds.iris.edu/spud/emtf/17328962
sta = 'NEK27'; % http://ds.iris.edu/spud/emtf/17329184
sta = 'NEK28'; % http://ds.iris.edu/spud/emtf/17329406
sta = 'NEK29'; % http://ds.iris.edu/spud/emtf/17329628
sta = 'NEK30';
sta = 'NEK31';
sta = 'NEK32';

%sta = 'MBB02';
%sta = 'MBB01';

sta = 'NEK28';
sta = 'NEK29';
sta = 'NEK27';
sta = 'NEK25';

sta = 'VAQ57'; % http://ds.iris.edu/spud/emtf/15014349
sta = 'VAQ58'; % http://ds.iris.edu/spud/emtf/15014571
sta = 'VAQ59'; % http://ds.iris.edu/spud/emtf/15014793



% Note: getIRISCatalog() does not work for stations with multiple
% instruments such as MBB05.
update_catalog = 0;
C = getIRISCatalog(update_catalog);
for i = 1:length(C)
    if strmatch(sta,C{i},'exact')
        start = C{i}{2}(1:10);
        stop = C{i}{3}(1:10);
        chas = C{i}(4:end);
        break
    end
end

chas = unique(chas);
if (length(chas) > 5)
  error('Too many channels.')
end

units = 'counts';
%units = 'natural'; % Data is often missing when this selected. See
% scale/scalefactors.m

getIRIS(sta,start,stop,chas,units);
prepIRIS(sta,start,stop,chas,units);
plotIRIS(sta,start,stop,chas,units,'original');
cleanIRIS(sta,start,stop,chas,units);
plotIRIS(sta,start,stop,chas,units,'cleaned');


