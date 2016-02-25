% Instrument information: http://www.iris.washington.edu/mda/EM/MBB05
sta = 'MBB05';
start = '2008-06-02';
stop  = '2011-05-27';
chas  = {'LFE','LFN','LFZ','LQE','LQN'};

sta = 'MBB05';
start = '2009-05-11';
stop  = '2011-05-27';
chas  = {'MFE','MFN','MFZ','MQE','MQN'};

sta = 'WYH18';
% Instrument information: http://www.iris.washington.edu/mda/EM/MBB05
% http://ds.iris.edu/spud/emtf/1331436
% XML
% http://ds.iris.edu/spudservice/data/1331435

sta = 'WAB05';
% http://ds.iris.edu/spud/emtf/1428884
% XML
% http://ds.iris.edu/spudservice/data/1428884

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

getIRIS(sta,start,stop,chas)
prepIRIS(sta,start,stop,chas)
plotIRIS(sta,start,stop,chas,'original')
cleanIRIS(sta,start,stop,chas)
plotIRIS(sta,start,stop,chas,'cleaned')


