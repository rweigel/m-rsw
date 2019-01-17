basedir = 'data/marshall/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_20131002 = importdata(sprintf('%sGIC_Data_131002_4_PC_BW.csv',basedir));
data_20131002.columns = {'H14_MRDG_T5_T1','H14_MRDG_T5_T2','H21_MRRE_T2_T1','H21_MRRE_T2_T2','T181_BWN_T3_T1','T181_BWN_T3_T2'};

t = [0:size(F1.data,1)-1]'/6;
figure(1);clf;
    plot(t,data_20131002.data)
    lh = legend(data_20131002.columns);
    set(lh,'Interpreter','none')
    ylabel('GIC [A]')
    xlabel('Minutes since 2013-10-02')
save(sprintf('%s20131002.mat',basedir),'data_20131002')    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_20150623 = importdata(sprintf('%sGIC_Data_150623_PC_BW.csv',basedir));
data_20150623.columns = {'H14_MRDG_T5_T1','H14_MRDG_T5_T2','H21_MRRE_T2_T1','H21_MRRE_T2_T2','T181_BWN_T3_T1','T181_BWN_T3_T2'};

t = [0:size(F2.data,1)-1]'/15;
figure(2);clf;
    plot(t,data_20150623.data)
    lh = legend(data_20150623.columns);
    set(lh,'Interpreter','none')
    ylabel('GIC [A]')
    xlabel('Minutes since 2015-06-23')
save(sprintf('%s20150623.mat',basedir),'data_20150623')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

