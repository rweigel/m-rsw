function main(rn)

close all;plot_TF_aves(0,filestr);

addpath('./m');
addpath('./m/export_fig');
addpath('./m/LIBRA'); % For mlochuber().
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

writepng = 0;   % Write png and pdf files
intmplot = 0;   % Intermediate plots
regenfiles = 0; % If 0, used cached E,B,GIC mat files

if nargin == 0
    for rn = 1:5
        main(rn);
    end
    return;
end

opts = main_options(rn);
filestr = sprintf('options-%d',rn);

% removed 20060818 due to large segment of bad E
% removed 20060411 and 20060412 due to baseline shift in E
% removed 20060402 due to baseline shift in GIC
dateos = {'20061214','20060819','20061107','20060403','20060805','20060725','20071118','20071122','20061128','20061201'};
datefs = {'20061215','20060821','20061112','20060410','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    66    ,    17    ,    32    ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];

fprintf('--------------\n')
fprintf('Options set #%d\n',rn);
fprintf('--------------\n')

for i = 1:length(dateos)
%for i = 1:1
%for i = 4:4 % Sample interval in paper

    fprintf('--------------\n')
    fprintf('Continuous data interval %d of %d\n',i,length(dateos));
    fprintf('--------------\n')

    dateo = dateos{i};
    datef = datefs{i};
    dt    = dts(i);

    prepdirs(dateo,filestr);
    
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
        plot_raw(tGIC,GIC(:,2),tE,E,tB,B,dateo,writepng,{'GIC 1 Hz filtered then despiked'});
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

    if intmplot
        plot_timeseries(dateo,intervalno,filestr,writepng);
        plot_correlations(dateo,intervalno,filestr,png)        
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end

    
    % Loop over blocks.
    %Tw = opts.td.window.width;
    %Ts = opts.td.window.shift;
    Tw = 3600*24; % Window width
    Ts = 3600*24; % Shift 
    Io = [1:Ts:length(t)-Tw+1];
    k = 1;  % Time window # within datao/datef
    fn = 1; % File number
    for io = Io(1:end)
        fprintf('-------\nInterval %d of %d for %s\n',k,length(Io),dateo);
        Ix = [io:io+Tw-1];

        tr = t(Ix); % Time values for segment.
        Er = E(Ix,:);
        Br = B(Ix,:);
        GICr = GIC(Ix,:);
        [GICr,Er,Br] = taper(GICr,Er,Br,opts.td.window.function);

        fnamesab{fn} = compute_ab(GICr,Er,Br,dateo,k);
        fnamestf{fn} = compute_TF(tr,GICr,Er,Br,dateo,k,filestr,opts);
        if intmplot
            close all
            plot_timeseries(dateo,k,filestr,writepng);
            plot_spectra(dateo,k,filestr,writepng);
            plot_H(dateo,k,filestr,writepng);
            plot_Z(dateo,k,filestr,writepng);
        end
        %input('Continue?')
        k = k + 1;
        fn = fn + 1;
    end
end

aggregate_TFs(fnamesab,fnamestf,filestr,opts);

diary off
delete(sprintf('log/compute_TF_aves_%s.txt',filestr));
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));
compute_TF_aves(filestr,opts);
diary off

close all;
plot_TF_aves(0,filestr);
