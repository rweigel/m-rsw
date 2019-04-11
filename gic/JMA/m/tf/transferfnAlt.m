function S = transferfnAlt(SGE,SEB,opts)

if nargin < 4
    t = [1:size(SGE.In,1)]';
end

S = struct();

Nint = size(SGE.Z,3);


% Needed for Fuji case
if size(SEB.Z,3) == 1
    Zi = Zinterp(SEB.fe,SEB.Z,SGE.fe);
    SEB.Z = Zi;
    for k = 1:Nint
        SEB.Z(:,:,k) = Zi;
    end
end

for k = 1:Nint

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)
    %
    % Bx term      a(w)        Zxx           b(w)      Zyx
    S.Z(:,1,k) = SGE.Z(:,1,k).*SEB.Z(:,1,k) + SGE.Z(:,2,k).*SEB.Z(:,3,k);
    % By term      a(w)        Zxy       b(w)         Zyy
    S.Z(:,2,k) = SGE.Z(:,1,k).*SEB.Z(:,2,k) + SGE.Z(:,2,k).*SEB.Z(:,4,k);

    % Bx term      a(w)     Zxx           b(w)       Zyx
    S.Z(:,3,k) = SGE.Z(:,3,k).*SEB.Z(:,1,k) + SGE.Z(:,4,k).*SEB.Z(:,3,k);
    % By term      a(w)     Zxy           b(w)       Zyy
    S.Z(:,4,k) = SGE.Z(:,3,k).*SEB.Z(:,2,k) + SGE.Z(:,4,k).*SEB.Z(:,4,k);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    S.fe = SGE.fe;
    S.In(:,:,k) = SEB.In(:,:,k);
    S.Out(:,:,k) = SGE.Out(:,:,k);
    S.Time(:,:,k) = SEB.Time(:,:,k);
    
    N = size(SGE.In,1);
    f = [0:N/2]'/N; % Assumes N is even.
    S.H(:,:,k) = Z2H(SGE.fe,S.Z(:,:,k),f);

    S.Predicted(:,:,k) = Zpredict(SGE.fe,S.Z(:,:,k),SEB.In(:,:,k));

    S.PE(1,:,k)  = pe_nonflag(SGE.Out(:,:,k),S.Predicted(:,:,k));
    S.MSE(1,:,k) = mse_nonflag(SGE.Out(:,:,k),S.Predicted(:,:,k));
    S.CC(1,:,k)  = cc_nonflag(SGE.Out(:,:,k),S.Predicted(:,:,k));

    S.In_PSD(:,:,k)     = smoothSpectra(SEB.In(:,:,k),opts);
    S.Out_PSD(:,:,k)    = smoothSpectra(SGE.Out(:,:,k),opts);
    S.Error_PSD(:,:,k)  = smoothSpectra(SGE.Out(:,:,k) - S.Predicted(:,:,k),opts);
    S.SN(:,:,k)         = S.Out_PSD(:,:,k)./S.Error_PSD(:,:,k);
    S.Coherence(:,:,k)  = smoothCoherence(SGE.Out(:,:,k),S.Predicted(:,:,k),opts);

    S.Phi(:,:,k) = atan2(imag(S.Z(:,:,k)),real(S.Z(:,:,k)));
    
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',k,Nint,S.PE(1,1,k),S.CC(1,1,k),S.MSE(1,1,k)); 
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',k,Nint,S.PE(1,2,k),S.CC(1,2,k),S.MSE(1,2,k)); 
end