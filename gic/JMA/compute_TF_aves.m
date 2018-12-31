function compute_TF_aves(filestr)

fnamemat = sprintf('mat/aggregate_TFs-%s.mat',filestr);

fprintf('compute_TF_aves.m: Loading %s\n',fnamemat);
load(fnamemat);
fprintf('compute_TF_aves.m: Loaded %s\n',fnamemat);

fields = {'Z_Mean','Z_Median','Z_Huber','Z_Std',...
          'Zabs_Mean','Zabs_Median','Zabs_Huber','Zabs_Std',...
          'Phi_Mean','Phi_Median','Phi_Huber','Phi_Std'};

for f = 1:length(fields)
    EB = setfield(EB,fields{f},[]);
    GE = setfield(GE,fields{f},[]);
    GB = setfield(GB,fields{f},[]);
end

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
    
    if ~isempty(S.aobo)
        S.aobo_Mean = mean(S.aobo,1);
        S.aobo_Standard_Error = std(S.aobo,0,1)/sqrt(size(S.aobo,2));
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

        if (0)
            W = squeeze(sqrt(S.Input_PSD(:,1,:).^2 + S.Input_PSD(:,2,:).^2));
            %W = squeeze(sqrt(S.Output_PSD(:,2,:).^2));        
            Ws = mean(W,2);        
            W = W./repmat(Ws,1,size(W,2));
        end
        
        if (0)
            W = transpose(S.PE(:,2));
            W = repmat(W,size(z,1),1);
            Ws = mean(W,2);
            W = W./repmat(Ws,1,size(W,2));
        end
        
        if (0)
            W = ones(size(z));
        end
        
        %keyboard
        S.Z_Mean(:,i)   = mean(z,2);
        S.Z_Median(:,i) = median(z,2);

        if (size(z,2) > 2)
            S.Z_Huber(:,i) = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
        else
            S.Z_Huber(:,i) = NaN;
        end
                
        % transposes in above b/c mlochuber only averages across rows.
        S.Z_Standard_Error(:,i) = std(z,0,2)/sqrt(size(z,2));

        S.Zabs_Mean(:,i)   = mean(abs(z),2);
        S.Zabs_Median(:,i) = median(abs(z),2);
        if (size(z,2) > 2)
            S.Zabs_Huber(:,i)  = mlochuber(abs(z)')';
        else
            S.Zabs_Huber(:,i) = NaN;
        end
        S.Zabs_Standard_Error(:,i) = std(abs(z),0,2)/sqrt(size(abs(z),2));

        V = sort(bootstrp(1000,@mean,abs(z).').',2);
        S.Zabs_Mean_Standard_Error_Upper(:,i) = V(:,1000-50)-S.Zabs_Mean(:,i); 
        S.Zabs_Mean_Standard_Error_Lower(:,i) = S.Zabs_Mean(:,i)-V(:,50);
        
        S.Phi_Mean(:,i)   = (180/pi)*atan2(imag(S.Z_Mean(:,i)),real(S.Z_Mean(:,i)));
        S.Phi_Median(:,i) = (180/pi)*atan2(imag(S.Z_Median(:,i)),real(S.Z_Median(:,i)));
        S.Phi_Huber(:,i)  = (180/pi)*atan2(imag(S.Z_Huber(:,i)),real(S.Z_Huber(:,i)));

    end

    if ~isempty(S.aobo)
        for k = 1:size(In,3) % Loop over days

            S.Predictiono_Mean(:,1,k) = S.aobo_Mean(1)*In(:,1,k) + S.aobo_Mean(2)*In(:,2,k);
            S.PEo_Mean(k,1)           = pe(Out(:,1,k),S.Predictiono_Mean(:,1,k));
            S.Predictiono_Mean_Error(:,1,k) = Out(:,1,k)-S.Predictiono_Mean(:,1,k);
            S.MSEo_Mean(k,1)          = mse(Out(:,1,k),S.Predictiono_Mean(:,1,k));
            
            fprintf('Model 1, Interval %02d: PE in-sample: %6.3f; PE using mean: = %6.3f;\n',...
                    k,S.PEo(k,1),S.PEo_Mean(k,1));
        end
        fprintf('___________________________________________________________________________\n')
        fprintf('Model 1  Ave PE:         in-sample: %6.3f;     using mean: %6.3f;\n',...
                mean(S.PEo(:,1)),mean(S.PEo_Mean(:,1)));
        fprintf('Model 1  PE Err:         in-sample: %6.3f;     using mean: %6.3f;\n',...
                std(S.PEo(:,1))/sqrt(size(S.PEo,1)),std(S.PEo_Mean(:,1))/sqrt(size(S.PEo_Mean,1)));
        fprintf('Model 1 Ave MSE:         in-sample: %6.3f;     using mean: %6.3f;\n',...
                mean(S.MSEo(:,1)),mean(S.MSEo_Mean(:,1)));

            fprintf('___________________________________________________________________________\n')
    end
    
    
    for k = 1:size(In,3)
                
        S.Prediction_Mean(:,:,k) = Zpredict(S.fe,S.Z_Mean,In(:,:,k));
        S.PE_Mean(k,:)           = pe(Out(:,:,k),S.Prediction_Mean(:,:,k));
        S.Prediction_Mean_Error(:,:,k) = Out(:,:,k)-S.Prediction_Mean(:,:,k);

        tmp = Zpredict(S.fe,S.Z_Median,In(:,:,k));
        S.PE_Median(k,:)           = pe(Out(:,:,k),tmp);

        if ~all(S.Z_Huber)
            tmp  = Zpredict(S.fe,S.Z_Huber,In(:,:,k));
            S.PE_Huber(k,:)            = pe(Out(:,:,k),tmp);
        else
            S.PE_Huber(k,:) = [NaN,NaN];
        end
        
        fprintf('Model 2, Interval %02d: PE in-sample: %6.3f;    using: mean: %6.3f; median = %6.3f; huber = %6.3f;\n',...
                k,S.PE(k,2),S.PE_Mean(k,2),S.PE_Median(k,2),S.PE_Huber(k,2));
    end
    
    fprintf('___________________________________________________________________________\n')
        fprintf('Model 2 Ave PE:          in-sample: %6.3f;     using mean: %6.3f; median %6.3f; huber = %6.3f;\n',...
            mean(S.PE(:,2)),mean(S.PE_Mean(:,2)),mean(S.PE_Median(:,2)),mean(S.PE_Huber(:,2)));
        fprintf('Model 2 PE Err:          in-sample: %6.3f;     using mean: %6.3f;\n',...
                std(S.PE(:,2))/sqrt(size(S.PE,1)),std(S.PE_Mean(:,2))/sqrt(size(S.PE_Mean,1)));
    fprintf('___________________________________________________________________________\n')
