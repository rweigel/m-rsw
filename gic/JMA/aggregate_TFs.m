function aggregate_TFs(dateos,filestr)

IO = struct();
EB = struct();
EG = struct();
BG = struct();

k = 1;
for j = 1:length(dateos)
    dateo = dateos{j};

    dirmat = sprintf('mat/%s',dateo);

    f = 1;
    fprintf('aggregate_TFs.m: Working on %s\n',dateo);
    while 1
        fnamemat = sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,f);
        if ~exist(fnamemat,'file')
            break;
        end
        load(fnamemat);
        GE.PEo(k,1) = PE_GE;
        GB.PEo(k,1) = PE_GB;

        GE.CCo(k,1) = CC_GE;
        GB.CCo(k,1) = CC_GB;
        
        GE.MSEo(k,1) = MSE_GE;
        GB.MSEo(k,1) = MSE_GB;
        
        GE.aobo(k,:) = [ao,bo];
        GB.aobo(k,:) = [hox,hoy];
        f = f + 1;
        k = k + 1;
    end
end

k = 1;
for j = 1:length(dateos)
    dateo = dateos{j};

    dirmat = sprintf('mat/%s',dateo);
    
    f = 1;
    fprintf('aggregate_TFs.m: Working on %s\n',dateo);
    while 1
        fnamemat = sprintf('%s/compute_TF_%s-%s-%d.mat',dirmat,dateo,filestr,f);
        if ~exist(fnamemat,'file')
            break;
        end
        load(fnamemat);
        fprintf('  Read %s\n',fnamemat); 

        IO.B(:,:,k) = B(:,1:2);
        IO.E(:,:,k) = E;
        IO.GIC(:,:,k) = GIC(:,2:3);

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
                
        EB.S_Error(:,:,k) = Serr_EB;
        GE.S_Error(:,:,k) = Serr_GE;
        GB.S_Error(:,:,k) = Serr_GB;
        
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

        f = f + 1;
        k = k + 1;
    end

end

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
fprintf('aggregate_TFs.m: Saving %s\n',fnamemat);
save(fnamemat,'EB','GE','GB','IO');
fprintf('aggregate_TFs.m: Saved %s\n',fnamemat);
