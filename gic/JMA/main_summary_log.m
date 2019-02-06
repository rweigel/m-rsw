setpaths;

if ~exist('filestr','var')
    filestr = 'options-1';
    fname = sprintf('mat/main_%s.mat',filestr);
    fprintf('main.m: Loading %s\n',fname);
    load(fname);
    fprintf('main.m: Loaded %s\n',fname);    
end

fname = sprintf('log/main_summary_log_%s.txt',filestr);
if exist(fname,'file'),delete(fname);end
diary(fname);

fprintf('________________________________________________________________\n');

transferfnSummary(GBo,GBo_avg,'Model 0 - G/Bo');
transferfnSummary(GEo,GEo_avg,'Model 1 - G/Eo');
transferfnSummary(GE,GE_avg,'Model 2 - G/E');
transferfnSummary(GBa,GBa_avg,'Model 3 - G/E''');
transferfnSummary(GB,GB_avg,'Model 4 - G/B');
transferfnSummary(EB,EB_avg,'E/B')

r = transpose(squeeze(GEo_avg.MSE./GE_avg.MSE));
rm = mean(r(:,2));
rb = boot95(r(:,2));
ra = mean(GEo_avg.MSE(1,2,:),3)./mean(GE_avg.MSE(1,2,:),3);
fprintf('<Model 1 (Eo) MSE/Model 2 (E) MSE>   = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',rm,rb,ra);

r = transpose(squeeze(GEo_avg.MSE./GBa_avg.MSE));
rm = mean(r(:,2));
rb = boot95(r(:,2));
ra = mean(GEo_avg.MSE(1,2,:),3)./mean(GBa_avg.MSE(1,2,:),3);
fprintf('<Model 1 (Eo) MSE/Model 3 (E'') MSE>  = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',rm,rb,ra);

r = transpose(squeeze(GEo_avg.MSE./GB_avg.MSE));
rm = mean(r(:,2));
rb = boot95(r(:,2));
ra = mean(GEo_avg.MSE(1,2,:),3)./mean(GB_avg.MSE(1,2,:),3);
fprintf('<Model 1 (Eo) MSE/Model 4 (B) MSE>   = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',rm,rb,ra);

fprintf('________________________________________________________________\n');
diary off
