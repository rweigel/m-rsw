addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear

[tGIC,GIC]  = prepGIC();        % Read GIC data from Watari
[tE,E,tB,B] = prepEB('second'); % Read 1s E and B data from Kyoto
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Data don't look like 1s data.

% GIC spans shorter time range than E and B.  This pads out GIC
% with NaNs and interpolates over gaps (but there were no gaps).
GIC = interp1(tGIC,GIC,tE); 
tGIC = tE;

% Used for paper.  Requires ~32 GB RAM
Nc = 60*10; % Number of causal coefficients
Na = 60*10; % Number of acausal coefficients

%Nc = 10; % Number of causal coefficients
%Na = 10; % Number of acausal coefficients

TI = [0:1:size(E,1)]';

% Remove mean
GIC = GIC - repmat(mean_nonflag(GIC),size(GIC,1),1);
E = E - repmat(mean_nonflag(E),size(E,1),1);

% GIC(:,1) = aoE(:,1) + boE(:,2);
LIN = basic_linear(E,GIC(:,1));
GICp2_TD0(:,1) = basic_linear(E,LIN.Weights,'predict');

% GIC(:,2) = aoE(:,1) + boE(:,2);
LIN = basic_linear(E,GIC(:,2));
GICp2_TD0(:,2) = basic_linear(E,LIN.Weights,'predict');
% Linear regression coefficients
ao = LIN.Weights(1)
bo = LIN.Weights(2)

% Compute 1000 bootstrap ao bo values to get standard deviation.
for i = 1:1000
    LIN = basic_linear(E,GIC(:,2),60*60);
    aoboot(i) = LIN.Weights(1);
    boboot(i) = LIN.Weights(2);
end
aobootstd = std(aoboot);
bobootstd = std(boboot);

% Attempt to reproduce Watari by averaging to 1 minute
E1m = block_mean(E,60);
GIC1m = block_mean(GIC,60);

% GIC(:,2) = aoE(:,1) + boE(:,2); for 1-minute data.
% Shift by one minute to see if it matters.
LIN = basic_linear(E1m(1:end-1,:),GIC1m(2:end,2));
ao1m = LIN.Weights(1)
bo1m = LIN.Weights(2)

% See how ao and bo depend on shift of 1-second data.
tl = [-100:100];
for i = tl
    j = i-tl(1)+1;
    [T,X] = time_delay(GIC(:,2),E,1,i);
    LIN = basic_linear(X,T);
    arvlag(j) = LIN.ARVtrain;
    aolag(j) = LIN.Weights(1);
    bolag(j) = LIN.Weights(2);
end

I = sum(isnan(GIC) + isnan(E),2) == 0;

% Pulkkinen et al. 2007 method.
% Compute ao and bo using 2007 method
d = (mean_nonflag(E(I,1).*E(I,2)))^2-mean_nonflag(E(I,1).*E(I,1))*mean_nonflag(E(I,2).*E(I,2));
an = mean_nonflag(GIC(I,2).*E(I,2))*mean_nonflag(E(I,1).*E(I,2)) - mean_nonflag(GIC(I,2).*E(I,1))*mean_nonflag(E(I,2).*E(I,2));
aoP = an/d
bn = mean_nonflag(GIC(I,2).*E(I,1))*mean_nonflag(E(I,1).*E(I,2)) - mean_nonflag(GIC(I,2).*E(I,2))*mean_nonflag(E(I,1).*E(I,1));
boP = bn/d

% Compute cross correlation between E and GIC
[xc,lags] = xcorr(GIC(I,2),E(I,1));
[yc,lags] = xcorr(GIC(I,2),E(I,2));
[gc,lags] = xcorr(GIC(I,2),GIC(I,2));


LIN = basic_linear(B(:,1:2),GIC(:,1));
GICp3_TD0(:,1) = basic_linear(B(:,1:2),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:2),GIC(:,2));
GICp3_TD0(:,2) = basic_linear(B(:,1:2),LIN.Weights,'predict');
aoB = LIN.Weights(1);
boB = LIN.Weights(2);

LIN = basic_linear(B(:,1:3),GIC(:,1));
GICp3_TD03(:,1) = basic_linear(B(:,1:3),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:3),GIC(:,2));
GICp3_TD03(:,2) = basic_linear(B(:,1:3),LIN.Weights,'predict');

LIN = basic_linear(E,GIC(:,1));
GICp2_TD0(:,1) = basic_linear(E,LIN.Weights,'predict');
LIN = basic_linear(E,GIC(:,2));
GICp2_TD0(:,2) = basic_linear(E,LIN.Weights,'predict');
aE = LIN.Weights(1);
bE = LIN.Weights(2);
cE = LIN.Weights(end)

LIN = basic_linear(B(:,1:2),GIC(:,1));
GICp3_TD0(:,1) = basic_linear(B(:,1:2),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:2),GIC(:,2));
GICp3_TD0(:,2) = basic_linear(B(:,1:2),LIN.Weights,'predict');
aB = LIN.Weights(1);
bB = LIN.Weights(2);
cB = LIN.Weights(end)

LIN = basic_linear(B(:,1:3),GIC(:,1));
GICp3_TD03(:,1) = basic_linear(B(:,1:3),LIN.Weights,'predict');
LIN = basic_linear(B(:,1:3),GIC(:,2));
GICp3_TD03(:,2) = basic_linear(B(:,1:3),LIN.Weights,'predict');

break

% Compute transfer function with B driving E using TD method
% transferfnTD handles NaNs internally.
[Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B,E,Nc,Na);

% Compute transfer function with B driving E using FD method
[Z_FD,fe_FD,H_FD,t_FD] = transferfnFD(B,E,2,'rectangular');
Ep_FD = real(Zpredict(fe_FD,Z_FD,B));

% Use first half of data
Ix = [1:floor(size(E,1)/2)];
% Compute transfer function with E driving GIC using TD method
[Z2_TD,f2_TD,H2_TD,t2_TD,GICp2_TD] = transferfnTD(E(Ix,:),GIC(Ix,:),Nc,Na);

% Compute transfer function with E driving GIC using FD method
[Z2_FD,fe2_FD,H2_FD,t2_FD] = transferfnFD(E(Ig,:),GIC(Ig,:),1,'rectangular');
GICp2_FD = NaN(size(GIC));
GICp2_FD(Ig,:) = real(Zpredict(fe2_FD,Z2_FD,E(Ig,:)));

% Compute transfer function with B driving GIC using TD method
[Z3_TD,f3_TD,H3_TD,t3_TD,GICp3_TD] = transferfnTD(B,GIC,Nc,Na);

% Compute transfer function with B driving GIC using FD method
[Z3_FD,fe3_FD,H3_FD,t3_FD] = transferfnFD(B(Ig,:),GIC(Ig,:),1,'rectangular');
GICp3_FD = NaN(size(GIC));
GICp3_FD(Ig,:) = real(Zpredict(fe3_FD,Z3_FD,B(Ig,:)));

save('main.mat');

main_plot;


