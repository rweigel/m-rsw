addpath('../../time');
addpath('../../stats');
addpath('../../gic/transferfn');

clear

[tGIC,GIC]  = prepGIC();        % Read GIC data from Watari
[tE,E,tB,B] = prepEB('second'); % Read 1s E and B data from Kyoto
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Data don't look like 1s data.

% GIC spans shorter time range than E and B.  This pads out GIC
% with NaNs and interpolates over gaps (but there were no gaps).
GIC = interp1(tGIC,GIC,tE);
tGIC = tE;

% Used for paper.  Requires ~32 GB RAM
%Nc = 60*5; % Number of causal coefficients
%Na = 60*5; % Number of acausal coefficients

Nc = 10; % Number of causal coefficients
Na = 10; % Number of acausal coefficients

Ig = ~isnan(GIC(:,1)); % Good GIC points

% Compute transfer function with B driving E using TD method
% transferfnTD handles NaNs internally.
[Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B,E,Nc,Na);

% Compute transfer function with B driving E using FD method
[Z_FD,fe_FD,H_FD,t_FD] = transferfnFD(B,E,2,'rectangular');
Ep_FD = real(Zpredict(fe_FD,Z_FD,B));

% Compute transfer function with E driving GIC using TD method
[Z2_TD,f2_TD,H2_TD,t2_TD,GICp2_TD] = transferfnTD(E,GIC,Nc,Na);

LIN = basic_linear(E,GIC(:,1));
GICp2_TD0(:,1) = basic_linear(E,LIN.Weights,'predict');
LIN = basic_linear(E,GIC(:,2));
GICp2_TD0(:,2) = basic_linear(E,LIN.Weights,'predict');
aE = LIN.Weights(1);
bE = LIN.Weights(2);

% Compute transfer function with E driving GIC using FD method
[Z2_FD,fe2_FD,H2_FD,t2_FD] = transferfnFD(E(Ig,:),GIC(Ig,:),1,'rectangular');
GICp2_FD = NaN(size(GIC));
GICp2_FD(Ig,:) = real(Zpredict(fe2_FD,Z2_FD,E(Ig,:)));

% Compute transfer function with B driving GIC using TD method
[Z3_TD,f3_TD,H3_TD,t3_TD,GICp3_TD] = transferfnTD(B,GIC,Nc,Na);

LIN = basic_linear(B(:,1:2),GIC(:,1));
GICp3_TD0(:,1) = basic_linear(B(:,1:2),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:2),GIC(:,2));
GICp3_TD0(:,2) = basic_linear(B(:,1:2),LIN.Weights,'predict');
aB = LIN.Weights(1);
bB = LIN.Weights(2);

LIN = basic_linear(B(:,1:3),GIC(:,1));
GICp3_TD03(:,1) = basic_linear(B(:,1:3),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:3),GIC(:,2));
GICp3_TD03(:,2) = basic_linear(B(:,1:3),LIN.Weights,'predict');

% Compute transfer function with B driving GIC using FD method
[Z3_FD,fe3_FD,H3_FD,t3_FD] = transferfnFD(B(Ig,:),GIC(Ig,:),1,'rectangular');
GICp3_FD = NaN(size(GIC));
GICp3_FD(Ig,:) = real(Zpredict(fe3_FD,Z3_FD,B(Ig,:)));

save('main.mat');

main_plot;


