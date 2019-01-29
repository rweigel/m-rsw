function fname = compute_TF(t,GIC,E,B,dateo,intervalno,filestr,opts)

dirmat = sprintf('mat/%s',dateo);

% Compute transfer function with B driving E using FD method
[Z_EB,fe_EB,H_EB,t_EB,Ep_EB] = transferfnFD(B(:,1:2),E,opts);

for k = 1:2
    PE_EB(k)  = pe_nonflag(E(:,k),Ep_EB(:,k));
    MSE_EB(k) = mse_nonflag(E(:,k),Ep_EB(:,k));
    CC_EB(k)  = cc_nonflag(E(:,k),Ep_EB(:,k));
end

fprintf('compute_TF.m: PE/CC/MSE of Ex using B                       = %.2f/%.2f/%.3f\n',PE_EB(1),CC_EB(1),MSE_EB(1));
fprintf('compute_TF.m: PE/CC/MSE of Ey using B                       = %.2f/%.2f/%.3f\n',PE_EB(2),CC_EB(2),MSE_EB(2));

% Compute transfer function with E driving GIC using FD method
% GIC(:,1) is LPF
% GIC(:,2) is LPF despiked
[Z_GE,fe_GE,H_GE,t_GE,GICp_GE] = transferfnFD(E,GIC,opts);

for k = 1:2
    PE_GE(k)  = pe_nonflag(GIC(:,k),GICp_GE(:,k));
    MSE_GE(k) = mse_nonflag(GIC(:,k),GICp_GE(:,k));
    CC_GE(k)  = cc_nonflag(GIC(:,k),GICp_GE(:,k));
end

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using E          = %.2f/%.2f/%.3f\n',PE_GE(1),CC_GE(1),MSE_GE(1));
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using E             = %.2f/%.2f/%.3f\n',PE_GE(2),CC_GE(2),MSE_GE(2));

% Compute transfer function with B driving GIC using FD method
[Z_GB,fe_GB,H_GB,t_GB,GICp_GB] = transferfnFD(B(:,1:2),GIC,opts);

for k = 1:2
    PE_GB(k)  = pe_nonflag(GIC(:,k),GICp_GB(:,k));
    MSE_GB(k) = mse_nonflag(GIC(:,k),GICp_GB(:,k));
    CC_GB(k)  = cc_nonflag(GIC(:,k),GICp_GB(:,k));
end

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using B          = %.2f/%.2f/%.3f\n',PE_GB(1),CC_GB(1),MSE_GB(1)); 
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using B             = %.2f/%.2f/%.3f\n',PE_GB(2),CC_GB(2),MSE_GB(2)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)
%
% Bx term      a(w)        Zxx           b(w)      Zyx
Z_GBa(:,1) = Z_GE(:,1).*Z_EB(:,1) + Z_GE(:,2).*Z_EB(:,3);
% By term      a(w)        Zxy       b(w)         Zyy
Z_GBa(:,2) = Z_GE(:,1).*Z_EB(:,2) + Z_GE(:,2).*Z_EB(:,4);

% Bx term      a(w)     Zxx           b(w)       Zyx
Z_GBa(:,3) = Z_GE(:,3).*Z_EB(:,1) + Z_GE(:,4).*Z_EB(:,3);
% By term      a(w)     Zxy           b(w)       Zyy
Z_GBa(:,4) = Z_GE(:,3).*Z_EB(:,2) + Z_GE(:,4).*Z_EB(:,4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(B,1);
f = [0:N/2]'/N; % Assumes N is even.
H_GBa = Z2H(fe_GB,Z_GBa,f);

GICp_GBa = Zpredict(fe_GB,Z_GBa,B(:,1:2));

for k = 1:2
    PE_GBa(k)  = pe_nonflag(GIC(:,k),GICp_GBa(:,k));
    MSE_GBa(k) = mse_nonflag(GIC(:,k),GICp_GBa(:,k));
    CC_GBa(k)  = cc_nonflag(GIC(:,k),GICp_GBa(:,k));
end

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using E''         = %.2f/%.2f/%.3f\n',PE_GBa(1),CC_GBa(1),MSE_GBa(1)); 
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using E''            = %.2f/%.2f/%.3f\n',PE_GBa(2),CC_GBa(2),MSE_GBa(2)); 

clear k N f

fname = sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,intervalno);
save(fname);
fprintf('compute_TF.m: Wrote %s\n',fname);


FD_only = 1;
if (FD_only == 0)

    % Used for paper.  Requires ~32 GB RAM
    Nc = 60*10; % Number of causal coefficients
    Na = 60*10; % Number of acausal coefficients

    fprintf('Computing TD model 1/5\n');
    % Compute transfer function with B driving E using TD method
    [Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B(:,1:2),E(:,:),Nc,Na);

    fprintf('Computing TD model 2/5\n');
    % Compute transfer function with E driving GIC using TD method
    [Z2_TD,f2_TD,H2_TD,t2_TD,GICp2_TD] = transferfnTD(E(:,:),GIC(:,2),Nc,Na);
    % FD functions are computing using both columns of GIC.  Make TD output
    % look same.
    GICp2_TD(:,2) = GICp2_TD(:,1);
    GICp2_TD(:,1) = NaN*GICp2_TD(:,1);

    fprintf('Computing TD model 3/5\n');
    % Compute transfer function with Ex driving GIC using TD method
    [Z2a_TD,f2a_TD,H2a_TD,t2a_TD,GICp2a_TD] = transferfnTD(E(:,1),GIC(:,2),Nc,Na);

    fprintf('Computing TD model 4/5\n');
    % Compute transfer function with Ey driving GIC using TD method
    [Z2b_TD,f2b_TD,H2b_TD,t2b_TD,GICp2b_TD] = transferfnTD(E(:,2),GIC(:,2),Nc,Na);

    fprintf('Computing TD model 5/5\n');
    % Compute transfer function with B driving GIC using TD method
    [Z3_TD,f3_TD,H3_TD,t3_TD,GICp3_TD] = transferfnTD(B(:,1:2),GIC(:,2),Nc,Na);
    GICp3_TD(:,2) = GICp3_TD(:,1);
    GICp3_TD(:,1) = NaN*GICp3_TD(:,1);

    save(sprintf('%s/compute_TF_%s-%d.mat',dirmat,dateo,intervalno))
end