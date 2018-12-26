function compute_TF(t,GIC,E,B,dateo,intervalno,opts)

dirmat = sprintf('mat/%s',dateo);

window = opts.window.functionstr; % TODO: Pass function handle.
method = opts.regression.method; 

% Compute transfer function with B driving E using FD method
[Z_EB,fe_EB,H_EB,t_EB,Ep_EB,SB,SE,Serr_EB] = transferfnFD(B(:,1:2),E(:,:),method,window);

PE_EB(1) = pe_nonflag(E(:,1),Ep_EB(:,1));
fprintf('PE of Ex using B = %.2f\n',PE_EB(1));
PE_EB(2) = pe_nonflag(E(:,2),Ep_EB(:,2));
fprintf('PE of Ey using B = %.2f\n',PE_EB(2));

% Compute transfer function with E driving GIC using FD method
% Note - should be using GIC(:,2), but transferfnFD does not handle that
% case
% GIC(:,2) is LPF
% GIC(:,3) is LPF despiked
[Z_GE,fe_GE,H_GE,t_GE,GICp_GE,SE,SG,Serr_GE] = transferfnFD(E(:,:),[GIC(:,2:3)],method,window);

PE_GE(1) = pe_nonflag(GIC(:,1),GICp_GE(:,1));
fprintf('PE of nondespiked GIC using E = %.2f\n',PE_GE(1));

PE_GE(2) = pe_nonflag(GIC(:,2),GICp_GE(:,2));
fprintf('PE of despiked GIC using E    = %.2f\n',PE_GE(2));

% Compute transfer function with B driving GIC using FD method
[Z_GB,fe_GB,H_GB,t_GB,GICp_GB,SB,SG,Serr_GB] = transferfnFD(B(:,1:2),[GIC(:,2:3)],method,window);

PE_GB(1) = pe_nonflag(GIC(:,1),GICp_GB(:,1));
fprintf('PE of nondespiked GIC using B = %.2f\n',PE_GB(1)); 

PE_GB(2) = pe_nonflag(GIC(:,2),GICp_GB(:,2));
fprintf('PE of despiked GIC using B = %.2f\n',PE_GB(2)); 

fname = sprintf('%s/compute_TF_%s-%d.mat',dirmat,dateo,intervalno);
save(fname);
fprintf('compute_TF.m: Wrote %s\n',fname);

FD_only = 1;

% Used for paper.  Requires ~32 GB RAM
Nc = 60*10; % Number of causal coefficients
Na = 60*10; % Number of acausal coefficients

if (FD_only == 0)
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