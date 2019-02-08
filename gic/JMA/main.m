function main(rn)

%clear
%rn = 1;

setpaths;

writepng = 0;   % Write png and pdf files
intmplot = 0;   % Intermediate plots
regenfiles = 0; % If 0, used cached E,B,GIC mat files

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

for i = 1:length(dateos)
%for i = 1:2

    fprintf('------------------------------------------------------------------------\n')
    fprintf('Continuous data interval %d of %d. Start date: %s\n',i,length(dateos),dateos{i});
    fprintf('------------------------------------------------------------------------\n')

    dateo = dateos{i};
    datef = datefs{i};
    dt    = dts(i);

    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles); 

    % Read GIC data from Watari
    % First column is raw, second is 1 Hz filtered.
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        

    % Correct for clock drift
    tGIC = tGIC + dt;

    if intmplot
        close all;
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC raw','GIC 1 Hz filtered'});
    end
    
    E    = despikeE(tE,E);
    GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
    GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

    if intmplot
        plot_raw(tGIC,GIC(:,2),tE,E,tB,B,dateo,writepng,{'GIC'});
    end
        
    [t,E,B] = timealign(tGIC,tE,E,B);
    [GIC,E,B] = removemean(GIC,E,B);

    if strmatch('pca',opts.td.transform,'exact')
        if i == 1
            [V,D] = eig(cov(E));
        end
        E = fliplr((V*E')');
        B(:,1:2) = fliplr((V*B(:,1:2)')');
    end
    
    if intmplot
        plot_timeseries(dateo,intervalno,filestr,writepng);
        plot_correlations(dateo,intervalno,filestr,writepng);
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end

    fprintf('main.m: %s G/Eo\n',dateo);    
    GEoc{i} = transferfnConst(E,GIC,opts);

    fprintf('main.m: %s G/Bo\n',dateo);    
    GBoc{i} = transferfnConst(B,GIC,opts);
    
    fprintf('main.m: %s G/E\n',dateo);
    GEc{i} = transferfnFD(E,GIC,opts); 
    
    fprintf('main.m: %s G/B\n',dateo);
    GBc{i} = transferfnFD(B(:,1:2),GIC,opts); 
    
    fprintf('main.m: %s E/B\n',dateo);
    EBc{i} = transferfnFD(B(:,1:2),E,opts);
    
    fprintf('main.m: %s G/E''\n',dateo);
    GBac{i} = transferfnAlt(GEc{i},EBc{i},opts);
    
end

GEo  = transferfnCombine(GEoc);
GBo  = transferfnCombine(GBoc);
GE   = transferfnCombine(GEc);
GB   = transferfnCombine(GBc);
EB   = transferfnCombine(EBc);
GBa  = transferfnCombine(GBac);

fprintf('________________________________________________________________\n');

fprintf('main.m: %s G/Eo\n',dateo);
GEo_avg = transferfnAverage(GEo,opts);

fprintf('main.m: %s G/Bo\n',dateo);
GBo_avg = transferfnAverage(GBo,opts);

fprintf('main.m: %s G/E\n',dateo);
GE_avg = transferfnAverage(GE,opts);

fprintf('main.m: %s G/B\n',dateo);
GB_avg = transferfnAverage(GB,opts);

fprintf('main.m: %s G/E''\n',dateo);
GBa_avg = transferfnAverage(GBa,opts);

fprintf('main.m: %s E/B\n',dateo);
EB_avg  = transferfnAverage(EB,opts);

savevars = {'opts','GEo','GBo','GE','GB','EB','GBa','GEo_avg','GBo_avg','GE_avg','GB_avg','EB_avg','GBa_avg'};
fname = sprintf('mat/main_%s.mat',filestr);
fprintf('main.m: Saving %s\n',fname);
save(fname,savevars{:});
fprintf('main.m: Saved %s\n',fname);

diary off

main_summary_log;

main_summary_plots;
