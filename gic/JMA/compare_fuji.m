addpath('./m');
addpath('./m/LIBRA');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

dateo = '20031029';
datef = '20031031';

dateo = '20031101';
datef = '20031118';

%dateo = '20060403';
%datef = '20060410';


regenfiles = 0;
clean = 1;
writepng = 0;
intplot = 0;

opts = main_options(1);

prepdirs(dateo,opts.filestr);
[tE,E,tB,B] = prep_EB(dateo,datef,regenfiles);

%B = B(I,:);
%E = E(I,:);

t = tE;
tGIC = tE;
GIC = E;

%plot_raw(tGIC,GIC,tE,E,tB,B,dateo,writepng,{'GIC raw','GIC 1 Hz filtered'});

[GIC,E,B] = removemean(GIC,E,B);

opts.td.window.width = NaN;
opts.td.window.shift = NaN;
S = transferfnFD(B(:,1:2),E,opts);
S.Bunits = 'nT';
S.Eunits = 'mV/km';

mtplots(S);
break

opts.td.window.width = 86400;
opts.td.window.shift = 86400;
S = transferfnFD(B(:,1:2),E,opts);

Savg = struct();
Savg.fe = S.fe;
Savg.Z = mean(S.Z,3);

Savg.Phi = atan2(imag(Savg.Z),real(Savg.Z));
Savg.Bunits = 'nT';
Savg.Eunits = 'mV/km';

mtplots(Savg);
break

dateos = {dateo};
aggregate_TFs(dateos,filestr);

diary off
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));
compute_TF_aves(filestr);
diary off

plot_TF_aves(1,filestr);