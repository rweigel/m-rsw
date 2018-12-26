function compute_TF_aves()

fnamemat = sprintf('mat/aggregate_TFs.mat');

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
GE = compute(GE);

fprintf('-----------------------------\n')
fprintf('PEs for Input = B, Output = GIC\n')
fprintf('-----------------------------\n')
GB = compute(GB);

fprintf('-----------------------------\n')
fprintf('PEs for Input = B, Output = E\n')
fprintf('-----------------------------\n')
EB = compute(EB);

fnamemat = sprintf('mat/compute_TF_aves.mat');
fprintf('compute_TF_aves.m: Saving %s\n',fnamemat);
save(fnamemat,'EB','GE','GB');
fprintf('compute_TF_aves.m: Saved %s\n',fnamemat);


function S = compute(S)

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
        
        S.Z_Mean(:,i)   = mean(z,2);
        S.Z_Median(:,i) = median(z,2);
        S.Z_Huber(:,i)  = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
        % transposes in above b/c mlochuber only averages across rows.
        S.Z_Standard_Error(:,i) = std(z,0,2)/sqrt(size(z,2));

        
        S.Zabs_Mean(:,i)   = mean(abs(z),2);
        S.Zabs_Median(:,i) = median(abs(z),2);
        S.Zabs_Huber(:,i)  = mlochuber(abs(z)')';
        S.Zabs_Standard_Error(:,i) = std(abs(z),0,2)/sqrt(size(abs(z),2));

        V = sort(bootstrp(1000,@mean,abs(z).').',2);
        S.Zabs_Mean_Standard_Error_Upper(:,i) = V(:,1000-50)-S.Zabs_Mean(:,i); 
        S.Zabs_Mean_Standard_Error_Lower(:,i) = S.Zabs_Mean(:,i)-V(:,50);
        
        S.Phi_Mean(:,i)   = (180/pi)*atan2(imag(S.Z_Mean(:,i)),real(S.Z_Mean(:,i)));
        S.Phi_Median(:,i) = (180/pi)*atan2(imag(S.Z_Median(:,i)),real(S.Z_Median(:,i)));
        S.Phi_Huber(:,i)  = (180/pi)*atan2(imag(S.Z_Huber(:,i)),real(S.Z_Huber(:,i)));

    end

    for k = 1:size(S.Input,3)
        S.Prediction_Mean(:,:,k) = Zpredict(S.fe,S.Z_Mean,S.Input(:,:,k));
        S.PE_Mean(k,:)           = pe(S.Output(:,:,k),S.Prediction_Mean(:,:,k));

        S.Prediction_Median(:,:,k) = Zpredict(S.fe,S.Z_Median,S.Input(:,:,k));
        S.PE_Median(k,:)           = pe(S.Output(:,:,k),S.Prediction_Median(:,:,k));

        S.Prediction_Huber(:,:,k)  = Zpredict(S.fe,S.Z_Huber,S.Input(:,:,k));
        S.PE_Huber(k,:)            = pe(S.Output(:,:,k),S.Prediction_Huber(:,:,k));

        fprintf('Interval %02d: in-sample: %5.2f; mean = %5.2f; median = %5.2f; huber = %5.2f;\n',...
                k,S.PE(k,2),S.PE_Mean(k,2),S.PE_Median(k,2),S.PE_Huber(k,2));
    end
    
    fprintf('___________________________________________________________________________\n')
    fprintf('Averages:    in-sample: %5.2f; mean = %5.2f; median = %5.2f; huber = %5.2f;\n',...
            mean(S.PE(:,2)),mean(S.PE_Mean(:,2)),mean(S.PE_Median(:,2)),mean(S.PE_Huber(:,2)));
    fprintf('___________________________________________________________________________\n')
