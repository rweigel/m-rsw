function S = transferfnMetrics(In,Out,fe,Z,opts)

S = struct();
S.In = In;
S.Out = Out;
S.fe = fe;
S.Z = Z;

a = opts.td.Ntrim;
b = size(In,1)-opts.td.Ntrim+1;

for k = 1:size(In,3)
    S.Predicted(:,:,k) = real(Zpredict(fe,Z,In(:,:,k)));

    S.PE(1,:,k)  = pe(Out(a:b,:,k),S.Predicted(a:b,:,k));
    S.MSE(1,:,k) = mse(Out(a:b,:,k),S.Predicted(a:b,:,k));    
    S.CC(1,:,k)  = cc(Out(a:b,:,k),S.Predicted(a:b,:,k));    
    fprintf('transferfnMetrics.m: %d/%d PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',k,size(In,3),S.PE(1,1,k),S.CC(1,1,k),S.MSE(1,1,k));
    fprintf('transferfnMetrics.m: %d/%d PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',k,size(In,3),S.PE(1,2,k),S.CC(1,2,k),S.MSE(1,2,k));    

    S.Out_PSD(:,:,k)    = smoothSpectra(Out(:,:,k),opts);
    S.Error_PSD(:,:,k)  = smoothSpectra(Out(:,:,k) - S.Predicted(:,:,k),opts);
    S.SN(:,:,k)         = S.Out_PSD(:,:,k)./S.Error_PSD(:,:,k);
    S.Coherence(:,:,k)  = smoothCoherence(S.Out(:,:,k),S.Predicted(:,:,k),opts);
end

for i = 1:size(S.PE,2)
    S.PE_CI95(:,i) = boot( squeeze( S.PE(1,i,:) ),@(x) mean(x,1),1000,50);
    S.CC_CI95(:,i) = boot( squeeze( S.CC(1,i,:) ),@(x) mean(x,1),1000,50);
    S.MSE_CI95(:,i) = boot( squeeze( S.MSE(1,i,:) ),@(x) mean(x,1),1000,50);
end
