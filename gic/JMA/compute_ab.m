function fname = compute_ab(t,GIC,E,B,dateo,intervalno,opts)

dirmat = sprintf('mat/%s',dateo);

% Important: Inputs/outputs must be zero mean.

% Matrix method to compute ao and bo
% GIC(:,i) = aoE(:,1) + boE(:,2);
for i = 1:2
    LIN = basic_linear(E,GIC(:,i));
    GEo_Prediction(:,i) = basic_linear(E(:,:),LIN.Weights,'predict');
    GEo_ao(i) = LIN.Weights(1);
    GEo_bo(i) = LIN.Weights(2);
    fprintf('compute_ab.m: ao =  %7.4f; bo =  %7.4f (matrix method)\n',GEo_ao(i),GEo_bo(i));

    GEo_PE(i) = pe_nonflag(GIC(:,i),GEo_Prediction(:,i));
    GEo_MSE(i) = mse_nonflag(GIC(:,i),GEo_Prediction(:,i));
    GEo_CC(i) = cc_nonflag(GIC(:,2),GEo_Prediction(:,i));
    fprintf('compute_ab.m:   PE/CC/MSE of GIC(:,%d) = aoE(:,1) + boE(:,2) = %.2f/%.2f/%.3f\n',i,GEo_PE(i),GEo_CC(i),GEo_MSE(i));
end

GEo_Dateo   = dateo;
GEo_Seconds = [t(1),t(end)];

GEo_Input_PSD  = smoothSpectra(E(:,1:2),opts);
GEo_Output_PSD = smoothSpectra(GIC,opts);
GEo_Error_PSD  = smoothSpectra(GIC - GEo_Prediction,opts);
GEo_Coherence  = smoothCoherence(GIC,GEo_Prediction,opts);

% Pulkkinen et al. 2007 method.
d = (mean_nonflag(E(:,1).*E(:,2)))^2-mean_nonflag(E(:,1).*E(:,1))*mean_nonflag(E(:,2).*E(:,2));
an = mean_nonflag(GIC(:,2).*E(:,2))*mean_nonflag(E(:,1).*E(:,2)) - mean_nonflag(GIC(:,2).*E(:,1))*mean_nonflag(E(:,2).*E(:,2));
aoP = an/d;
bn = mean_nonflag(GIC(:,2).*E(:,1))*mean_nonflag(E(:,1).*E(:,2)) - mean_nonflag(GIC(:,2).*E(:,2))*mean_nonflag(E(:,1).*E(:,1));
boP = bn/d;
fprintf('compute_ab.m: ao =  %7.4f; bo =  %7.4f (Pulkkinen 2007 et al. method)\n',aoP,boP);

% GIC(:,2) = aoE(:,1) + boE(:,2); for 1-minute averaged data.
% Attempt to reproduce Watari by averaging to 1 minute
E1m = block_mean(E(:,:),60);
E1m = block_detrend_nonflag(E1m,size(E1m,1));
GIC1m = block_mean(GIC(:,2),60);
GIC1m = block_detrend_nonflag(GIC1m,size(GIC1m,1));
LIN = basic_linear(E1m,GIC1m);
ao1m = LIN.Weights(1);
bo1m = LIN.Weights(2);
fprintf('compute_ab.m: ao =  %7.4f; bo =  %7.4f (matrix method; 1-min aves)\n',ao1m,bo1m);

% GIC(:,2) = aoE(:,1) + boE(:,2); for 1-hour averaged data.
% Attempt to reproduce Watari by averaging to 1 minute
E1h = block_mean(E(:,:),60*60);
E1h = block_detrend_nonflag(E1h,size(E1h,1));
GIC1h = block_mean(GIC(:,2),60*60);
GIC1h = block_detrend_nonflag(GIC1h,size(GIC1h,1));
LIN = basic_linear(E1h,GIC1h);
ao1h = LIN.Weights(1);
bo1h = LIN.Weights(2);
fprintf('compute_ab.m: ao =  %7.4f; bo =  %7.4f (matrix method; 1-hr aves)\n',ao1h,bo1h);

for i = 1:2
    LIN = basic_linear(B(:,1:2),GIC(:,i));
    GBo_Prediction(:,i) = basic_linear(B(:,1:2),LIN.Weights,'predict');
    GBo_ao(i) = LIN.Weights(1);
    GBo_bo(i) = LIN.Weights(2);
    fprintf('compute_ab.m: ao =  %7.4f; bo =  %7.4f (matrix method)\n',GBo_ao(i),GBo_bo(i));

    GBo_PE(i) = pe_nonflag(GIC(:,i),GBo_Prediction(:,i));
    GBo_MSE(i) = mse_nonflag(GIC(:,i),GBo_Prediction(:,i));
    GBo_CC(i) = cc_nonflag(GIC(:,2),GBo_Prediction(:,i));
    fprintf('compute_ab.m:   PE/CC/MSE of GIC(:,%d) = hxoB(:,1) + hyoB(:,2) = %.2f/%.2f/%.3f\n',i,GBo_PE(i),GBo_CC(i),GBo_MSE(i));
end

GBo_Dateo   = dateo;
GBo_Seconds = [t(1),t(end)];

GBo_Input_PSD  = smoothSpectra(B(:,1:2),opts);
GBo_Output_PSD = smoothSpectra(GIC,opts);
GBo_Error_PSD  = smoothSpectra(GIC - GBo_Prediction,opts);
GBo_Coherence  = smoothCoherence(GIC,GBo_Prediction,opts);

% GIC(:,2) = hxodB(:,1) + hyodB(:,2); % (LPF version is second column)
dB = [diff(B(:,1:2));0,0];
LIN = basic_linear(dB,GIC(:,2));
GIC_GdB(:,1) = basic_linear(dB,LIN.Weights,'predict');
dhox = LIN.Weights(1);
dhoy = LIN.Weights(2);
fprintf('compute_ab.m: hxo = %7.4f; hyo = %7.4f (Using diff(magnetic field))\n',dhox,dhoy);

PE_GdB = pe_nonflag(GIC(:,2),GIC_GdB);
MSE_GdB = mse_nonflag(GIC(:,2),GIC_GdB);
CC_GdB = corr(GIC(:,2),GIC_GdB);
fprintf('compute_ab.m:   PE/CC/MSE of GIC using GIC(:,2) = hxo dB(:,1) + hyo dB(:,2) = %.2f/%.2f/%.3f\n',PE_GdB,CC_GdB,MSE_GdB);

% GIC(:,2) = hxoB(:,1) + hyoB(:,2) + hzoB(:,3);
LIN = basic_linear(B(:,1:3),GIC(:,2));
GIC_GBo3(:,1) = basic_linear(B(:,1:3),LIN.Weights,'predict');
h3ox = LIN.Weights(1);
h3oy = LIN.Weights(2);
h3oz = LIN.Weights(3);

fprintf('compute_ab.m: hxo = %7.4f; hyo = %7.4f; hzo = %.4f (Using magnetic field)\n',h3ox, h3oy, h3oz);

PE_GBo3 = pe_nonflag(GIC(:,2),GIC_GBo3);
MSE_GBo3 = mse_nonflag(GIC(:,2),GIC_GBo3);
CC_GBo3 = corr(GIC(:,2),GIC_GBo3,'rows','complete');
fprintf('compute_ab.m:   PE/CC/MSE of GIC using GIC(:,2) = hxoB(:,1) + hyoB(:,2) = %.2f/%.2f/%.3f\n',PE_GBo3,CC_GBo3,MSE_GBo3);

for i = 1:2
    fprintf('compute_ab.m: PE/CC/MSE of GIC(:,%d) = aoE(:,1) + boE(:,2)   = %.2f/%.2f/%.3f\n',i,GEo_PE(i),GEo_CC(i),GEo_MSE(i));
    fprintf('compute_ab.m: PE/CC/MSE of GIC(:,%d) = hxoB(:,1) + hyoB(:,2) = %.2f/%.2f/%.3f\n',i,GBo_PE(i),GBo_CC(i),GBo_MSE(i));
end

fname = sprintf('%s/compute_ab_%s-%d.mat',dirmat,dateo,intervalno);
save(fname,'-regexp','GEo_','-regexp','GBo_');
fprintf('compute_ab.m: Wrote %s\n',fname);

