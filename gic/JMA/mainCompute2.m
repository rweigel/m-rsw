function mainCompute2(GIC,E,B,Ix,dateo,intervalno)

dirmat = sprintf('mat/%s',dateo);

% Used for paper.  Requires ~32 GB RAM
Nc = 60*10; % Number of causal coefficients
Na = 60*10; % Number of acausal coefficients

% Compute transfer function with B driving E using FD method
[Z_FD_EB,fe_FD_EB,H_FD_EB,t_FD_EB,Ep_FD_EB] = transferfnFD(B(Ix,1:2),E(Ix,:),2,'rectangular');

% Compute transfer function with E driving GIC using FD method
% Note - should be using GIC(Ix,2), but transferfnFD does not handle that
% case
[Z_FD_GE,fe_FD_GE,H_FD_GE,t_FD_GE,GICp_FD_GE] = transferfnFD(E(Ix,:),GIC(Ix,1:2),2,'rectangular');

% Compute transfer function with B driving GIC using FD method
[Z_FD_GB,fe_FD_GB,H_FD_GB,t_FD_GB,GICp_FD_GB] = transferfnFD(B(Ix,1:2),GIC(Ix,1:2),2,'rectangular');

save(sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,intervalno))

FD_only = 1;

if (FD_only == 0)
    fprintf('Computing TD model 1/5\n');
    % Compute transfer function with B driving E using TD method
    [Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B(Ix,1:2),E(Ix,:),Nc,Na);

    fprintf('Computing TD model 2/5\n');
    % Compute transfer function with E driving GIC using TD method
    [Z2_TD,f2_TD,H2_TD,t2_TD,GICp2_TD] = transferfnTD(E(Ix,:),GIC(Ix,2),Nc,Na);
    % FD functions are computing using both columns of GIC.  Make TD output
    % look same.
    GICp2_TD(:,2) = GICp2_TD(:,1);
    GICp2_TD(:,1) = NaN*GICp2_TD(:,1);

    fprintf('Computing TD model 3/5\n');
    % Compute transfer function with Ex driving GIC using TD method
    [Z2a_TD,f2a_TD,H2a_TD,t2a_TD,GICp2a_TD] = transferfnTD(E(Ix,1),GIC(Ix,2),Nc,Na);

    fprintf('Computing TD model 4/5\n');
    % Compute transfer function with Ey driving GIC using TD method
    [Z2b_TD,f2b_TD,H2b_TD,t2b_TD,GICp2b_TD] = transferfnTD(E(Ix,2),GIC(Ix,2),Nc,Na);

    fprintf('Computing TD model 5/5\n');
    % Compute transfer function with B driving GIC using TD method
    [Z3_TD,f3_TD,H3_TD,t3_TD,GICp3_TD] = transferfnTD(B(Ix,1:2),GIC(Ix,2),Nc,Na);
    GICp3_TD(:,2) = GICp3_TD(:,1);
    GICp3_TD(:,1) = NaN*GICp3_TD(:,1);

    save(sprintf('%s/mainCompute2_TD_%s-%d.mat',dirmat,dateo,intervalno))
end