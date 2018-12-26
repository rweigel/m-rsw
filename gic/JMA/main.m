addpath('./m');
addpath('./m/LIBRA');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

opts = struct();

opts.td.window.function = @parzenwin;
opts.td.window.functionstr = 'parzen'; %'rectangular' 'parzen'
opts.td.window.options = struct();

opts.td.prewhiten = struct();
opts.td.prewhiten.method = '';
opts.td.prewhiten.options = '';

opts.fd.window = struct();
opts.fd.window.function = @parzenwin;
opts.fd.window.functionstr = 'parzen';
opts.fd.window.options = struct();

opts.fd.regression = struct();
opts.fd.regression.method = 3; % 1-6
opts.fd.regression.methodstr = 'robustfit_on_Z';% 'ols_on_Z' 'robustfit_on_Z';

%opts.fd.stackave = struct();
%opts.fd.stackave.method = 'mean'; % mean, median, mode, mlochuber, trimmean
%opts.fd,stackave.options = ''; % For mlochuber: k, loc, sca. For trimmean, percent, flag.

filestr = sprintf('%s-%s-%s',...
    opts.td.window.functionstr,...
    opts.fd.window.functionstr,...
    opts.fd.regression.methodstr...
);

writepng = 0;
regenfiles = 0;

% removed 20060818 due to large segment of bad E
% removed 20060411 and 20060412 due to baseline shift in E

dateos = {'20061214','20060819','20061107','20060402','20060805','20060725','20071118','20071122','20061128','20061201'};
datefs = {'20061215','20060821','20061112','20060410','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    66    ,    17    ,    32    ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];

diary(sprintf('log/main_%s.txt',filestr));

for i = 1:length(dateos)

    dateo = dateos{i};
    datef = datefs{i};
    dt    = dts(i);

    prepdirs(dateo);
    
    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles); 

    % Read GIC data from Watari
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        

    % Correct for clock drift
    tGIC = tGIC + dt;

    close all
    plot_raw(tGIC,GIC,tE,E,tB,B,dateo);
    
    E = despikeE(tE,E);
    GIC = despikeGIC(tGIC,GIC);

    %plot_raw(tGIC,GIC,tE,E,tB,B,dateo);
    %input('Continue?')

    [t,E,B] = timealign(tGIC,tE,E,B);
    [GIC,E,B] = removemean(GIC,E,B);
    [GIC,E,B] = taper(GIC,E,B,opts.td.window.function);

    intervalno = 0; % Entire time span labeled as interval 0

    compute_TF(t,GIC,E,B,dateo,intervalno,opts.fd);
    close all;
    plot_timeseries(dateo,intervalno,writepng);
    plot_spectra(dateo,intervalno,writepng);
    plot_H(dateo,intervalno,writepng);
    plot_Z(dateo,intervalno,writepng);

    k = 1;
    Tw = 3600*24;
    Ts = 3600*24;
    Io = [1:Ts:length(t)-Tw+1];
    for io = Io(1:end)
        fn = 0;
        intervalno = k;
        fprintf('-------\nInterval %d of %d for %s\n',k,length(Io),dateo);
        k = k+1;
        Ix = [io:io+Tw-1];

        tr = t(Ix); % Time values for segment.
        Er = E(Ix,:);
        Br = B(Ix,:);
        GICr = GIC(Ix,:);
        [GICr,Er,Br] = taper(GICr,Er,Br,opts.td.window.function);

        compute_TF(tr,GICr,Er,Br,dateo,intervalno,opts.fd);
        close all
        plot_timeseries(dateo,intervalno,writepng);
        plot_spectra(dateo,intervalno,writepng);
        plot_H(dateo,intervalno,writepng);
        plot_Z(dateo,intervalno,writepng);
        %input('Continue?')
    end
end

aggregate_TFs(dateos);

compute_TF_aves();
plot_TF_aves(1,filestr);
diary off
