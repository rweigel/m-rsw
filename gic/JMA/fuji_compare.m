addpath('./m');
addpath('./m/LIBRA');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

dateo = '20031029';
datef = '20031031';

dateo = '20031101';
datef = '20031108';

regenfiles = 0;
clean = 1;
writepng = 0;
intplot = 0;

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


prepdirs(dateo,filestr,clean);
[tE,E,tB,B] = prep_EB(dateo,datef,regenfiles);

t = tE;
tGIC = tE;
GIC = E;

plot_raw(tGIC,GIC,tE,E,tB,B,dateo);
[GIC,E,B] = removemean(GIC,E,B);

intervalno = 0;
compute_TF(t,GIC,E,B,dateo,intervalno,filestr,opts);
plot_Z(dateo,intervalno,filestr,writepng);

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

    compute_ab(GICr,Er,Br,dateo,intervalno)

    compute_TF(tr,GICr,Er,Br,dateo,intervalno,filestr,opts);
    if intplot
        close all
        plot_timeseries(dateo,intervalno,filestr,writepng);
        plot_spectra(dateo,intervalno,filestr,writepng);
        plot_H(dateo,intervalno,filestr,writepng);
        plot_Z(dateo,intervalno,filestr,writepng);
    end
    %input('Continue?')
end

dateos = {dateo};
aggregate_TFs(dateos,filestr);

diary off
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));
compute_TF_aves(filestr);
diary off

plot_TF_aves(1,filestr);