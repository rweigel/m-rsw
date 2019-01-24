addpath('./m');
addpath('./m/export_fig');
addpath('./m/LIBRA');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

opts = struct();

opts.td.transform = 'none'; % pca

opts.td.window.function = @rectwin;
opts.td.window.functionstr = 'rectangular'; %'rectangular' 'parzen'
opts.td.window.options = struct();

opts.td.prewhiten = struct();
opts.td.prewhiten.method = '';
opts.td.prewhiten.methodstr = 'none'; % diff
opts.td.prewhiten.options = '';

opts.fd.window = struct();
opts.fd.window.function = @parzenwin;
opts.fd.window.functionstr = 'parzen';
opts.fd.window.options = struct();

opts.fd.regression = struct();

opts.fd.regression.method = 2; % 1-6
opts.fd.regression.methodstr = 'ols_on_Z';

%opts.fd.regression.method = 3; 
%opts.fd.regression.methodstr = 'robust_on_Z';

%opts.fd.stackave = struct();
%opts.fd.stackave.method = 'mean'; % mean, median, mode, mlochuber, trimmean
%opts.fd,stackave.options = ''; % For mlochuber: k, loc, sca. For trimmean, percent, flag.

filestr = sprintf('%s-%s-%s-%s-%s',...
    opts.td.transform,...
    opts.td.prewhiten.methodstr,...
    opts.td.window.functionstr,...
    opts.fd.window.functionstr,...
    opts.fd.regression.methodstr...
);

clean = 1;
writepng = 0;
regenfiles = 0;
intplot = 1;

% removed 20060818 due to large segment of bad E
% removed 20060411 and 20060412 due to baseline shift in E

dateos = {'20061214','20060819','20061107','20060402','20060805','20060725','20071118','20071122','20061128','20061201'};
%dateos = {'20061214','20060819'};
datefs = {'20061215','20060821','20061112','20060410','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    66    ,    17    ,    32    ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];

if (0)
    [dateos,I] = sort(dateos);
    datefs = datefs(I);
    for i = 1:length(dateos)
        %fprintf('%s-%s, ',dateos{i},datefs{i});
    end
end

if (0)
    regenfiles = 1;
    for i = 1:length(dateos)
        dateo = dateos{i};
        datef = datefs{i};
        [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles); 
    end
end

fn = 1;
%for i = 1:length(dateos)
for i = 4:4
%for i = 1:1
    fprintf('--------------\n')
    fprintf('--------------\n')
    dateo = dateos{i};
    datef = datefs{i};
    dt    = dts(i);

    prepdirs(dateo,filestr,clean);
    
    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles); 

    % Read GIC data from Watari
    % First column is raw, second is 1 Hz filtered.
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        

    % Correct for clock drift
    tGIC = tGIC + dt;

    if intplot
        close all
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC raw','GIC 1 Hz filtered'});
    end
    
    E    = despikeE(tE,E);
    GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
    GIC  = [GIC(:,2),GICd];            % Keep 1 Hz filtered column and despiked column

    if intplot
        plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC 1 Hz filtered','GIC 1 Hz filtered then despiked'});
    end

    if strmatch('pca',opts.td.transform)
        if i == 1
            [V,D] = eig(cov(E));
        end
        E = fliplr((V*E')');
        B(:,1:2) = fliplr((V*B(:,1:2)')');
    end
    
    [t,E,B] = timealign(tGIC,tE,E,B);

    [GIC,E,B] = removemean(GIC,E,B);

    intervalno = 0; % Full time span from dateo to datef labeled as interval 0
    
    compute_ab(GIC,E,B,dateo,intervalno);
    compute_TF(t,GIC,E,B,dateo,intervalno,filestr,opts);

    if intplot
        plot_timeseries(dateo,intervalno,filestr,writepng);
        keyboard
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end
    
    % Loop over blocks.
    k = 1;
    Tw = 3600*24; % Window width
    Ts = 3600*24; % Shift 
    Io = [1:Ts:length(t)-Tw+1];
    for io = Io(1:end)
        fprintf('-------\nInterval %d of %d for %s\n',k,length(Io),dateo);
        Ix = [io:io+Tw-1];

        tr = t(Ix); % Time values for segment.
        Er = E(Ix,:);
        Br = B(Ix,:);
        GICr = GIC(Ix,:);
        [GICr,Er,Br] = taper(GICr,Er,Br,opts.td.window.function);

        fnameab{fn} = compute_ab(GICr,Er,Br,dateo,k);
        fnametf{fn} = compute_TF(tr,GICr,Er,Br,dateo,k,filestr,opts);
        if intplot
            close all
            plot_timeseries(dateo,k,filestr,writepng);
            plot_spectra(dateo,k,filestr,writepng);
            plot_H(dateo,k,filestr,writepng);
            plot_Z(dateo,k,filestr,writepng);
        end
        %input('Continue?')
    end
    fn = fn+1;
end

aggregate_TFs(fnameab,fnametf,filestr);

diary off
delete(sprintf('log/compute_TF_aves_%s.txt',filestr));
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));
compute_TF_aves(filestr);
diary off

plot_TF_aves(0,filestr);
