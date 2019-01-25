function aggregate_TFs(fnameab,fnametf,filestr)

IO = struct();
EB = struct();
EG = struct();
BG = struct();

k = 1;
for k = 1:length(fnameab)
    fprintf('aggregate_TFs.m: Reading %s\n',fnameab{k}); 
    load(fnameab{k});

    GE.Predictiono(:,:,k) = ao*E(:,1) + bo*E(:,2);
    GB.Predictiono(:,:,k) = hox*B(:,1) + hoy*B(:,2);

    GE.Erroro_PSD(:,:,k) = smoothSpectra(GE.Predictiono(:,1,k)-GIC(:,2),'parzen');
    GB.Erroro_PSD(:,:,k) = smoothSpectra(GB.Predictiono(:,1,k)-GIC(:,2),'parzen');

    GE.PEo(k,:) = PE_GEo;
    GB.PEo(k,:) = PE_GBo;

    GE.CCo(k,:) = CC_GEo;
    GB.CCo(k,:) = CC_GBo;

    GE.MSEo(k,:) = MSE_GEo;
    GB.MSEo(k,:) = MSE_GBo;

    GE.aobo(k,:) = [ao,bo];
    GB.aobo(k,:) = [hox,hoy];
end

fprintf('------\n');

for k = 1:length(fnametf)

    load(fnametf{k});
    fprintf('aggregate_TFs.m: Reading %s\n',fnametf{k}); 

    IO.B(:,:,k) = B(:,1:2);
    IO.E(:,:,k) = E;
    IO.GIC(:,:,k) = GIC;

    EB.Prediction(:,:,k) = Ep_EB;
    GE.Prediction(:,:,k) = GICp_GE;
    GB.Prediction(:,:,k) = GICp_GB;

    EB.Prediction_Error(:,:,k) = E - Ep_EB;
    GE.Prediction_Error(:,:,k) = GIC - GICp_GE;
    GB.Prediction_Error(:,:,k) = GIC - GICp_GB;

    EB.Input_PSD(:,:,k) = SB;
    GE.Input_PSD(:,:,k) = SE;
    GB.Input_PSD(:,:,k) = SB;

    EB.Output_PSD(:,:,k) = SE;
    GE.Output_PSD(:,:,k) = SG;
    GB.Output_PSD(:,:,k) = SG;

    EB.fe = fe_EB;
    GE.fe = fe_GE;
    GB.fe = fe_GB;

    EB.PE(k,:) = PE_EB;
    GE.PE(k,:) = PE_GE;
    GB.PE(k,:) = PE_GB;

    EB.CC(k,:) = CC_EB;
    GE.CC(k,:) = CC_GE;
    GB.CC(k,:) = CC_GB;

    EB.MSE(k,:) = MSE_EB;
    GE.MSE(k,:) = MSE_GE;
    GB.MSE(k,:) = MSE_GB;

    EB.Error_PSD(:,:,k) = Serr_EB;
    GE.Error_PSD(:,:,k) = Serr_GE;
    GB.Error_PSD(:,:,k) = Serr_GB;

    EB.Z(:,:,k) = Z_EB;
    GE.Z(:,:,k) = Z_GE;
    GB.Z(:,:,k) = Z_GB;

    EB.H(:,:,k) = H_EB;
    GE.H(:,:,k) = H_GE;
    GB.H(:,:,k) = H_GB;

    % GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)

    % Bx term          a(w)        Zxx           b(w)      Zyx
    GB.Z_Alt(:,1,k) = Z_GE(:,1).*Z_EB(:,1) + Z_GE(:,2).*Z_EB(:,3);
    % By term           a(w)        Zxy       b(w)         Zyy
    GB.Z_Alt(:,2,k) = Z_GE(:,1).*Z_EB(:,2) + Z_GE(:,2).*Z_EB(:,4);

    % Bx term            a(w)     Zxx           b(w)       Zyx
    GB.Z_Alt(:,3,k) = Z_GE(:,3).*Z_EB(:,1) + Z_GE(:,4).*Z_EB(:,3);
    % By term            a(w)     Zxy           b(w)       Zyy
    GB.Z_Alt(:,4,k) = Z_GE(:,3).*Z_EB(:,2) + Z_GE(:,4).*Z_EB(:,4);

    GB.Prediction_Alt(:,:,k) = Zpredict(GB.fe,GB.Z_Alt(:,:,k),IO.B(:,:,k));
    GB.Prediction_Alt_Error(:,:,k) = GIC - GB.Prediction_Alt(:,:,k);

    GB.Error_Alt_PSD(:,:,k) = smoothSpectra(GB.Prediction_Alt_Error(:,:,k),'parzen');

    GB.PE_Alt(k,1) = pe_nonflag(GIC(:,1),GB.Prediction_Alt(:,1,k));
    GB.PE_Alt(k,2) = pe_nonflag(GIC(:,2),GB.Prediction_Alt(:,2,k));

    GB.MSE_Alt(k,1) = mse_nonflag(GIC(:,1),GB.Prediction_Alt(:,1,k));
    GB.MSE_Alt(k,2) = mse_nonflag(GIC(:,2),GB.Prediction_Alt(:,2,k));

    GB.CC_Alt(k,1) = mse_nonflag(GIC(:,1),GB.Prediction_Alt(:,1,k),'rows','complete');
    GB.CC_Alt(k,2) = mse_nonflag(GIC(:,2),GB.Prediction_Alt(:,2,k),'rows','complete');

end

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
fprintf('aggregate_TFs.m: Saving %s\n',fnamemat);
save(fnamemat,'EB','GE','GB','IO');
fprintf('aggregate_TFs.m: Saved %s\n',fnamemat);
