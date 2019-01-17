function compute_TF_aves(filestr)

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);

fprintf('compute_TF_aves.m: Loading %s\n',fnamemat);
load(fnamemat);
fprintf('compute_TF_aves.m: Loaded %s\n',fnamemat);

fprintf('-----------------------------\n')
fprintf('PEs for Input = E, Output = GIC\n')
fprintf('-----------------------------\n')
GE = compute(GE,IO.E,IO.GIC);

fprintf('-----------------------------\n')
fprintf('PEs for Input = B, Output = GIC\n')
fprintf('-----------------------------\n')
GB = compute(GB,IO.B,IO.GIC);

fprintf('-----------------------------\n')
fprintf('PEs for Input = B, Output = E\n')
fprintf('-----------------------------\n')
EB = compute(EB,IO.B,IO.E);

fnamemat = sprintf('mat/compute_TF_aves-%s.mat',filestr);
fprintf('compute_TF_aves.m: Saving %s\n',fnamemat);
save(fnamemat,'EB','GE','GB');
fprintf('compute_TF_aves.m: Saved %s\n',fnamemat);

function S = compute(S,In,Out)

    if isfield(S,'aobo')
        S.aobo_Mean = mean(S.aobo,1);
        S.aobo_Standard_Error = std(S.aobo,0,1)/sqrt(size(S.aobo,2));
    end
    
    for i = 1:2
        S.Input_PSD_Mean(:,i) = mean(squeeze(S.Input_PSD(:,i,:)),2); 
        S.Output_PSD_Mean(:,i) = mean(squeeze(S.Output_PSD(:,i,:)),2); 
    end
    
    for i = 1:4

        h = squeeze(S.H(:,i,:));
        S.H_Mean(:,i)   = mean(h,2);
        S.H_Median(:,i) = median(h,2);
        S.H_Standard_Error(:,i) = std(h,0,2)/sqrt(size(h,2));

        % Very slow. TODO: Consider only a restricted range of h.
        %V = sort(bootstrp(1000,@mean,abs(h).').',2);
        %S.H_Mean_Standard_Error_Upper(:,i) = V(:,150); 
        %S.H_Mean_Standard_Error_Lower(:,i) = V(:,1000-150);        
        %S.H_Huber(:,i)  = ( mlochuber(h') )';
        % transposes b/c mlochuber only averages across rows.
        
        z = squeeze(S.Z(:,i,:));

        if (1)
            W = squeeze(1./(sqrt(S.Input_PSD(:,1,:).^2 + S.Input_PSD(:,2,:).^2)));
            % Gives no change in PE of GE and decrease in PE of GB.
            %W = squeeze(sqrt(S.Output_PSD(:,2,:).^2));        
            Ws = mean(W,2);        
            W = W./repmat(Ws,1,size(W,2));
        end

        if (0)
            % Give increase in PE of GE and decrease in PE of GB.
            W = squeeze(S.Output_PSD(:,2,:)./S.Error_PSD(:,2,:));
            % Gives no change in PE of GE and decrease in PE of GB.
            %W = squeeze(sqrt(S.Output_PSD(:,2,:).^2));        
            Ws = mean(W,2);        
            W = W./repmat(Ws,1,size(W,2));
        end
        
        if (0)
            % Gives only slight overall increase
            W = transpose(sqrt(S.PE(:,2)));
            W = repmat(W,size(z,1),1);
            Ws = mean(W,2);
            W = W./repmat(Ws,1,size(W,2));
        end

        if (0)
            W = 1./max(squeeze(Out(:,2,:)));
            W = repmat(W,size(z,1),1);
            Ws = mean(W,2);
            W = W./repmat(Ws,1,size(W,2));
        end

        if (0)
            W = ones(size(z));
        end
        
        %keyboard
        S.Z_Mean(:,i)   = mean(W.*z,2);
        S.Z_Median(:,i) = median(z,2);
        %S.Z_Median(:,i) = trimmean(z,30,'round',2);
        if (size(z,2) > 2) % Need more than two points to compute 
            S.Z_Huber(:,i) = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
        else
            S.Z_Huber(:,i) = NaN;
        end
        
        if isfield(S,'Z_Alt')
            z_alt = squeeze(S.Z_Alt(:,i,:));
            S.Z_Alt_Mean(:,i) = mean(z_alt,2);
            S.Zabs_Alt_Mean(:,i) = mean(abs(z_alt),2);
        end

        S.Zabs_Mean(:,i)   = mean(abs(z),2);
        S.Zabs_Median(:,i) = median(abs(z),2);
        if (size(z,2) > 2)
            S.Zabs_Huber(:,i)  = mlochuber(abs(z)')';
        else
            S.Zabs_Huber(:,i) = NaN;
        end

        S.Phi_Mean(:,i)   = (180/pi)*atan2(imag(S.Z_Mean(:,i)),real(S.Z_Mean(:,i)));
        S.Phi_Median(:,i) = (180/pi)*atan2(imag(S.Z_Median(:,i)),real(S.Z_Median(:,i)));
        if (size(z,2) > 2)
            S.Phi_Huber(:,i) = (180/pi)*atan2(imag(S.Z_Huber(:,i)),real(S.Z_Huber(:,i)));
        else
            S.Phi_Huber(:,i) = NaN;
        end
        if isfield(S,'Z_Alt')
            S.Phi_Alt_Mean(:,i)   = (180/pi)*atan2(imag(S.Z_Alt_Mean(:,i)),real(S.Z_Alt_Mean(:,i)));        
        end
        
        S.Z_Standard_Error(:,i) = std(z,0,2)/sqrt(size(z,2));
        S.Zabs_Standard_Error(:,i) = std(abs(z),0,2)/sqrt(size(abs(z),2));

    end


    a = 60*300;
    b = 86400-a+1;

    if isfield(S,'aobo')
        for k = 1:size(In,3) % Loop over days

            tmp = S.aobo_Mean(1)*In(:,1,k) + S.aobo_Mean(2)*In(:,2,k);
            S.PEo_Mean(k,1)           = pe(Out(a:b,2,k),tmp(a:b,1));
            S.CCo_Mean(k,1)           = corr(Out(a:b,2,k),tmp(a:b,1),'rows','complete');

            Erroro_PSD_Mean(:,:,k) = smoothSpectra(Out(:,2,k)-tmp,'parzen');            

            fprintf('Model 1, Interval %02d: PE in-sample: %6.3f; PE using mean: %6.3f;\n',...
                    k,S.PEo(k,1),S.PEo_Mean(k,1));
        end
        fprintf('___________________________________________________________________________\n')
        fprintf('Model 1  Ave PE            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
                mean(S.PEo(:,1)),mean(S.PEo_Mean(:,1)));
        fprintf('Model 1  PE 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                norm95(S.PEo(:,1)),norm95(S.PEo_Mean(:,1)));
        fprintf('Model 1  PE 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                boot95(S.PEo(:,1)),boot95(S.PEo_Mean(:,1)));

        fprintf('Model 1  Ave CC            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
                mean(S.CCo(:,1)),mean(S.CCo_Mean(:,1)));
        fprintf('Model 1  CC 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                norm95(S.CCo(:,1)),norm95(S.CCo_Mean(:,1)));
        fprintf('Model 1  CC 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                boot95(S.CCo(:,1)),boot95(S.CCo_Mean(:,1)));

        fprintf('___________________________________________________________________________\n')

        S.Erroro_PSD_Mean = mean(squeeze(Erroro_PSD_Mean(:,1,:)),2);
    end


    for k = 1:size(In,3)

        tmp = Zpredict(S.fe,S.Z_Mean,In(:,:,k));
        S.PE_Mean(k,:)           = pe(Out(a:b,:,k),tmp(a:b,:));
        S.CC_Mean(k,1)           = corr(Out(a:b,1,k),tmp(a:b,1),'rows','complete');
        S.CC_Mean(k,2)           = corr(Out(a:b,2,k),tmp(a:b,2),'rows','complete');

        Error_PSD_Mean(:,:,k) = smoothSpectra(Out(:,:,k)-tmp,'parzen');

        if isfield(S,'Z_Alt_Mean')
            tmp = Zpredict(S.fe,S.Z_Alt_Mean,In(:,:,k));
            S.PE_Alt_Mean(k,:) = pe(Out(a:b,:,k),tmp(a:b,:));
        else
            S.PE_Alt_Mean(k,:) = [NaN,NaN];
        end
        
        tmp = Zpredict(S.fe,S.Z_Median,In(:,:,k));
        S.PE_Median(k,:) = pe(Out(a:b,:,k),tmp(a:b,:));

        tmp = Zpredict(S.fe,S.Z_Median,In(:,:,k));
        S.PE_Median(k,:) = pe(Out(a:b,:,k),tmp(a:b,:));
        
        if ~all(S.Z_Huber)
            tmp  = Zpredict(S.fe,S.Z_Huber,In(:,:,k));
            S.PE_Huber(k,:) = pe(Out(a:b,:,k),tmp(a:b,:));
            S.CC_Huber(k,1) = corr(Out(a:b,1,k),tmp(a:b,1),'rows','complete');
            S.CC_Huber(k,2) = corr(Out(a:b,1,k),tmp(a:b,1),'rows','complete');
        else
            S.PE_Huber(k,:) = [NaN,NaN];
            S.CC_Huber(k,:) = [NaN,NaN];
        end
        
        fprintf('Model 2, Interval %02d: PE in-sample: %6.3f; using: mean: %6.3f; alt (mean): %6.3f; median = %6.3f; huber = %6.3f;\n',...
                k,S.PE(k,2),S.PE_Mean(k,2),S.PE_Alt_Mean(k,2),S.PE_Median(k,2),S.PE_Huber(k,2));
    end

    for i = 1:2
        S.Error_PSD_Mean(:,i) = mean(squeeze(Error_PSD_Mean(:,i,:)),2);
    end

    fprintf('___________________________________________________________________________\n')
    fprintf('Model 2 Ave PE              : in-sample: %6.3f;     using mean: %6.3f; alt (mean): %6.3f; median %6.3f; huber = %6.3f;\n',...
        mean(S.PE(:,2)),mean(S.PE_Mean(:,2)),mean(S.PE_Alt_Mean(:,2)),mean(S.PE_Median(:,2)),mean(S.PE_Huber(:,2)));
    fprintf('Model 2  PE 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            norm95(S.PE(:,2)),norm95(S.PE_Mean(:,2)));
    fprintf('Model 2  PE 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            boot95(S.PE(:,2)),boot95(S.PE_Mean(:,2)));
        
    fprintf('Model 2 Ave CC              : in-sample: %6.3f;     using mean: %6.3f\n',...
        mean(S.CC(:,2)),mean(S.CC_Mean(:,2)));
    fprintf('Model 2  PE CC%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            norm95(S.CC(:,2)),norm95(S.CC_Mean(:,2)));
    fprintf('Model 2  CC 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            boot95(S.CC(:,2)),boot95(S.CC_Mean(:,2)));
    fprintf('___________________________________________________________________________\n');
    
    if isfield(S,'Z_Alt_Mean')
        for k = 1:size(In,3)
        
            tmp = Zpredict(S.fe,S.Z_Alt_Mean,In(:,:,k));
            S.PE_Alt_Mean(k,:)           = pe(Out(a:b,:,k),tmp(a:b,:));
            S.CC_Alt_Mean(k,1)           = corr(Out(a:b,1,k),tmp(a:b,1),'rows','complete');
            S.CC_Alt_Mean(k,2)           = corr(Out(a:b,2,k),tmp(a:b,2),'rows','complete');

            tmp = Zpredict(S.fe,S.Z_Alt_Mean,In(:,:,k));
            Error_Alt_PSD_Mean(:,:,k) = smoothSpectra(Out(:,:,k)-tmp,'parzen');        

            fprintf('Model 3, Interval %02d: PE in-sample: %6.3f; using: mean: %6.3f;\n',...
                    k,S.PE_Alt(k,2),S.PE_Alt_Mean(k,2));
        end
        fprintf('___________________________________________________________________________\n')
        fprintf('Model 3 Ave PE              : in-sample: %6.3f;     using mean: %6.3f;\n',...
            mean(S.PE_Alt(:,2)),mean(S.PE_Alt_Mean(:,2)));
        fprintf('Model 3  PE 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                norm95(S.PE_Alt(:,2)),norm95(S.PE_Alt_Mean(:,2)));
        fprintf('Model 3  PE 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                boot95(S.PE_Alt(:,2)),boot95(S.PE_Alt_Mean(:,2)));

        fprintf('Model 3 Ave CC              : in-sample: %6.3f;     using mean: %6.3f\n',...
            mean(S.CC_Alt(:,2)),mean(S.CC_Alt_Mean(:,2)));
        fprintf('Model 3  PE CC%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                norm95(S.CC_Alt(:,2)),norm95(S.CC_Alt_Mean(:,2)));
        fprintf('Model 3  CC 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                boot95(S.CC_Alt(:,2)),boot95(S.CC_Alt_Mean(:,2)));
        fprintf('___________________________________________________________________________\n')

        for i = 1:2
            S.Error_Alt_PSD_Mean(:,i) = mean(squeeze(Error_Alt_PSD_Mean(:,i,:)),2);
        end
    
    end


