opts = main_options(1);

% Read 1s E and B data from Kyoto
[tE,E,tB,B,meanE,meanB] = prep_EB('20061214','20061215','mmb',1); 

% Read GIC data from Watari
% First column is raw, second is 1 Hz filtered.
[tGIC,GIC]  = prep_GIC('20061214','20061215',1);        

E    = despikeE(E);
GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column

[t,E,B] = timealign(tGIC,tE,E,B);
[GIC,E,B] = removemean(GIC,E,B);

% near zero mean input and output
regress(GIC(:,2),E)
% Give a = 96.0 and b = -196.6

% Add mean back:
regress(GIC(:,2),E+repmat(meanE,size(E,1),1))
% Gives a = 39.7 and b = -16.6
% Watari found a = 38.1, b = -7.4.

break


opts.td.window.width = 86400*2;
opts.td.window.shift = 86400*2;
GEo = transferfnConst(E,GIC,opts)

[GICt,Et,Bt] = computeTrend(GIC,E,B,dateos,datefs);

GICd = removeTrend(GIC,GICt);
Ed = removeTrend(E,Et);
Bd = removeTrend(B,Bt);

GEod = transferfnConst(Ed,GICd,opts)


