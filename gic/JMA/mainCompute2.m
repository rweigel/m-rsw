% Used for paper.  Requires ~32 GB RAM
Nc = 60*10; % Number of causal coefficients
Na = 60*10; % Number of acausal coefficients

Nc = 10; % Number of causal coefficients
Na = 10; % Number of acausal coefficients

% Compute transfer function with B driving E using FD method
[Z_FD,fe_FD,H_FD,t_FD,Ep_FD] = transferfnFD(B(Ix,:),E(Ix,:),2,'rectangular');

% Compute transfer function with E driving GIC using FD method
% Note - should be using GIC(Ix,2), but transferfnFD does not handle that
% case
[Z2_FD,fe2_FD,H2_FD,t2_FD,GICp2_FD] = transferfnFD(E(Ix,:),GIC(Ix,:),1,'rectangular');

% Compute transfer function with B driving GIC using FD method
[Z3_FD,fe3_FD,H3_FD,t3_FD,GICp3_FD] = transferfnFD(B(Ix,:),GIC(Ix,:),1,'rectangular');

% Compute transfer function with B driving E using TD method
[Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(B(Ix,:),E(Ix,:),Nc,Na);

% Compute transfer function with E driving GIC using TD method
[Z2_TD,f2_TD,H2_TD,t2_TD,GICp2_TD] = transferfnTD(E(Ix,:),GIC(Ix,2),Nc,Na);
% FD functions are computing using both columns of GIC.
GICp2_TD(:,2) = GICp2_TD(:,1);
GICp2_TD(:,1) = NaN*GICp2_TD(:,1);

% Compute transfer function with B driving GIC using TD method
[Z3_TD,f3_TD,H3_TD,t3_TD,GICp3_TD] = transferfnTD(B(Ix,:),GIC(Ix,2),Nc,Na);
GICp3_TD(:,2) = GICp3_TD(:,1);
GICp3_TD(:,1) = NaN*GICp3_TD(:,1);

save mainCompute2.mat;

