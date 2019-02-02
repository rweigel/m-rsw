function fname = compute_TF(t,GIC,E,B,dateo,intervalno,filestr,opts)

dirmat = sprintf('mat/%s',dateo);

% Compute transfer function with B driving E using FD method
[EB_Z,EB_fe,EB_H,EB_t,EB_Prediction] = transferfnFD(B(:,1:2),E,opts);

for k = 1:2
    EB_PE(k)  = pe_nonflag(E(:,k),EB_Prediction(:,k));
    EB_MSE(k) = mse_nonflag(E(:,k),EB_Prediction(:,k));
    EB_CC(k)  = cc_nonflag(E(:,k),EB_Prediction(:,k));
end

EB_Dateo   = dateo;
EB_Seconds = [t(1),t(end)];

EB_Input_PSD  = smoothSpectra(B(:,1:2),opts);
EB_Output_PSD = smoothSpectra(E,opts);
EB_Error_PSD  = smoothSpectra(E-EB_Prediction,opts);
EB_Coherence  = smoothCoherence(E,EB_Prediction,opts);
EB_Phi        = atan2(imag(EB_Z),real(EB_Z));

fprintf('compute_TF.m: PE/CC/MSE of Ex using B                       = %.2f/%.2f/%.3f\n',EB_PE(1),EB_CC(1),EB_MSE(1));
fprintf('compute_TF.m: PE/CC/MSE of Ey using B                       = %.2f/%.2f/%.3f\n',EB_PE(2),EB_CC(2),EB_MSE(2));
    
% Compute transfer function with E driving GIC using FD method
% GIC(:,1) is LPF
% GIC(:,2) is LPF despiked
[GE_Z,GE_fe,GE_H,GE_t,GE_Prediction] = transferfnFD(E,GIC,opts);

for k = 1:2
    GE_PE(k)  = pe_nonflag(GIC(:,k),GE_Prediction(:,k));
    GE_MSE(k) = mse_nonflag(GIC(:,k),GE_Prediction(:,k));
    GE_CC(k)  = cc_nonflag(GIC(:,k),GE_Prediction(:,k));
end

GE_Dateo   = dateo;
GE_Seconds = [t(1),t(end)];

GE_Input_PSD   = smoothSpectra(E,opts);
GE_Prediction  = GE_Prediction;
GE_Output_PSD  = smoothSpectra(GIC,opts);
GE_Error_PSD   = smoothSpectra(GIC - GE_Prediction,opts);
GE_Coherence   = smoothCoherence(GIC,GE_Prediction,opts);
GE_Phi         = atan2(imag(GE_Z),real(GE_Z));

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using E          = %.2f/%.2f/%.3f\n',GE_PE(1),GE_CC(1),GE_MSE(1));
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using E             = %.2f/%.2f/%.3f\n',GE_PE(2),GE_CC(2),GE_MSE(2));

% Compute transfer function with B driving GIC using FD method
[GB_Z,GB_fe,GB_H,GB_t,GB_Prediction] = transferfnFD(B(:,1:2),GIC,opts);

for k = 1:2
    GB_PE(k)  = pe_nonflag(GIC(:,k),GB_Prediction(:,k));
    GB_MSE(k) = mse_nonflag(GIC(:,k),GB_Prediction(:,k));
    GB_CC(k)  = cc_nonflag(GIC(:,k),GB_Prediction(:,k));
end

GB_Dateo   = dateo;
GB_Seconds = [t(1),t(end)];

GB_Input_PSD  = smoothSpectra(B(:,1:2),opts);
GB_Output_PSD = smoothSpectra(GIC,opts);
GB_Error_PSD  = smoothSpectra(GIC - GB_Prediction,opts);
GB_Coherence  = smoothCoherence(GIC,GB_Prediction,opts);
GB_Phi        = atan2(imag(GB_Z),real(GB_Z));

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using B          = %.2f/%.2f/%.3f\n',GB_PE(1),GB_CC(1),GB_MSE(1)); 
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using B             = %.2f/%.2f/%.3f\n',GB_PE(2),GB_CC(2),GB_MSE(2)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)
%
% Bx term      a(w)        Zxx           b(w)      Zyx
GBa_Z(:,1) = GE_Z(:,1).*EB_Z(:,1) + GE_Z(:,2).*EB_Z(:,3);
% By term      a(w)        Zxy       b(w)         Zyy
GBa_Z(:,2) = GE_Z(:,1).*EB_Z(:,2) + GE_Z(:,2).*EB_Z(:,4);

% Bx term      a(w)     Zxx           b(w)       Zyx
GBa_Z(:,3) = GE_Z(:,3).*EB_Z(:,1) + GE_Z(:,4).*EB_Z(:,3);
% By term      a(w)     Zxy           b(w)       Zyy
GBa_Z(:,4) = GE_Z(:,3).*EB_Z(:,2) + GE_Z(:,4).*EB_Z(:,4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(B,1);
f = [0:N/2]'/N; % Assumes N is even.
GBa_H = Z2H(GB_fe,GBa_Z,f);

GBa_Prediction = Zpredict(GB_fe,GBa_Z,B(:,1:2));

for k = 1:2
    GBa_PE(k)  = pe_nonflag(GIC(:,k),GBa_Prediction(:,k));
    GBa_MSE(k) = mse_nonflag(GIC(:,k),GBa_Prediction(:,k));
    GBa_CC(k)  = cc_nonflag(GIC(:,k),GBa_Prediction(:,k));
end

GBa_Dateo   = dateo;
GBa_Seconds = [t(1),t(end)];

GBa_Input_PSD  = smoothSpectra(E,opts);
GBa_Output_PSD = smoothSpectra(GIC,opts);
GBa_Error_PSD  = smoothSpectra(GIC - GBa_Prediction,opts);
GBa_Coherence  = smoothCoherence(GIC,GBa_Prediction,opts);

fprintf('compute_TF.m: PE/CC/MSE of nondespiked GIC using E''         = %.2f/%.2f/%.3f\n',GBa_PE(1),GBa_CC(1),GBa_MSE(1)); 
fprintf('compute_TF.m: PE/CC/MSE of despiked GIC using E''            = %.2f/%.2f/%.3f\n',GBa_PE(2),GBa_CC(2),GBa_MSE(2)); 

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