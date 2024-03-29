setpaths;
if 1 || ~exist('filestr','var')
    codever = 1;
    oos_aves = 0;
    filestr = sprintf('options-%d-v%d-o%d',rn,codever,oos_aves);
    fname = sprintf('data/jma/mat/main_%s.mat',filestr);
    fprintf('main.m: Loading %s\n',fname);
    load(fname);
    fprintf('main.m: Loaded %s\n',fname);    
end

writepng = 1;

plot_GIC_predictions;
plot_EB_predictions;

figprep(writepng,1000,500);
set(0,'DefaultAxesFontSize',14);
f = summaryPlotFunctions();

%f.compareHplots(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,filestr,writepng);
f.compareZplots(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,EB_avg.Mean,filestr,writepng);
f.comparePhiplots(GE_avg.Mean,GB_avg.Mean,EB_avg.Mean,filestr,writepng);
f.compareSN2(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,GBa_avg.Mean,'',filestr,writepng);
f.parameterHistograms(GEo,GEo_avg,filestr,writepng);
