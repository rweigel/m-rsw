addpath('~/git/m-rsw/time');
addpath('~/git/m-rsw/stats');
addpath('~/git/m-rsw/gic/transferfn');

clear

[tGIC,GIC]  = prepGIC();
[tE,E,tB,B] = prepEB('second');
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Nonsensical data

[Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B,E,60*20,60);

[Z_FD,fe_FD,H_FD,t_FD] = transferfnFD(B,E,2,'rectangular');
Ep_FD = Zpredict(fe_FD,Z_FD,B);
Ep_FD = real(Ep_FD);

save('main.mat');

main_plot;