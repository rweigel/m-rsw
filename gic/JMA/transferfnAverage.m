function Savg = transferfnAverage(S,opts)

Savg = struct();

a = 60*10;
b = 86400-a+1;

Savg.In_PSD  = mean(S.In_PSD,3); 
Savg.Out_PSD = mean(S.Out_PSD,3); 

Savg.In_PSD_Median  = median(S.In_PSD,3); 
Savg.Out_PSD_Median = median(S.Out_PSD,3); 


if isfield(S,'ao')
    Savg.ao = mean(S.ao,3);
    Savg.bo = mean(S.bo,3);
    Savg.ao_Median = median(S.ao,3);
    Savg.bo_Median = median(S.bo,3);
    
    for k = 1:size(S.In,3) % Loop over days
        Savg.Predicted(:,1,k) = Savg.ao(1)*S.In(:,1,k) + Savg.bo(1)*S.In(:,2,k);
        Savg.Predicted(:,2,k) = Savg.ao(2)*S.In(:,1,k) + Savg.bo(2)*S.In(:,2,k);

        Savg.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));
        Savg.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));
        Savg.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));

        Savg.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Predicted(:,:,k),opts);
        Savg.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Predicted(:,:,k),opts);

        Savg.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Error_PSD(:,:,k);
        
        Savg.Predicted_Median(:,1,k) = Savg.ao_Median(1)*S.In(:,1,k) + Savg.bo_Median(1)*S.In(:,2,k);
        Savg.Predicted_Median(:,2,k) = Savg.ao_Median(2)*S.In(:,1,k) + Savg.bo_Median(2)*S.In(:,2,k);

        Savg.PE_Median(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Predicted_Median(a:b,:,k));
        Savg.MSE_Median(1,:,k) = mse(S.Out(a:b,:,k),Savg.Predicted_Median(a:b,:,k));
        Savg.CC_Median(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Predicted_Median(a:b,:,k));

        Savg.Error_PSD_Median(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Predicted_Median(:,:,k),opts);
        Savg.Coherence_Median(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Predicted_Median(:,:,k),opts);
        
        fprintf('transferfnAverage.m: Interval %02d: PEx in-sample: %6.3f; using: mean: %6.3f\n',...
                 k,S.PE(1,1,k),Savg.PE(1,1,k));
        fprintf('transferfnAverage.m: Interval %02d: PEy in-sample: %6.3f; using: mean: %6.3f\n',...
                 k,S.PE(1,2,k),Savg.PE(1,2,k));

    end
    return
end

Savg.fe = S.fe;

for i = 1:4

    z = squeeze(S.Z(:,i,:));

    W = ones(size(z));
    z = z.*W;

    % Z
    Savg.Z_StdErr(:,i) = std(z,0,2)/sqrt(size(z,2));
    Savg.Z(:,i)   = mean(z,2);
    Savg.Z_Median(:,i) = median(z,2);
    if (size(z,2) > 2) % Need more than two points to compute 
        Savg.Z_Huber(:,i) = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
    else
        Savg.Z_Huber(:,i) = NaN;
    end

    % |Z|
    Savg.Zabs_StdErr(:,i) = std(abs(z),0,2)/sqrt(size(z,2));            
    Savg.Zabs(:,i)   = mean(abs(z),2);
    Savg.Zabs_Median(:,i) = median(abs(z),2);

    if (size(z,2) > 2)
        Savg.Zabs_Huber(:,i)  = mlochuber(abs(z)')';
    else
        Savg.Zabs_Huber(:,i) = NaN;
    end

    % Phi
    phi = atan2(imag(z),real(z));
    phi = unwrap(phi,[],2);
    Savg.Phi(:,i)   = mean(phi,2);
    Savg.Phi_StdErr(:,i) = std(phi,0,2)/sqrt(size(z,2));            

    Savg.Phi_Mean2(:,i)  = atan2(imag(Savg.Z(:,i)),real(Savg.Z(:,i)));
    Savg.Phi_Median(:,i) = atan2(imag(Savg.Z_Median(:,i)),real(Savg.Z_Median(:,i)));
    if (size(z,2) > 2)
        Savg.Phi_Huber(:,i) = atan2(imag(Savg.Z_Huber(:,i)),real(Savg.Z_Huber(:,i)));
    else
        Savg.Phi_Huber(:,i) = NaN;
    end

    % H
    h = squeeze(S.H(:,i,:));
    Savg.H(:,i)   = mean(h,2);
    Savg.H_Median(:,i) = median(h,2);
    Savg.H_StdErr(:,i) = std(h,0,2)/sqrt(size(h,2));
    
    % Very slow. TODO: Consider only a restricted range of h.
    %V = sort(bootstrp(1000,@mean,abs(h).').',2);
    %S.H_Mean_StdErr_Upper(:,i) = V(:,150); 
    %S.H_Mean_StdErr_Lower(:,i) = V(:,1000-150);        
    %S.H_Huber(:,i)  = ( mlochuber(h') )';
    % transposes b/c mlochuber only averages across rows.

end
    
for k = 1:size(S.In,3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Savg.Predicted(:,:,k) = Zpredict(Savg.fe,Savg.Z,S.In(:,:,k));

    Savg.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));
    Savg.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));
    Savg.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Predicted(a:b,:,k));

    Savg.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Predicted(:,:,k),opts);
    Savg.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Predicted(:,:,k),opts);

    Savg.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Error_PSD(:,:,k);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('transferfnAverage.m: Interval %02d: PEx in-sample: %6.3f; using: mean: %6.3f\n',...
             k,S.PE(1,1,k),Savg.PE(1,1,k));
    fprintf('transferfnAverage.m: Interval %02d: PEy in-sample: %6.3f; using: mean: %6.3f\n',...
             k,S.PE(1,2,k),Savg.PE(1,2,k));

end
