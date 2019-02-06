addpath('./m');
addpath('./m/export_fig');
addpath('./m/LIBRA'); % For mlochuber().
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

opts = main_opts(1);

% Read 1s E and B data from Kyoto
[tE,E,tB,B] = prep_EB('20061214','20061215',regenfiles); 

% Read GIC data from Watari
% First column is raw, second is 1 Hz filtered.
[tGIC,GIC]  = prep_GIC('20061214','20061215',regenfiles);        

% Correct for clock drift
tGIC = tGIC + dts(4);

E    = despikeE(tE,E);
GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

[t,E,B] = timealign(tGIC,tE,E,B);
[GIC,E,B] = removemean(GIC,E,B);

opts.td.window.width = 86400*2;
opts.td.window.shift = 86400*2;
GEox = compute_ab(E,GIC,opts);