function compute_ab(GIC,E,B,dateo,intervalno)

dirmat = sprintf('mat/%s',dateo);

% Important: Inputs/outputs must be zero mean.

% Matrix method to compute ao and bo
% GIC(:,2) = aoE(:,1) + boE(:,2);
LIN = basic_linear(E(:,:),GIC(:,2));
GIC_GE(:,1) = basic_linear(E(:,:),LIN.Weights,'predict');
ao = LIN.Weights(1);
bo = LIN.Weights(2);
fprintf('ao =  %7.4f; bo =  %7.4f (matrix method)\n',ao,bo);

% Pulkkinen et al. 2007 method.
d = (mean_nonflag(E(:,1).*E(:,2)))^2-mean_nonflag(E(:,1).*E(:,1))*mean_nonflag(E(:,2).*E(:,2));
an = mean_nonflag(GIC(:,2).*E(:,2))*mean_nonflag(E(:,1).*E(:,2)) - mean_nonflag(GIC(:,2).*E(:,1))*mean_nonflag(E(:,2).*E(:,2));
aoP = an/d;
bn = mean_nonflag(GIC(:,2).*E(:,1))*mean_nonflag(E(:,1).*E(:,2)) - mean_nonflag(GIC(:,2).*E(:,2))*mean_nonflag(E(:,1).*E(:,1));
boP = bn/d;
fprintf('ao =  %7.4f; bo =  %7.4f (Pulkkinen 2007 et al. method)\n',aoP,boP);

% GIC(:,2) = aoE(:,1) + boE(:,2); for 1-minute data.
% Attempt to reproduce Watari by averaging to 1 minute
E1m = block_mean(E(:,:),60);
E1m = block_detrend_nonflag(E1m,size(E1m,1));
GIC1m = block_mean(GIC(:,2),60);
GIC1m = block_detrend_nonflag(GIC1m,size(GIC1m,1));
LIN = basic_linear(E1m,GIC1m);
ao1m = LIN.Weights(1);
bo1m = LIN.Weights(2);
fprintf('ao =  %7.4f; bo =  %7.4f (matrix method; 1-min aves)\n',ao1m,bo1m);

% GIC(:,2) = hxoB(:,1) + hyoB(:,2); % (LPF version is second column)
LIN = basic_linear(B(:,1:2),GIC(:,2));
GIC_GB(:,1) = basic_linear(B(:,1:2),LIN.Weights,'predict');
hox = LIN.Weights(1);
hoy = LIN.Weights(2);
fprintf('hxo = %7.4f; hyo = %7.4f (Using magnetic field)\n',hox,hoy);

% GIC(:,2) = hxoB(:,1) + hyoB(:,2) + hzoB(:,3);
LIN = basic_linear(B(:,1:3),GIC(:,2));
GICp3_TD03(:,2) = basic_linear(B(:,1:3),LIN.Weights,'predict');
hox = LIN.Weights(1);
hoy = LIN.Weights(2);
hoz = LIN.Weights(3);

fprintf('hxo = %7.4f; hyo = %7.4f; hzo = %.4f (Using magnetic field)\n',hox, hoy, hoz);

PE_GE = pe_nonflag(GIC(:,2),GIC_GE);
MSE_GE = mse_nonflag(GIC(:,2),GIC_GE);
CC_GE = corr(GIC(:,2),GIC_GE,'rows','complete');
fprintf('PE/CC/MSE of despiked GIC using E = %.2f/%.2f/%.3f\n',PE_GE,CC_GE,MSE_GE);

PE_GB = pe_nonflag(GIC(:,2),GIC_GB);
MSE_GB = mse_nonflag(GIC(:,2),GIC_GB);
CC_GB = corr(GIC(:,2),GIC_GB,'rows','complete');
fprintf('PE/CC/MSE of despiked GIC using B = %.2f/%.2f/%.3f\n',PE_GB,CC_GB,MSE_GB);

fname = sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,intervalno);
save(fname,'ao','bo','hox','hoy','GIC_GE','GIC_GB','PE_GE','PE_GB','CC_GE','CC_GB','MSE_GE','MSE_GB');

fprintf('compute_ab.m: Wrote %s\n',fname);

