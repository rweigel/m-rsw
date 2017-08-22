
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

% Pulkkinen et al. 2007 method.
% Compute ao and bo using 2007 method
d = (mean_nonflag(E(Ix,1).*E(Ix,2)))^2-mean_nonflag(E(Ix,1).*E(Ix,1))*mean_nonflag(E(Ix,2).*E(Ix,2));
an = mean_nonflag(GIC(Ix,2).*E(Ix,2))*mean_nonflag(E(Ix,1).*E(Ix,2)) - mean_nonflag(GIC(Ix,2).*E(Ix,1))*mean_nonflag(E(Ix,2).*E(Ix,2));
aoP = an/d
bn = mean_nonflag(GIC(Ix,2).*E(Ix,1))*mean_nonflag(E(Ix,1).*E(Ix,2)) - mean_nonflag(GIC(Ix,2).*E(Ix,2))*mean_nonflag(E(Ix,1).*E(Ix,1));
boP = bn/d

% Compute cross correlation between E and GIC
[xc,lags] = xcorr(GIC(Ix,2),E(Ix,1));
[yc,lags] = xcorr(GIC(Ix,2),E(Ix,2));
[gc,lags] = xcorr(GIC(Ix,2),GIC(Ix,2));

% GIC(:,1) = aoE(:,1) + boE(:,2);
LIN = basic_linear(E(Ix,:),GIC(Ix,1));
GICp2_TD0(:,1) = basic_linear(E(Ix,:),LIN.Weights,'predict');
ao = LIN.Weights(1)
bo = LIN.Weights(2)

% GIC(:,2) = aoE(:,1) + boE(:,2); % (LPF version is second column)
LIN = basic_linear(E(Ix,:),GIC(Ix,2));
GICp2_TD0(:,2) = basic_linear(E(Ix,:),LIN.Weights,'predict');
% Linear regression coefficients
ao = LIN.Weights(1)
bo = LIN.Weights(2)

LIN = basic_linear(B(Ix,1:2),GIC(Ix,1));
GICp3_TD0(:,1) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');
aoB = LIN.Weights(1)
boB = LIN.Weights(2)

LIN = basic_linear(B(Ix,1:2),GIC(Ix,2));
GICp3_TD0(:,2) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');
aoB = LIN.Weights(1)
boB = LIN.Weights(2)

LIN = basic_linear(B(Ix,1:3),GIC(Ix,1));
GICp3_TD03(:,1) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');
LIN = basic_linear(B(Ix,1:3),GIC(Ix,2));
GICp3_TD03(:,2) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');

LIN = basic_linear(E(Ix,:),GIC(Ix,1));
GICp2_TD0(:,1) = basic_linear(E(Ix,:),LIN.Weights,'predict');
aE = LIN.Weights(1)
bE = LIN.Weights(2)
cE = LIN.Weights(end)

LIN = basic_linear(E(Ix,:),GIC(Ix,2));
GICp2_TD0(:,2) = basic_linear(E(Ix,:),LIN.Weights,'predict');
aE = LIN.Weights(1)
bE = LIN.Weights(2)
cE = LIN.Weights(end)

LIN = basic_linear(B(Ix,1:2),GIC(Ix,1));
GICp3_TD0(:,1) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');
LIN = basic_linear(B(Ix,1:2),GIC(Ix,2));
GICp3_TD0(:,2) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');
aB = LIN.Weights(1)
bB = LIN.Weights(2)
cB = LIN.Weights(end)

LIN = basic_linear(B(Ix,1:3),GIC(Ix,1));
GICp3_TD03(:,1) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');
LIN = basic_linear(B(Ix,1:3),GIC(Ix,2));
GICp3_TD03(:,2) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');

save mainCompute1.mat
