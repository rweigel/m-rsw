function S = transferfnFuji(S,opts)

% Replace predictions, metrics with that using transfer function from
% from http://ds.iris.edu/spud/emtf/13598200
D = readEDIXML([fileparts(mfilename('fullpath')),'/MMB.xml']);

fe = transpose(1./D.PERIOD);

% Convert Z from having columns of period to rows of period
Z  = transpose(D.Z);

% Sort fe and Z so they are increasing in frequency instead of period
[fe,I] = sort(fe);
Z = Z(I,:);

% Coordinate system appears to be x = East, y = South. Convert to
% y = North.
Z(:,2) = -Z(:,2);
Z(:,4) = -Z(:,4);

% Add zero frequency (need to remove need for this in Zpredict; Zpredict
% should check if fe(1) == 0 and if not, add a zero frequency)
Z  = [0,0,0,0;Z];
fe = [0;fe];

% Assumes N is even.
N = size(S.In,1);
f = [0:N/2]'/N;

S.Z = Z;
S.fe = fe;
S.Phi = atan2(imag(Z),real(Z));

a = opts.td.Ntrim;
b = 86400-opts.td.Ntrim+1;

for k = 1:size(S.In,3)
    S.Predicted(:,:,k) = real(Zpredict(S.fe,S.Z,S.In(:,:,k)));
    S.PE(1,:,k)  = pe(S.Out(a:b,:,k),S.Predicted(a:b,:,k));
    S.MSE(1,:,k) = mse(S.Out(a:b,:,k),S.Predicted(a:b,:,k));    
    S.CC(1,:,k)  = cc(S.Out(a:b,:,k),S.Predicted(a:b,:,k));    
    fprintf('transferfnFuji.m: %d/%d PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',k,size(S.In,3),S.PE(1,1,k),S.CC(1,1,k),S.MSE(1,1,k));
    fprintf('transferfnFuji.m: %d/%d PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',k,size(S.In,3),S.PE(1,2,k),S.CC(1,2,k),S.MSE(1,2,k));    

    S.Error_PSD(:,:,k)  = smoothSpectra(S.Out(:,:,k) - S.Predicted(:,:,k),opts);
    S.SN(:,:,k)         = S.Out_PSD(:,:,k)./S.Error_PSD(:,:,k);
    S.Coherence(:,:,k)  = smoothCoherence(S.Out(:,:,k),S.Predicted(:,:,k),opts);
end
