function aggregate_TFs(fnameab,fnametf,filestr,opts)

IO = struct();
EB = struct();
EG = struct();
BG = struct();

for k = 1:length(fnameab)
    fprintf('aggregate_TFs.m: Reading %s\n',fnameab{k}); 
    load(fnameab{k});

    GEo.Dateo{k,1} = GEo_Dateo;
    GBo.Dateo{k,1} = GBo_Dateo;

    GEo.Seconds(k,:) = GEo_Seconds;
    GBo.Seconds(k,:) = GBo_Seconds;

    GEo.Prediction(:,:,k) = GEo_Prediction;
    GBo.Prediction(:,:,k) = GBo_Prediction;

    GEo.Input_PSD(:,:,k) = GEo_Input_PSD;
    GBo.Input_PSD(:,:,k) = GBo_Input_PSD;

    GEo.Output_PSD(:,:,k) = GEo_Output_PSD;
    GBo.Output_PSD(:,:,k) = GBo_Output_PSD;

    GEo.Error_PSD(:,:,k) = GEo_Error_PSD;
    GBo.Error_PSD(:,:,k) = GBo_Error_PSD;

    GEo.Coherence(:,:,k) = GEo_Coherence;
    GBo.Coherence(:,:,k) = GBo_Coherence;
    
    GEo.PE(k,:) = GEo_PE;
    GBo.PE(k,:) = GBo_PE;

    GEo.CC(k,:) = GEo_PE;
    GBo.CC(k,:) = GBo_PE;

    GEo.MSE(k,:) = GEo_MSE;
    GBo.MSE(k,:) = GBo_MSE;

    GEo.ao(:,k) = GEo_ao;
    GBo.ao(:,k) = GBo_ao;

    GEo.bo(:,k) = GEo_bo;
    GBo.bo(:,k) = GBo_bo;
end

fprintf('------\n');

for k = 1:length(fnametf)

    load(fnametf{k});
    fprintf('aggregate_TFs.m: Reading %s\n',fnametf{k}); 

    IO.B(:,:,k) = B(:,1:2);
    IO.E(:,:,k) = E;
    IO.GIC(:,:,k) = GIC;

    EB.Dateo{k,1} = EB_Dateo;
    GE.Dateo{k,1} = GE_Dateo;
    GB.Dateo{k,1} = GB_Dateo;
    GBa.Dateo{k,1} = GBa_Dateo;

    EB.Seconds(k,:)  = EB_Seconds;
    GE.Seconds(k,:)  = GE_Seconds;
    GB.Seconds(k,:)  = GB_Seconds;
    GBa.Seconds(k,:) = GBa_Seconds;
    
    EB.Prediction(:,:,k)  = EB_Prediction;
    GE.Prediction(:,:,k)  = GE_Prediction;
    GB.Prediction(:,:,k)  = GB_Prediction;
    GBa.Prediction(:,:,k) = GBa_Prediction;
    
    EB.Input_PSD(:,:,k)  = EB_Input_PSD;
    GE.Input_PSD(:,:,k)  = GE_Input_PSD;
    GB.Input_PSD(:,:,k)  = GB_Input_PSD;
    GBa.Input_PSD(:,:,k) = GBa_Input_PSD;
    
    EB.Output_PSD(:,:,k)  = EB_Output_PSD;
    GE.Output_PSD(:,:,k)  = GE_Output_PSD;
    GB.Output_PSD(:,:,k)  = GB_Output_PSD;
    GBa.Output_PSD(:,:,k) = GBa_Output_PSD;
    
    EB.Error_PSD(:,:,k)  = EB_Error_PSD;
    GE.Error_PSD(:,:,k)  = GE_Error_PSD;
    GB.Error_PSD(:,:,k)  = GB_Error_PSD;
    GBa.Error_PSD(:,:,k) = GBa_Error_PSD;

    EB.Coherence(:,:,k)  = EB_Coherence;
    GE.Coherence(:,:,k)  = GE_Coherence;
    GB.Coherence(:,:,k)  = GB_Coherence;
    GBa.Coherence(:,:,k) = GBa_Coherence;
    
    EB.fe  = EB_fe;
    GE.fe  = GE_fe;
    GB.fe  = GB_fe;
    GBa.fe = GB_fe;
    
    EB.PE(k,:)  = EB_PE;
    GE.PE(k,:)  = GE_PE;
    GB.PE(k,:)  = GB_PE;
    GBa.PE(k,:) = GBa_PE;
    
    EB.CC(k,:)  = EB_CC;
    GE.CC(k,:)  = GE_CC;
    GB.CC(k,:)  = GB_CC;
    GBa.CC(k,:) = GBa_CC;
    
    EB.MSE(k,:)  = EB_MSE;
    GE.MSE(k,:)  = GE_MSE;
    GB.MSE(k,:)  = GB_MSE;
    GBa.MSE(k,:) = GBa_MSE;

    EB.Z(:,:,k)  = EB_Z;
    GE.Z(:,:,k)  = GE_Z;
    GB.Z(:,:,k)  = GB_Z;
    GBa.Z(:,:,k) = GBa_Z;
    
    EB.H(:,:,k)  = EB_H;
    GE.H(:,:,k)  = GE_H;
    GB.H(:,:,k)  = GB_H;
    GBa.H(:,:,k) = GBa_H;
    
end

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
fprintf('aggregate_TFs.m: Saving %s\n',fnamemat);
save(fnamemat,'GE','GEo','GB','GBo','GBa','EB','IO');
fprintf('aggregate_TFs.m: Saved %s\n',fnamemat);
