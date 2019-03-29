%function main(rn)

clear;
rn = 1;

setpaths;

writepng   = 0; % Write png and pdf files
intmplot   = 0; % Intermediate plots
regenfiles = 0; % If 0, used cached E, B, and GIC .mat files
oos_aves   = 0; % Compute Out-of-Sample averages for metrics

% All runs
if nargin == 0
    for rn = 1:4
        main(rn);
    end
    return;
end

dirfig = sprintf('figures/combined');
if ~exist(dirfig,'dir')
    mkdir(dirfig);
end

opts = main_options(rn);
filestr = opts.filestr;

% removed 20060818 due to large segment of bad E
% removed 20060411 and 20060412 due to baseline shift in E
% removed 20060402 due to baseline shift in GIC
dateos = {'20060403','20060819','20061107','20061214','20060805','20060725','20071118','20071122','20061128','20061201'};
datefs = {'20060410','20060821','20061112','20061215','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    0    ,    17    ,    32    ,    66     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];

opts.data = struct();
opts.data.dateos = dateos;
opts.data.datefs = datefs;
opts.data.dts    = dts;

fname = sprintf('log/main_log_%s.txt',filestr);
if exist(fname,'file'),delete(fname);end
diary(fname);

fprintf('------------------------------------------------------------------------\n')
fprintf('Options set #%d\n',rn);
fprintf('------------------------------------------------------------------------\n')
printstruct(opts)
fprintf('------------------------------------------------------------------------\n')

if opts.td.detrend
    [GICt,Et,Bt,GICa,Ea,Ba] = computeTrend(GIC,E,B);
end

di = 0;
for i = 1:length(dateos)
%for i = 7:length(dateos)
    
    fprintf('------------------------------------------------------------------------\n')
    fprintf('Continuous data interval %d of %d. Start date: %s\n',i,length(dateos),dateos{i});
    fprintf('------------------------------------------------------------------------\n')

    dateo = dateos{i};
    datef = datefs{i};
    dt    = dts(i);

    i = i-di;
    if (datenum(datef,'yyyymmdd')-datenum(dateo,'yyyymmdd')+1)*86400 < opts.td.window.width
        di = di+1;
        fprintf('main.m: Skipping interval %s-%s due to opts.td.window.width\n',dateo,datef);
        continue;
    end

    % Read 1s B data for remote reference
    [~,~,tBr,Br] = prep_EB(dateo,datef,'kak',regenfiles); 

    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,'mmb',regenfiles); 

    % Read GIC data from Watari
    % First column is raw, second is 1 Hz filtered.
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        

    if opts.td.detrend
        % Remove daily trend
        E = removeTrend(E,Et);
        B = removeTrend(B,Bt);
        Br = removeTrend(B,Brt);        
        GIC = removeTrend(GIC,GICt);
    end
    
    B(:,:,2) = Br;
    
    % Correct for clock drift
    %tGIC = tGIC + dt/86400;

    if intmplot
        if i == 1
            close all;
        end
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC raw','GIC 1 Hz filtered'});
    end

    E    = despikeE(E);
    GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
    GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

    [t,E,B] = timealign(tGIC,tE,E,B);

    if intmplot
        plot_raw(t,GIC(:,2),t,E,t,B,dateo,writepng,{'GIC'});
    end

    [GIC,E,B] = removemean(GIC,E,B);

    if 0 && strcmp('pca',opts.td.transform)
        if i == 1
            [RE,DE] = eig(cov(E(:,1:2)));
            [RB,DB] = eig(cov(B(:,1:2)));            
        end
        B(:,1:2) = fliplr((RB*B(:,1:2)')');
        E(:,1:2) = fliplr((RE*E(:,1:2)')');
    end
    
    if intmplot
        plot_timeseries(dateo,intervalno,filestr,writepng);
        plot_correlations(dateo,intervalno,filestr,writepng);
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end

    fprintf('main.m: %s G/Eo\n',dateo);
    GEoc{i} = transferfnConst(E,GIC,opts,t);

    fprintf('main.m: %s G/Bo\n',dateo);
    GBoc{i} = transferfnConst(B(:,1:2,1),GIC,opts,t);
    
    fprintf('main.m: %s G/E\n',dateo);
    GEc{i} = transferfnFD(E,GIC,opts,t);
    
    fprintf('main.m: %s G/B\n',dateo);
    GBc{i} = transferfnFD(B(:,1:2,1),GIC,opts,t);
    
    fprintf('main.m: %s E/B\n',dateo);
    EBc{i} = transferfnFD(B(:,1:2,1),E,opts,t);

    %Need to re-implement this in transferfnFD.m. Lost verion that had it.
    %fprintf('main.m: %s E/B Remote Reference\n',dateo);
    %topts = opts;
    %topts.fd.regression.method = 1; % Remote reference not implemented for other methods.
    %EBrc{i} = transferfnFD(B(:,1:2,:),E,topts,t);
    
    fprintf('main.m: %s G/E''\n',dateo);
    GBac{i} = transferfnAlt(GEc{i},EBc{i},opts,t);

    fprintf('main.m: %s G/Eo''\n',dateo);
    Eprime = [];
    GICx = [];
    for zz = 1:size(EBc{i}.Predicted,3)
        Eprime = [Eprime;EBc{i}.Predicted(:,:,zz)];
        %GICx   = [GICx;EBc{i}.Out(:,:,zz)];
    end
    GBoac{i} = transferfnConst(Eprime,GIC,opts,t);
    
end

GEo  = transferfnCombine(GEoc);
GBo  = transferfnCombine(GBoc);
GE   = transferfnCombine(GEc);
GB   = transferfnCombine(GBc);
EB   = transferfnCombine(EBc);
%EBr  = transferfnCombine(EBrc);
GBa  = transferfnCombine(GBac);
GBoa = transferfnCombine(GBoac);

fprintf('________________________________________________________________\n');

if oos_aves
    % Requires Nintervals = size(GE.Z,3) more calculations. Will give almost
    % identical results if Nintervals is large.
    transferfnAverageFunction = @transferfnAverageOutofSample;
else
    transferfnAverageFunction = @transferfnAverage;    
end

fprintf('main.m: G/Eo\n');
GEo_avg = transferfnAverageFunction(GEo,opts);
transferfnSummary(GEo,GEo_avg,'Model 1 - G/Eo');

fprintf('main.m: G/E''o\n');
GBoa_avg = transferfnAverageFunction(GBoa,opts);
transferfnSummary(GBoa,GBoa_avg,'Model 1'' - G/E''o');

fprintf('main.m: G/Bo\n');
GBo_avg = transferfnAverageFunction(GBo,opts);
transferfnSummary(GBo,GBo_avg,'Model 0 - G/Bo');

fprintf('main.m: G/E\n');
GE_avg = transferfnAverageFunction(GE,opts);
%transferfnSummary(GE,GE_avg,'Model 2 - G/E');

fprintf('main.m: G/E No stack\n');
GE_ns = transferfnFD2(GE,opts);
GE_avg.NoStack_OLS = GE_ns.OLS;
GE_avg.NoStack_Robust1 = GE_ns.Robust1;
GE_avg.NoStack_Robust2 = GE_ns.Robust2;
transferfnSummary(GE,GE_avg,'G/E No stack');

fprintf('main.m: G/B\n');
GB_avg = transferfnAverageFunction(GB,opts);
%transferfnSummary(GB,GB_avg,'Model 4 - G/B');

fprintf('main.m: G/B No stack\n');
GB_ns = transferfnFD2(GB,opts);
GB_avg.NoStack_OLS = GB_ns.OLS;
GB_avg.NoStack_Robust1 = GB_ns.Robust1;
GB_avg.NoStack_Robust2 = GB_ns.Robust2;
transferfnSummary(GB,GB_avg,'G/B');

fprintf('main.m: G/E''\n');
GBa_avg = transferfnAverageFunction(GBa,opts);
transferfnSummary(GBa,GBa_avg,'Model 3 - G/E''');

fprintf('main.m: E/B\n');
EB_avg  = transferfnAverageFunction(EB,opts);
EB_avg.Fuji = transferfnFujii(EB,'mmb',opts);
%transferfnSummary(EB,EB_avg,'E/B')

fprintf('main.m: E/B No stack\n');
EB_ns = transferfnFD2(EB,opts);
EB_avg.NoStack_OLS = EB_ns.OLS;
EB_avg.NoStack_Robust1 = EB_ns.Robust1;
EB_avg.NoStack_Robust2 = EB_ns.Robust2;
transferfnSummary(EB,EB_avg,'E/B');

%fprintf('main.m: E/B Remote Reference\n');
%EBr_avg = transferfnAverageFunction(EBr,opts);
%transferfnSummary(EBr,EBr_avg,'E/B Remote Reference')

%savevars = {'opts','GEo','GBo','GE','GB','EB','EBr','GBa','GEo_avg','GBo_avg','GE_avg','GB_avg','EB_avg','EBr_avg','GBa_avg'};
savevars = {'opts','GEo','GBo','GE','GB','EB','GBa','GEo_avg','GBo_avg','GE_avg','GB_avg','EB_avg','GBa_avg'};
fname = sprintf('mat/main_%s.mat',filestr);
fprintf('main.m: Saving %s\n',fname);
save(fname,savevars{:});
fprintf('main.m: Saved %s\n',fname);

diary off

main_log;

main_plots;
