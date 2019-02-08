function Savg = transferfnAverage(S,opts)

Savg        = struct();
Savg.Mean   = struct();
Savg.Huber  = struct();
Savg.Median = struct();

a = 60*10;
b = 86400-a+1;

Savg.Mean.In_PSD  = mean(S.In_PSD,3); 
Savg.Mean.Out_PSD = mean(S.Out_PSD,3); 

Savg.Median.In_PSD  = median(S.In_PSD,3); 
Savg.Median.Out_PSD = median(S.Out_PSD,3); 

function z = cmedian(z,dim)
    z = median(real(z),dim) + sqrt(-1)*median(imag(z),dim);
    % Note that when computing median of complex numbers, 
    % it seems we should be able to do median(z,2) as is done with
    % mean(z,2). But there seems to be a bug in MATLAB:
    % u = [-1+2*sqrt(-1),0+2*sqrt(-1),1+2*sqrt(-1),2+2*sqrt(-1)];
    % Returns true as expected: real(mean(u,2)) == mean(real(u),2)
    % Returns false: real(median(u,2)) == median(real(u),2))
    % So the median is calculated by splitting z into real and
    % imaginary components. For consistency, this is done for mean() even
    % though it is not needed.
end

function z = cmean(z,dim)
    z = mean(real(z),dim) + sqrt(-1)*median(imag(z),dim);
end

function z = cmlochuber(z,dim)
    if dim == 1
        z = ( mlochuber(real(z)) + sqrt(-1)*mlochuber(imag(z)) );
    else
        % .' is non-conjugate transpose.
        z = ( mlochuber(real(z.')) + sqrt(-1)*mlochuber(imag(z.')) ).';
    end
end        
    
if isfield(S,'ao')

    Savg.Mean.ao = mean(S.ao,3);
    Savg.Mean.bo = mean(S.bo,3);
    Savg.Median.ao = median(S.ao,3);
    Savg.Median.bo = median(S.bo,3);
    Savg.Huber.ao = mlochuber(squeeze(S.ao)')';
    Savg.Huber.bo = mlochuber(squeeze(S.bo)')';

    for k = 1:size(S.In,3) % Loop over days
        
        Savg.Mean.Predicted(:,1,k) = Savg.Mean.ao(1)*S.In(:,1,k) + Savg.Mean.bo(1)*S.In(:,2,k);
        Savg.Mean.Predicted(:,2,k) = Savg.Mean.ao(2)*S.In(:,1,k) + Savg.Mean.bo(2)*S.In(:,2,k);

        Savg.Mean.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));
        Savg.Mean.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));
        Savg.Mean.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));

        Savg.Mean.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Mean.Predicted(:,:,k),opts);
        Savg.Mean.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Mean.Predicted(:,:,k),opts);

        Savg.Mean.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Mean.Error_PSD(:,:,k);

        %
        
        Savg.Median.Predicted(:,1,k) = Savg.Median.ao(1)*S.In(:,1,k) + Savg.Median.bo(1)*S.In(:,2,k);
        Savg.Median.Predicted(:,2,k) = Savg.Median.ao(2)*S.In(:,1,k) + Savg.Median.bo(2)*S.In(:,2,k);

        Savg.Median.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));
        Savg.Median.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));
        Savg.Median.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));

        Savg.Median.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Median.Predicted(:,:,k),opts);
        Savg.Median.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Median.Predicted(:,:,k),opts);
        
        Savg.Median.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Median.Error_PSD(:,:,k);

        %
        
        Savg.Huber.Predicted(:,1,k) = Savg.Huber.ao(1)*S.In(:,1,k) + Savg.Huber.bo(1)*S.In(:,2,k);
        Savg.Huber.Predicted(:,2,k) = Savg.Huber.ao(2)*S.In(:,1,k) + Savg.Huber.bo(2)*S.In(:,2,k);

        Savg.Huber.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));
        Savg.Huber.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));
        Savg.Huber.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));

        Savg.Huber.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Huber.Predicted(:,:,k),opts);
        Savg.Huber.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Huber.Predicted(:,:,k),opts);
        
        Savg.Huber.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Huber.Error_PSD(:,:,k);
        
        fprintf('transferfnAverage.m: Interval %02d: PEx in-sample: %6.3f; using: mean: %6.3f | median %6.3f | huber %6.3f\n',...
                 k,S.PE(1,1,k),Savg.Mean.PE(1,1,k),Savg.Median.PE(1,1,k),Savg.Huber.PE(1,1,k));
        fprintf('transferfnAverage.m: Interval %02d: PEy in-sample: %6.3f; using: mean: %6.3f | median %6.3f | huber %6.3f\n',...
                 k,S.PE(1,2,k),Savg.Mean.PE(1,2,k),Savg.Median.PE(1,2,k),Savg.Huber.PE(1,2,k));

    end
else

    Savg.Mean.fe = S.fe;
    Savg.Median.fe = S.fe;
    Savg.Huber.fe  = S.fe;

    fe = S.fe;
    
    for i = 1:4

        z = squeeze(S.Z(:,i,:));

        nancol = NaN*ones(size(z,1),1);

        W = ones(size(z));
        z = z.*W;
        
        % Z
        Savg.Mean.Z(:,i)        = mean(z,2);
        Savg.Mean.Z_StdErr(:,i) = std(z,0,2)/sqrt(size(z,2));

        Savg.Median.Z(:,i)          = cmedian(z,2);
        Savg.Median.Z_StdError(:,i) = Savg.Mean.Z_StdErr(:,i);

        Savg.Huber.Z(:,i) = nancol;
        Savg.Huber.Z_StdError(:,i) = nancol;
        if (size(z,2) > 2) % Need more than two points to compute 
            Savg.Huber.Z(:,i) = cmlochuber(z,2);
            Savg.Huber.Z_StdError(:,i) = Savg.Mean.Z_StdErr(:,i);
        end

        % |Z|
        Savg.Mean.Zabs(:,i)  = mean(abs(z),2);
        Savg.Mean.Zabs2(:,i) = abs(Savg.Mean.Z(:,i));

        Savg.Mean.Zabs_StdErr(:,i)  = std(abs(z),0,2)/sqrt(size(z,2));            
        Savg.Mean.Zabs2_StdErr(:,i) = Savg.Mean.Zabs_StdErr(:,i);
        
        Savg.Median.Zabs(:,i)  = median(abs(z),2);
        Savg.Median.Zabs2(:,i) = abs(Savg.Median.Z(:,i));
        Savg.Median.Zabs_StdErr(:,i)  = Savg.Mean.Zabs_StdErr(:,i);
        Savg.Median.Zabs2_StdErr(:,i) = Savg.Mean.Zabs_StdErr(:,i);

        Savg.Huber.Zabs(:,i)  = nancol;
        Savg.Huber.Zabs2(:,i) = nancol;
        Savg.Huber.Zabs_StdErr(:,i)  = nancol;
        Savg.Huber.Zabs2_StdErr(:,i) = nancol;
        
        if (size(z,2) > 2) % Need more than two points to compute 
            % mlochuber not applicable to on-sided distribution so
            % Savg.Huber.Zabs(:,i)  = mlochuber(abs(z)')';
            % is not applicable.
            Savg.Huber.Zabs2(:,i) = abs(Savg.Huber.Z(:,i));
            Savg.Huber.Zabs2_StdErr(:,i) = Savg.Mean.Zabs_StdErr(:,i);
        end

        % Phi
        phi = atan2(imag(z),real(z));
        phi = unwrap(phi,[],2);

        Savg.Mean.Phi(:,i)   = mean(phi,2);
        Savg.Mean.Phi2(:,i)  = atan2(imag(Savg.Mean.Z(:,i)),real(Savg.Mean.Z(:,i)));
        Savg.Mean.Phi_StdErr(:,i)  = std(phi,0,2)/sqrt(size(z,2));            
        Savg.Mean.Phi2_StdErr(:,i) = Savg.Mean.Phi_StdErr(:,i);
        
        Savg.Median.Phi(:,i)  = median(phi,2);
        Savg.Median.Phi2(:,i) = atan2(imag(Savg.Median.Z(:,i)),real(Savg.Median.Z(:,i)));
        Savg.Mean.Phi_StdErr(:,i)  = Savg.Mean.Phi_StdErr(:,i);
        Savg.Mean.Phi2_StdErr(:,i) = Savg.Mean.Phi_StdErr(:,i);

        Savg.Huber.Phi(:,i)  = nancol;
        Savg.Huber.Phi2(:,i) = nancol;
        Savg.Huber.Phi_StdErr(:,i)  = nancol;
        Savg.Huber.Phi2_StdErr(:,i) = nancol;
        if (size(z,2) > 2) % Need more than two points to compute 
            Savg.Huber.Phi(:,i)  = mlochuber(phi.')';
            Savg.Huber.Phi2(:,i) = atan2(imag(Savg.Huber.Z(:,i)),real(Savg.Huber.Z(:,i)));
        end

        % H
        h = squeeze(S.H(:,i,:));
        Savg.Mean.H(:,i)   = mean(h,2);
        Savg.Mean.H_StdErr(:,i) = std(h,0,2)/sqrt(size(h,2));

        Savg.Median.H(:,i) = median(h,2);
        Savg.Median.H_StdErr(:,i) = Savg.Mean.H_StdErr(:,i);
        
        % Very slow. TODO: Consider only a restricted range of h.
        %V = sort(bootstrp(1000,@mean,abs(h).').',2);
        %S.H_Mean_StdErr_Upper(:,i) = V(:,150); 
        %S.H_Mean_StdErr_Lower(:,i) = V(:,1000-150);        
        %S.H_Huber(:,i)  = ( mlochuber(h') )';
        % transposes b/c mlochuber only averages across rows.

    end
    
    for k = 1:size(S.In,3)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Savg.Mean.Predicted(:,:,k)   = Zpredict(fe,Savg.Mean.Z,S.In(:,:,k));
        Savg.Median.Predicted(:,:,k) = Zpredict(fe,Savg.Median.Z,S.In(:,:,k));
        Savg.Huber.Predicted(:,:,k)  = Zpredict(fe,Savg.Huber.Z,S.In(:,:,k));    

        Savg.Mean.PE(1,:,k)    = pe(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));
        Savg.Median.PE(1,:,k)  = pe(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));
        Savg.Huber.PE(1,:,k)   = pe(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));

        Savg.Mean.MSE(1,:,k)   = mse(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));
        Savg.Median.MSE(1,:,k) = mse(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));
        Savg.Huber.MSE(1,:,k)  = mse(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));

        Savg.Mean.CC(1,:,k)    = cc(S.Out(a:b,:,k),Savg.Mean.Predicted(a:b,:,k));
        Savg.Median.CC(1,:,k)  = cc(S.Out(a:b,:,k),Savg.Median.Predicted(a:b,:,k));
        Savg.Huber.CC(1,:,k)   = cc(S.Out(a:b,:,k),Savg.Huber.Predicted(a:b,:,k));

        Savg.Mean.Error_PSD(:,:,k)   = smoothSpectra(S.Out(:,:,k)-Savg.Mean.Predicted(:,:,k),opts);
        Savg.Median.Error_PSD(:,:,k) = smoothSpectra(S.Out(:,:,k)-Savg.Median.Predicted(:,:,k),opts);
        Savg.Huber.Error_PSD(:,:,k)  = smoothSpectra(S.Out(:,:,k)-Savg.Huber.Predicted(:,:,k),opts);

        Savg.Mean.Coherence(:,:,k)   = smoothCoherence(S.Out(:,:,k),Savg.Mean.Predicted(:,:,k),opts);
        Savg.Median.Coherence(:,:,k) = smoothCoherence(S.Out(:,:,k),Savg.Median.Predicted(:,:,k),opts);
        Savg.Huber.Coherence(:,:,k)  = smoothCoherence(S.Out(:,:,k),Savg.Huber.Predicted(:,:,k),opts);

        Savg.Mean.SN(:,:,k)   = S.Out_PSD(:,:,k)./Savg.Mean.Error_PSD(:,:,k);    
        Savg.Median.SN(:,:,k) = S.Out_PSD(:,:,k)./Savg.Median.Error_PSD(:,:,k);    
        Savg.Huber.SN(:,:,k)  = S.Out_PSD(:,:,k)./Savg.Huber.Error_PSD(:,:,k);    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('transferfnAverage.m: Interval %02d: PEx in-sample: %6.3f; using: mean: %6.3f | median %6.3f | huber %6.3f\n',...
                 k,S.PE(1,1,k),Savg.Mean.PE(1,1,k),Savg.Median.PE(1,1,k),Savg.Huber.PE(1,1,k));
        fprintf('transferfnAverage.m: Interval %02d: PEy in-sample: %6.3f; using: mean: %6.3f | median %6.3f | huber %6.3f\n',...
                 k,S.PE(1,2,k),Savg.Mean.PE(1,2,k),Savg.Median.PE(1,2,k),Savg.Huber.PE(1,2,k));

    end
    
end

end


