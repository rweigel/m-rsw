setpaths;

if ~exist('filestr','var')
    filestr = 'options-1';
    fname = sprintf('mat/main_%s.mat',filestr);
    fprintf('main_log.m: Loading %s\n',fname);
    load(fname);
    fprintf('main_log.m: Loaded %s\n',fname);    
end

fname = sprintf('log/main_summary_log_%s.txt',filestr);
if exist(fname,'file'),delete(fname);end
diary(fname);

fprintf('________________________________________________________________\n');
fprintf('Options description: %s\n',opts.description);
fprintf('________________________________________________________________\n');
transferfnSummary(GBo,GBo_avg,'Model 0 - G/Bo');
transferfnSummary(GEo,GEo_avg,'Model 1 - G/Eo');
transferfnSummary(GE,GE_avg,'Model 2 - G/E');
transferfnSummary(GBa,GBa_avg,'Model 3 - G/E''');
transferfnSummary(GB,GB_avg,'Model 4 - G/B');
transferfnSummary(EB,EB_avg,'E/B')
transferfnSummary(GBoa,GBoa_avg,'G/Eo''')

if 0
    RSS2 = mean(squeeze(GE_avg.Mean.MSE(:,2,:)));
    RSS1 = mean(squeeze(GEo_avg.Mean.MSE(:,2,:)));
    p1 = 2;
    % 2*(length(GE_avg.Mean.fe)-1) is number of non-zero a(w) and b(w) parameters.
    % Multiply by 2 because a(w) and b(w) are complex.
    p2 = 4*(length(GE_avg.Mean.fe)-1); 
    n = 86400*size(GE_avg.Mean.MSE,3);
    F = ((RSS1 - RSS2)/(p2-p1))/(RSS2/(n-p2))

    df1 = p2 - p1;
    df2 = n - p2 - 1;
    p = 1 - fcdf(F,df1,df2)

    %AIC = 2k + n ln(RSS)
end

fprintf('main_log.m: Running bootstrap tests\n');
Nb = 10000;
var = 'PE';
m1 = squeeze(GEo_avg.Mean.(var)(1,2,:));
m2 = squeeze(GE_avg.Mean.(var)(1,2,:));
m3 = squeeze(GBa_avg.Mean.(var)(1,2,:));
m4 = squeeze(GB_avg.Mean.(var)(1,2,:));
b1 = bootstrp(Nb,@mean,m1);
b2 = bootstrp(Nb,@mean,m2);
b3 = bootstrp(Nb,@mean,m3);
b4 = bootstrp(Nb,@mean,m4);
I = find(b2-b1<0);
fprintf('p value to reject "Model 1 %s = Model 2 %s": %.3f\n',var,var,length(I)/Nb);
I = find(b3-b2<0);
fprintf('p value to reject "Model 2 %s = Model 3 %s": %.3f\n',var,var,length(I)/Nb);
I = find(b4-b3<0);
fprintf('p value to reject "Model 3 %s = Model 4 %s": %.3f\n',var,var,length(I)/Nb);

Reference = GEo_avg.Mean.MSE;
fn = fieldnames(GE_avg);
p = pad(fn);
for i = 1:length(fn)
    meth = fn{i};
    r = transpose(squeeze(Reference./GE_avg.(meth).MSE));
    rm = mean(r(:,2));
    rb = boot95(r(:,2));
    ra = mean(Reference(1,2,:),3)./mean(GE_avg.(meth).MSE(1,2,:),3);
    fprintf('Using %s %s:   <Model 1 (Eo) MSE/Model 2 (E) MSE>    = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',meth,p{i},rm,rb,ra);
end

fn = fieldnames(GBa_avg);
p = pad(fn);
for i = 1:length(fn)
    meth = fn{i};
    r = transpose(squeeze(Reference./GBa_avg.(meth).MSE));
    rm = mean(r(:,2));
    rb = boot95(r(:,2));
    ra = mean(Reference(1,2,:),3)./mean(GBa_avg.(meth).MSE(1,2,:),3);
    fprintf('Using %s %s:   <Model 1 (Eo) MSE/Model 3 (E'') MSE>   = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',meth,p{i},rm,rb,ra);
end

fn = fieldnames(GB_avg);
p = pad(fn);
for i = 1:length(fn)
    meth = fn{i};
    r = transpose(squeeze(Reference./GB_avg.(meth).MSE));
    rm = mean(r(:,2));
    rb = boot95(r(:,2));
    ra = mean(Reference(1,2,:),3)./mean(GB_avg.(meth).MSE(1,2,:),3);
    fprintf('Using %s %s:   <Model 1 (Eo) MSE/Model 4 (B) MSE>    = %4.2f +/- [%4.2f,%4.2f] (Alt. ratio = %4.2f)\n',meth,p{i},rm,rb,ra);
end

fprintf('________________________________________________________________\n');
diary off
