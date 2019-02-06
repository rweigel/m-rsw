function S = transferfnAlt(SGE,SEB,opts)

for k = 1:length(SGE)

    S{k} = struct();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)
    %
    % Bx term      a(w)        Zxx           b(w)      Zyx
    S{k}.Z(:,1) = SGE{k}.Z(:,1).*SEB{k}.Z(:,1) + SGE{k}.Z(:,2).*SEB{k}.Z(:,3);
    % By term      a(w)        Zxy       b(w)         Zyy
    S{k}.Z(:,2) = SGE{k}.Z(:,1).*SEB{k}.Z(:,2) + SGE{k}.Z(:,2).*SEB{k}.Z(:,4);

    % Bx term      a(w)     Zxx           b(w)       Zyx
    S{k}.Z(:,3) = SGE{k}.Z(:,3).*SEB{k}.Z(:,1) + SGE{k}.Z(:,4).*SEB{k}.Z(:,3);
    % By term      a(w)     Zxy           b(w)       Zyy
    S{k}.Z(:,4) = SGE{k}.Z(:,3).*SEB{k}.Z(:,2) + SGE{k}.Z(:,4).*SEB{k}.Z(:,4);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    S{k}.fe = SGE{k}.fe;
    S{k}.In = SEB{k}.In;
    S{k}.Out = SGE{k}.Out;
    
    N = size(SGE{k}.In,1);
    f = [0:N/2]'/N; % Assumes N is even.
    S{k}.H = Z2H(SGE{k}.fe,S{k}.Z,f);

    S{k}.Predicted = Zpredict(SGE{k}.fe,S{k}.Z,SEB{k}.In);

    S{k}.PE  = pe_nonflag(SGE{k}.Out,S{k}.Predicted);
    S{k}.MSE = mse_nonflag(SGE{k}.Out,S{k}.Predicted);
    S{k}.CC  = cc_nonflag(SGE{k}.Out,S{k}.Predicted);

    S{k}.In_PSD     = smoothSpectra(SEB{k}.In,opts);
    S{k}.Out_PSD    = smoothSpectra(SGE{k}.Out,opts);
    S{k}.Error_PSD  = smoothSpectra(SGE{k}.Out - S{k}.Predicted,opts);
    S{k}.SN         = S{k}.Out_PSD./S{k}.Error_PSD;
    S{k}.Coherence  = smoothCoherence(SGE{k}.Out,S{k}.Predicted,opts);

    S{k}.Phi = atan2(imag(S{k}.Z),real(S{k}.Z));
    
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',k,length(SGE),S{k}.PE(1),S{k}.CC(1),S{k}.MSE(1)); 
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',k,length(SGE),S{k}.PE(2),S{k}.CC(2),S{k}.MSE(2)); 
end