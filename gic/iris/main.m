% Instrument information: http://www.iris.washington.edu/mda/EM/MBB05
addpath('../../plot/')

sta = 'MBB05';
start = '2008-06-02';
stop  = '2011-05-27';
chas  = {'LFE','LFN','LFZ','LQE','LQN'};

sta = 'MBB05';
start = '2009-05-11';
stop  = '2011-05-27';
chas  = {'MFE','MFN','MFZ','MQE','MQN'};

sta = 'WYM20';
sta = 'WAB05';
sta = 'CAM05';
sta = 'MBB03';
sta = 'NVN08';

sta = 'UTN19';
sta = 'CON20';
sta = 'ORF03';
sta = 'CON21';
sta = 'ORF09';
sta = 'ORF10';

% Note: getIRISCatalog() does not work for stations with multiple
% instruments such as MBB05.
C = getIRISCatalog();
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
  error('Too many channels')
end

if strcmp(sta,'MBB03')
  start = '2010-10-25';
  stop = '2010-11-16';
end
if strcmp(sta,'MBB03')
  start = '2011-07-15';
  stop = '2011-08-13';
end

units = 'counts';
%units = 'natural';

getIRIS(sta,start,stop,chas,units);
prepIRIS(sta,start,stop,chas,units);
plotIRIS(sta,start,stop,chas,units,'original');
cleanIRIS(sta,start,stop,chas,units);
plotIRIS(sta,start,stop,chas,units,'cleaned');


