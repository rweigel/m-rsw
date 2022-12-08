function main(rn)

setpaths;

intmplot   = 0; % Intermediate plots
writepng   = 1; % Write png and pdf files for intermediate plots
regenfiles = 0; % If 0, used cached E, B, and GIC .mat files
oos_aves   = 0; % Compute Out-of-Sample averages for metrics
codever    = 1; % 0 corresponds to original submission. 
                % 1 corresponds to corrections made to prep_EB.m (signs
                % were dropped by regex - this clipped some E values and
                % reversed sign of B).

% All runs
if nargin == 0
    for rn = 1:6
        main(rn);
    end
    return;
end

close all;
opts = main_options(rn);
filestr = sprintf('%s-v%d-o%d',opts.filestr,codever,oos_aves);
fnamelog = sprintf('log/main_log_%s.txt',filestr);

if exist(fnamelog,'file')
    delete(fnamelog);
end
diary(fnamelog);

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

fprintf('------------------------------------------------------------------------\n')
fprintf('Options set #%d\n',rn);
fprintf('------------------------------------------------------------------------\n')
printstruct(opts)
fprintf('------------------------------------------------------------------------\n')

if 0
    regenfiles = 1;
    for i = 1:length(dateos)
        figure(i);clf;
        % Read 1s E and B data from Kyoto
        [tE,E,tB,B] = prep_EB(dateos{i},datefs{i},'mmb',regenfiles,0); 
        subplot(2,1,1);
            plot(tE,E);
            datetick('x');        

        [tE,E,tB,B] = prep_EB(dateos{i},datefs{i},'mmb',regenfiles,1); 
        subplot(2,1,2);
            plot(tE,E);
            datetick('x');

        drawnow;
    end
end

di = 0;
for i = 1:length(dateos)
%for i = 7:length(dateos)
%for i = 1:1
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
    %[~,~,tBr,Br] = prep_EB(dateo,datef,'kak',regenfiles); 

    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,'mmb',regenfiles,codever); 

    % Read GIC data from Watari
    % First column is raw, second is 1 Hz filtered.
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        
    
    if opts.td.detrend
        % Remove daily trend
        E = removeTrend(E,Et);
        B = removeTrend(B,Bt);
        %Br = removeTrend(B,Brt);        
        GIC = removeTrend(GIC,GICt);
    end
    
    %B(:,:,2) = Br;
    % Correct for clock drift
    %tGIC = tGIC + dt/86400;

    if intmplot
        if i == 1
            close all;
        end
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC raw','GIC 1 Hz filtered'},codever);
    end
    
    B    = despikeB(B,dateo);
    E    = despikeE(E);
    GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
    GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

    if intmplot
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC 1 Hz filtered','GIC despiked'},codever);
    end
    
    [t,E,B] = timealign(tGIC,tE,E,B);
    
    fnamemat = sprintf('data/jma/mat/prepEB_%s_%s-%s-v%d-despiked.mat','mmb',dateo,datef,codever);
    save(fnamemat,'tE','E','tB','B');
    fprintf('main.m: Wrote %s\n',fnamemat);

    fnamemat = sprintf('data-private/watari/mat/prepGIC_%s-%s-v%d-despiked.mat',dateo,datef,codever);
    save(fnamemat,'tGIC','GIC');
    fprintf('main.m: Wrote %s\n',fnamemat);
    
    % Always save pngs of raw data
    if rn == 1
        plot_raw(t,GIC(:,2),t,E,t,B,dateo,writepng,{'GIC'},codever);
    end
    
    % Not needed b/c prep_* functions remove mean.
    [GIC,E,B] = removemean(GIC,E,B);

    if 0 && strcmp('pca',opts.td.transform)
        if i == 1
            [RE,~] = eig(cov(E(:,1:2)));
            [RB,~] = eig(cov(B(:,1:2)));            
        end
        B(:,1:2) = fliplr((RB*B(:,1:2)')');
        E(:,1:2) = fliplr((RE*E(:,1:2)')');
    end

    if strcmp('rotateE1',opts.td.transform)
        a = 75;
        b = -75;
        c = sqrt(a^2 + b^2);
        Etmp(:,1) = (a/c)*E(:,1) + (b/c)*E(:,2);  % parallel
        Etmp(:,2) = -(b/c)*E(:,1) + (a/c)*E(:,2); % perp
        E = Etmp;
        clear Etmp;
    end
    
    if strcmp('rotateE2',opts.td.transform)
        a = cosd(38);
        b = sind(38);
        c = sqrt(a^2 + b^2);
        Etmp(:,1) = (a/c)*E(:,1) + (b/c)*E(:,2);  % parallel
        Etmp(:,2) = -(b/c)*E(:,1) + (a/c)*E(:,2); % perp
        E = Etmp;
        clear Etmp;
    end

    if intmplot
        plot_timeseries(dateo,intervalno,filestr,writepng);
        plot_correlations(dateo,intervalno,filestr,writepng);
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end

    fprintf('main.m: %s G/Eo\n',dateo);
    GEoc{i} = transferfnConst(E,GIC,opts,t,codever);

    if 1
    fprintf('main.m: %s G/Bo\n',dateo);
    GBoc{i} = transferfnConst(B(:,1:2,1),GIC,opts,t,codever);
    
    fprintf('main.m: %s G/E\n',dateo);
    GEc{i} = transferfnFD(E,GIC,opts,t);
    
    fprintf('main.m: %s G/B\n',dateo);
    GBc{i} = transferfnFD(B(:,1:2,1),GIC,opts,t);
    
    fprintf('main.m: %s E/B\n',dateo);
    EBc{i} = transferfnFD(B(:,1:2,1),E,opts,t);

    %Need to re-implement this in transferfnFD.m. Lost version that had it.
    %fprintf('main.m: %s E/B Remote Reference\n',dateo);
    %topts = opts;
    %topts.fd.regression.method = 1; % Remote reference not implemented for other methods.
    %EBrc{i} = transferfnFD(B(:,1:2,:),E,topts,t);
    
    fprintf('main.m: %s G/E''\n',dateo);
    GBac{i} = transferfnAlt(GEc{i},EBc{i},opts);

    fprintf('main.m: %s G/Eo''\n',dateo);
    Eprime = [];
    GICx = [];
    for zz = 1:size(EBc{i}.Predicted,3)
        Eprime = [Eprime;EBc{i}.Predicted(:,:,zz)];
        %GICx   = [GICx;EBc{i}.Out(:,:,zz)];
    end
    GBoac{i} = transferfnConst(Eprime,GIC,opts,t,codever);
    end
end

GEo  = transferfnCombine(GEoc);

if 1
GBo  = transferfnCombine(GBoc);
GE   = transferfnCombine(GEc);
GB   = transferfnCombine(GBc);
EB   = transferfnCombine(EBc);
%EBr  = transferfnCombine(EBrc);
GBa  = transferfnCombine(GBac);
GBoa = transferfnCombine(GBoac);
end

fprintf('________________________________________________________________\n');

if oos_aves
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

fprintf('main.m: E/B\n');
EB_avg  = transferfnAverageFunction(EB,opts);

%fprintf('main.m: E/B Remote Reference\n');
%EBr_avg = transferfnAverageFunction(EBr,opts);
%EB_avg.RR = EBr_avg.Mean;

fprintf('main.m: E/B Fujii\n');
EBf = transferfnFujii(EB,'mmb',opts,codever);
EB_avg.Fuji = EBf;

fprintf('main.m: E/B No stack\n');
EBns = transferfnFD2(EB,opts);
EB_avg.NoStack_OLS = EBns.OLS;
EB_avg.NoStack_Robust1 = EBns.Robust1;
EB_avg.NoStack_Robust2 = EBns.Robust2;
transferfnSummary(EB,EB_avg,'E/B');

fprintf('main.m: G/E\n');
GE_avg = transferfnAverageFunction(GE,opts);

fprintf('main.m: G/E No stack\n');
GEns = transferfnFD2(GE,opts);
GE_avg.NoStack_OLS = GEns.OLS;
GE_avg.NoStack_Robust1 = GEns.Robust1;
GE_avg.NoStack_Robust2 = GEns.Robust2;
transferfnSummary(GE,GE_avg,'G/E No stack');

fprintf('main.m: G/B\n');
GB_avg = transferfnAverageFunction(GB,opts);

fprintf('main.m: G/B No stack\n');
GBns = transferfnFD2(GB,opts);
GB_avg.NoStack_OLS = GBns.OLS;
GB_avg.NoStack_Robust1 = GBns.Robust1;
GB_avg.NoStack_Robust2 = GBns.Robust2;
transferfnSummary(GB,GB_avg,'G/B');

fprintf('main.m: G/E''\n');
GBa_avg = transferfnAverageFunction(GBa,opts);
fprintf('main.m: G/E'' Fujii\n');
GBaf = transferfnAlt(GE, EBf, opts);
GBa_avg.Fujii = GBaf;
transferfnSummary(GBa,GBa_avg,'Model 3 - G/E''');

savevars = {'opts','codever', 'oos_aves', 'dateos','datefs','GEo','GBo','GE','GB','EB','EBf','GBa','GBaf','GEo_avg','GBo_avg','GE_avg','GB_avg','EB_avg','GBa_avg'};
fname = sprintf('data/jma/mat/main_%s.mat',filestr);
fprintf('main.m: Saving %s\n',fname);
save(fname,savevars{:});
fprintf('main.m: Saved %s\n',fname);

diary off

main_log;

main_plots;
