addpath('./m');
addpath('./m/export_fig');
addpath('./m/LIBRA'); % For mlochuber().
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

opts = main_options(1);

% Read 1s E and B data from Kyoto
[tE,E,tB,B] = prep_EB('20061214','20061215',regenfiles); 

% Read GIC data from Watari
% First column is raw, second is 1 Hz filtered.
[tGIC,GIC]  = prep_GIC('20061214','20061215',regenfiles);        

dt = 66;

% Correct for clock drift
tGIC = tGIC + dt*1000;

E    = despikeE(E);
GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

[t,E,B] = timealign(tGIC,tE,E,B);
[GIC,E,B] = removemean(GIC,E,B);

opts.td.window.width = 86400*2;
opts.td.window.shift = 86400*2;
GEo = transferfnConst(E,GIC,opts)

[GICt,Et,Bt] = computeTrend(GIC,E,B,dateos,datefs);

GICd = removeTrend(GIC,GICt);
Ed = removeTrend(E,Et);
Bd = removeTrend(B,Bt);

GEod = transferfnConst(Ed,GICd,opts)


