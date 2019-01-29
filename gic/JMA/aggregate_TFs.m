function aggregate_TFs(fnameab,fnametf,filestr,opts)

IO = struct();
EB = struct();
EG = struct();
BG = struct();

for k = 1:length(fnameab)
    fprintf('aggregate_TFs.m: Reading %s\n',fnameab{k}); 
    load(fnameab{k});

    GEo.Prediction(:,:,k) = GICp_GEo;
    GBo.Prediction(:,:,k) = GICp_GBo;

    GEo.Input_PSD(:,:,k) = smoothSpectra(E,opts);
    GBo.Input_PSD(:,:,k) = smoothSpectra(B,opts);

    GEo.Output_PSD(:,:,k) = smoothSpectra(GIC,opts);
    GBo.Output_PSD(:,:,k) = smoothSpectra(GIC,opts);

    GEo.Error_PSD(:,:,k) = smoothSpectra(GIC - GICp_GEo,opts);
    GBo.Error_PSD(:,:,k) = smoothSpectra(GIC - GICp_GBo,opts);

    GEo.Coherence(:,:,k) = smoothCoherence(GIC,GICp_GEo,opts);
    GBo.Coherence(:,:,k) = smoothCoherence(GIC,GICp_GBo,opts);
    
    GEo.PE(k,:) = PE_GEo;
    GBo.PE(k,:) = PE_GBo;

    GEo.CC(k,:) = CC_GEo;
    GBo.CC(k,:) = CC_GBo;

    GEo.MSE(k,:) = MSE_GEo;
    GBo.MSE(k,:) = MSE_GBo;

    GEo.ao(k,:) = ao;
    GEo.bo(k,:) = bo;

    GBo.ao(k,:) = hxo;
    GBo.bo(k,:) = hyo;
end

fprintf('------\n');

for k = 1:length(fnametf)

    load(fnametf{k});
    fprintf('aggregate_TFs.m: Reading %s\n',fnametf{k}); 

    IO.B(:,:,k) = B(:,1:2);
    IO.E(:,:,k) = E;
    IO.GIC(:,:,k) = GIC;

    EB.Prediction(:,:,k)  = Ep_EB;
    GE.Prediction(:,:,k)  = GICp_GE;
    GB.Prediction(:,:,k)  = GICp_GB;
    GBa.Prediction(:,:,k) = GICp_GBa;
    
    EB.Input_PSD(:,:,k)  = smoothSpectra(B(:,1:2),opts);
    GE.Input_PSD(:,:,k)  = smoothSpectra(E,opts);
    GB.Input_PSD(:,:,k)  = smoothSpectra(B(:,1:2),opts);
    GBa.Input_PSD(:,:,k) = smoothSpectra(E,opts);
    
    EB.Output_PSD(:,:,k)  = smoothSpectra(E,opts);
    GE.Output_PSD(:,:,k)  = smoothSpectra(GIC,opts);
    GB.Output_PSD(:,:,k)  = smoothSpectra(GIC,opts);
    GBa.Output_PSD(:,:,k) = smoothSpectra(GIC,opts);
    
    EB.Error_PSD(:,:,k)  = smoothSpectra(E   - Ep_EB,opts);
    GE.Error_PSD(:,:,k)  = smoothSpectra(GIC - GICp_GE,opts);
    GB.Error_PSD(:,:,k)  = smoothSpectra(GIC - GICp_GB,opts);
    GBa.Error_PSD(:,:,k) = smoothSpectra(GIC - GICp_GBa,opts);

    EB.Coherence(:,:,k)  = smoothCoherence(E,Ep_EB,opts);
    GE.Coherence(:,:,k)  = smoothCoherence(GIC,GICp_GE,opts);
    GB.Coherence(:,:,k)  = smoothCoherence(GIC,GICp_GB,opts);
    GBa.Coherence(:,:,k) = smoothCoherence(GIC,GICp_GBa,opts);
    
    EB.fe = fe_EB;
    GE.fe = fe_GE;
    GB.fe = fe_GB;
    GBa.fe = fe_GB;
    
    EB.PE(k,:) = PE_EB;
    GE.PE(k,:) = PE_GE;
    GB.PE(k,:) = PE_GB;
    GBa.PE(k,:) = PE_GBa;
    
    EB.CC(k,:) = CC_EB;
    GE.CC(k,:) = CC_GE;
    GB.CC(k,:) = CC_GB;
    GBa.CC(k,:) = CC_GBa;
    
    EB.MSE(k,:) = MSE_EB;
    GE.MSE(k,:) = MSE_GE;
    GB.MSE(k,:) = MSE_GB;
    GBa.MSE(k,:) = MSE_GBa;

    EB.Z(:,:,k) = Z_EB;
    GE.Z(:,:,k) = Z_GE;
    GB.Z(:,:,k) = Z_GB;
    GBa.Z(:,:,k) = Z_GBa;
    
    EB.H(:,:,k) = H_EB;
    GE.H(:,:,k) = H_GE;
    GB.H(:,:,k) = H_GB;
    GBa.H(:,:,k) = H_GBa;
    
end

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
fprintf('aggregate_TFs.m: Saving %s\n',fnamemat);
save(fnamemat,'GE','GEo','GB','GBo','GBa','EB','IO');
fprintf('aggregate_TFs.m: Saved %s\n',fnamemat);
