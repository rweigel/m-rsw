function compute_TF_aves(opts)

filestr = opts.filestr;

diary off;
delete(sprintf('log/compute_TF_aves_%s.txt',filestr));
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);
fprintf('compute_TF_aves.m: Loading %s\n',fnamemat);
File = load(fnamemat);
fprintf('compute_TF_aves.m: Loaded %s\n',fnamemat);

GEo = compute(File.GEo, File.IO.E, File.IO.GIC, 'G/Eo');
GE = compute(File.GE, File.IO.E, File.IO.GIC, 'G/E');

GBo = compute(File.GBo, File.IO.B, File.IO.GIC, 'G/Bo');
GB = compute(File.GB, File.IO.B, File.IO.GIC, 'G/B');
GBa = compute(File.GBa, File.IO.B, File.IO.GIC, 'G/Ba');

EB = compute(File.EB, File.IO.B, File.IO.E, 'E/B');

summary(EB,'E/B');

summary(GBo,'G/Bo');
summary(GEo,'G/Eo');

summary(GE,'G/E');
summary(GBa,'G/Ba');
summary(GB,'G/B');

r = mean(GEo.MSE_Mean(:,2))/mean(GE.MSE_Mean(:,2));
r = mean(GEo.MSE_Mean(:,2)./GE.MSE_Mean(:,2));
rb = boot95(GEo.MSE_Mean(:,2)./GE.MSE_Mean(:,2));
fprintf('<Model 1 (Eo) MSE>/<Model 2 (E) MSE>   = %4.2f +/- [%4.2f,%4.2f]\n',r,rb);

r = mean(GEo.MSE_Mean(:,2))/mean(GBa.MSE_Mean(:,2));
r = mean(GEo.MSE_Mean(:,2)./GBa.MSE_Mean(:,2));
rb = boot95(GEo.MSE_Mean(:,2)./GBa.MSE_Mean(:,2));
fprintf('<Model 1 (Eo) MSE>/<Model 3 (E'') MSE>  = %4.2f +/- [%4.2f,%4.2f]\n',r,rb);

r = mean(GEo.MSE_Mean(:,2))/mean(GB.MSE_Mean(:,2));
r = mean(GEo.MSE_Mean(:,2)./GB.MSE_Mean(:,2));
rb = boot95(GEo.MSE_Mean(:,2)./GB.MSE_Mean(:,2));
fprintf('<Model 1 (Eo) MSE>/<Model 4 (B) MSE>   = %4.2f +/- [%4.2f,%4.2f]\n',r,rb);

fnamemat = sprintf('mat/compute_TF_aves-%s.mat',filestr);
fprintf('compute_TF_aves.m: Saving %s\n',fnamemat);
save(fnamemat,'GEo','GE','GB','GBo','GBa','EB');


eex = squeeze(File.IO.E(:,1,:));
eey = squeeze(File.IO.E(:,2,:));
fprintf('var(Ex)/var(Ey) = %.2f\n',var(eex(:)),var(eey(:)));

fprintf('compute_TF_aves.m: Saved %s\n',fnamemat);

diary off;

function W = weight(Z,In,Out,method)

    W = ones(size(Z));
    
    if (0)
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

end

function S = compute(S,In,Out,ts)

    for i = 1:2
        S.Input_PSD_Mean(:,i) = mean(squeeze(S.Input_PSD(:,i,:)),2); 
        S.Output_PSD_Mean(:,i) = mean(squeeze(S.Output_PSD(:,i,:)),2); 
        S.Input_PSD_Median(:,i) = median(squeeze(S.Input_PSD(:,i,:)),2); 
        S.Output_PSD_Median(:,i) = median(squeeze(S.Output_PSD(:,i,:)),2); 
    end
    
    if isfield(S,'ao')
        S.ao_Mean = mean(S.ao,2);
        S.bo_Mean = mean(S.bo,2);
        S.ao_Median = median(S.ao,2);
        S.bo_Median = median(S.bo,2);
    else
        for i = 1:4
            
            z = squeeze(S.Z(:,i,:));
            W = weight(z,In,Out,'const');
            z = z.*W;

            S.Z_StdErr(:,i) = std(z,0,2)/sqrt(size(z,2));
            S.Z_Mean(:,i)   = mean(z,2);
            S.Z_Median(:,i) = median(z,2);
            if (size(z,2) > 2) % Need more than two points to compute 
                S.Z_Huber(:,i) = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
            else
                S.Z_Huber(:,i) = NaN;
            end

            S.Zabs_StdErr(:,i) = std(abs(z),0,2)/sqrt(size(z,2));            
            S.Zabs_Mean(:,i)   = mean(abs(z),2);
            S.Zabs_Median(:,i) = median(abs(z),2);

            if (size(z,2) > 2)
                S.Zabs_Huber(:,i)  = mlochuber(abs(z)')';
            else
                S.Zabs_Huber(:,i) = NaN;
            end

            phi = atan2(imag(z),real(z));
            phi = unwrap(phi,[],2);
            S.Phi_Mean(:,i)   = mean(phi,2);
            S.Phi_StdErr(:,i) = std(phi,0,2)/sqrt(size(z,2));            

            S.Phi_Mean2(:,i)  = atan2(imag(S.Z_Mean(:,i)),real(S.Z_Mean(:,i)));
            S.Phi_Median(:,i) = atan2(imag(S.Z_Median(:,i)),real(S.Z_Median(:,i)));
            if (size(z,2) > 2)
                S.Phi_Huber(:,i) = atan2(imag(S.Z_Huber(:,i)),real(S.Z_Huber(:,i)));
            else
                S.Phi_Huber(:,i) = NaN;
            end

            h = squeeze(S.H(:,i,:));
            S.H_Mean(:,i)   = mean(h,2);
            S.H_Median(:,i) = median(h,2);
            S.H_StdErr(:,i) = std(h,0,2)/sqrt(size(h,2));

            % Very slow. TODO: Consider only a restricted range of h.
            %V = sort(bootstrp(1000,@mean,abs(h).').',2);
            %S.H_Mean_StdErr_Upper(:,i) = V(:,150); 
            %S.H_Mean_StdErr_Lower(:,i) = V(:,1000-150);        
            %S.H_Huber(:,i)  = ( mlochuber(h') )';
            % transposes b/c mlochuber only averages across rows.
            
        end
    end
    
    a = 60*10;
    b = 86400-a+1;
    
    if isfield(S,'ao')
        for k = 1:size(In,3) % Loop over days

            S.Prediction_Mean(:,1,k) = S.ao_Mean(1)*In(:,1,k) + S.bo_Mean(1)*In(:,2,k);
            S.Prediction_Mean(:,2,k) = S.ao_Mean(2)*In(:,1,k) + S.bo_Mean(2)*In(:,2,k);

            S.PE_Mean(k,:)  = pe(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));
            S.MSE_Mean(k,:) = mse(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));
            S.CC_Mean(k,:)  = cc(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));

            S.Error_PSD_Mean(:,:,k) = smoothSpectra(Out(:,:,k)-S.Prediction_Mean(:,:,k),opts);
            S.Coherence_Mean(:,:,k) = smoothCoherence(Out(:,:,k),S.Prediction_Mean(:,:,k),opts);
            
            S.Prediction_Median(:,1,k) = S.ao_Median(1)*In(:,1,k) + S.bo_Median(1)*In(:,2,k);
            S.Prediction_Median(:,2,k) = S.ao_Median(2)*In(:,1,k) + S.bo_Median(2)*In(:,2,k);
            
            S.PE_Median(k,:)  = pe(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));
            S.MSE_Median(k,:) = mse(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));
            S.CC_Median(k,:)  = cc(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));

            S.Error_PSD_Median(:,:,k) = smoothSpectra(Out(:,:,k)-S.Prediction_Median(:,:,k),opts);
            S.Coherence_Median(:,:,k) = smoothCoherence(Out(:,:,k),S.Prediction_Median(:,:,k),opts);
            
            fprintf('%s, Interval %02d: PE in-sample: %6.3f; using mean: %6.3f;\n',...
                    ts,k,S.PE(k,2),S.PE_Mean(k,2));
        end
        summary(S,ts,1);
    else

        for k = 1:size(In,3)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            S.Prediction_Mean(:,:,k) = Zpredict(S.fe,S.Z_Mean,In(:,:,k));

            S.PE_Mean(k,:)  = pe(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));
            S.MSE_Mean(k,:) = mse(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));
            S.CC_Mean(k,:)  = cc(Out(a:b,:,k),S.Prediction_Mean(a:b,:,k));

            S.Error_PSD_Mean(:,:,k) = smoothSpectra(Out(:,:,k)-S.Prediction_Mean(:,:,k),opts);
            S.Coherence_Mean(:,:,k) = smoothCoherence(Out(:,:,k),S.Prediction_Mean(:,:,k),opts);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            S.Prediction_Median(:,:,k) = Zpredict(S.fe,S.Z_Median,In(:,:,k));

            S.PE_Median(k,:)  = pe(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));
            S.MSE_Median(k,:) = mse(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));
            S.CC_Median(k,:)  = cc(Out(a:b,:,k),S.Prediction_Median(a:b,:,k));
        
            S.Error_PSD_Median(:,:,k) = smoothSpectra(Out(:,:,k)-S.Prediction_Median(:,:,k),opts);
            S.Coherence_Median(:,:,k) = smoothCoherence(Out(:,:,k),S.Prediction_Median(:,:,k),opts);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
            if ~all(S.Z_Huber)
                S.Prediction_Huber(:,:,k)  = Zpredict(S.fe,S.Z_Huber,In(:,:,k));

                S.PE_Huber(k,:)  = pe(Out(a:b,:,k),S.Prediction_Huber(a:b,:,k));
                S.MSE_Huber(k,:) = mse(Out(a:b,:,k),S.Prediction_Huber(a:b,:,k));
                S.CC_Huber(k,:)  = cc(Out(a:b,:,k),S.Prediction_Huber(a:b,:,k));

                S.Error_PSD_Median(:,:,k) = smoothSpectra(Out(:,:,k)-S.Prediction_Huber(:,:,k),opts);
                S.Coherence_Median(:,:,k) = smoothCoherence(Out(:,:,k),S.Prediction_Huber(:,:,k),opts);
            else
                S.Prediction_Huber = NaN*S.Prediction_Mean;
                S.PE_Huber(k,:)  = [NaN,NaN];
                S.MSE_Huber(k,:) = [NaN,NaN];
                S.CC_Huber(k,:)  = [NaN,NaN];
                S.Error_PSD_Median(:,:,k) = NaN*S.Error_PSD_Mean(:,:,k);
                S.Coherence_Median(:,:,k) = NaN*S.Error_PSD_Mean(:,:,k);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
            
            fprintf('%s, Interval %02d: PE in-sample: %6.3f; using: mean: %6.3f; median = %6.3f; huber = %6.3f;\n',...
                    ts,k,S.PE(k,2),S.PE_Mean(k,2),S.PE_Median(k,2),S.PE_Huber(k,2));
        end
        
        summary(S,ts,2);

    end
    
    fprintf('---------------------------------------------------------------------\n');
end

function summary(S,ts,m)

    if nargin == 2
        m = 0;
    end
    
    if m == 0 
        fprintf('___________________________________________________________________________\n')
        fprintf('%s  Ave PE            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
                ts,mean(S.PE(:,2)),mean(S.PE_Mean(:,2)));
        fprintf('%s  PE 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,norm95(S.PE(:,2)),norm95(S.PE_Mean(:,2)));
        fprintf('%s  PE 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,boot95(S.PE(:,2)),boot95(S.PE_Mean(:,2)));

        fprintf('%s  Ave CC            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
                ts,mean(S.CC(:,2)),mean(S.CC_Mean(:,2)));
        fprintf('%s  CC 95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,norm95(S.CC(:,2)),norm95(S.CC_Mean(:,2)));
        fprintf('%s  CC 95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,boot95(S.CC(:,2)),boot95(S.CC_Mean(:,2)));

        fprintf('%s  Ave MSE           :  in-sample: %6.3f;     using mean: %6.3f;\n',...
                ts,mean(S.MSE(:,2)),mean(S.MSE_Mean(:,2)));
        fprintf('%s  MSE 95%% Lims (norm):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,norm95(S.MSE(:,2)),norm95(S.MSE_Mean(:,2)));
        fprintf('%s  MSE 95%% Lims (boot):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
                ts,boot95(S.MSE(:,2)),boot95(S.MSE_Mean(:,2)));
            
        if isfield(S,'ao')
            unit = '[A/(V/km)]';
            if strmatch(ts,'G/Bo')
                unit = '[mA/nT]';
            end
            fprintf('ao average = %6.1f [%6.3f,%6.3f] %s (boot)\n',1e3*S.ao_Mean(2),1e3*boot95(S.ao(:,2)),unit);
            fprintf('bo average = %6.1f [%6.3f,%6.3f] %s (boot)\n',1e3*S.bo_Mean(2),1e3*boot95(S.bo(:,2)),unit);
        end
        fprintf('___________________________________________________________________________\n')
    end
    
            
end

end
