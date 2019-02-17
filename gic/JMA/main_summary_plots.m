setpaths;
if ~exist('filestr','var')
    filestr  = 'options-1';
    writepng = 0;
    fname = sprintf('mat/main_%s.mat',filestr);
    fprintf('main.m: Loading %s\n',fname);
    load(fname);
    fprintf('main.m: Loaded %s\n',fname);    
end

parameterhistograms(GEo,GEo_avg,filestr,writepng);

plot_model_summary(GEo_avg,GE_avg,GBo_avg,GB_avg,GBa_avg,EB_avg,filestr,writepng);

