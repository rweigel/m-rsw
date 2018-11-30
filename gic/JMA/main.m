addpath('./m');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

writepng = 0;
regenfiles = 1;

dateos = {'20061214','20060818','20061107','20060402','20060805','20060725','20071118','20071122','20061128','20061201'};
datefs = {'20061215','20060821','20061112','20060412','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    66    ,    17    ,    32    ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];

for i = 1:length(dateos)

    dateo = dateos{i};
    datef = datefs{i};
    dt = dts(i);

    prepdirs(dateo);
    
    % Read 1s E and B data from Kyoto
    [tE,E,tB,B] = prep_EB(dateo,datef,regenfiles); 

    % Read GIC data from Watari
    [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        

    % Correct for clock drift
    tGIC = tGIC + dt;

    close all
    plot_raw(tGIC,GIC,tE,E,tB,B,dateo);

    GIC = despike(tGIC,GIC);
    [t,E,B] = timealign(tGIC,tE,E,B);
    [GIC,E,B] = removemean(GIC,E,B);

    intervalno = 0; % Entire time span labeled as interval 0

    compute_TF(t,GIC,E,B,dateo,intervalno);
    close all;
    plot_timeseries(dateo,intervalno,png);
    plot_spectra(dateo,intervalno,png);
    plot_H(dateo,intervalno,png);
    plot_Z(dateo,intervalno,png);

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
            
        compute_TF(tr,GICr,Er,Br,dateo,intervalno);
        close all
        plot_timeseries(dateo,intervalno,png);
        plot_spectra(dateo,intervalno,png);
        plot_H(dateo,intervalno,png);
        plot_Z(dateo,intervalno,png);
        %input('Continue?')
    end
end
compute_TF_aves(dateso);