function mainCompute3()


% Get list of all files in mat/DATE. Loop over these files.

dirmat = sprintf('mat/%s',dateo);
dirfig = sprintf('figures/%s',dateo);

i = 1;
while 1
    fnamemat = sprintf('%s/mainCompute2_FD_%s-%d.mat',dirmat,dateo,i);
    if ~exist(fnamemat,'file')% || i == 2
        break;
    end
    load(fnamemat);

    SE_All(:,:,i) = SE;
    SB_All(:,:,i) = SB;
    SG_All(:,:,i) = SG;
    Serr_EB_All(:,:,i) = Serr_EB;
    Serr_GE_All(:,:,i) = Serr_GE;
    Serr_GB_All(:,:,i) = Serr_GB;
    
    Z_EB_All(:,:,i) = Z_EB;
    Z_GE_All(:,:,i) = Z_GE;
    Z_GB_All(:,:,i) = Z_GB;
    H_EB_All(:,:,i) = H_EB;
    H_GE_All(:,:,i) = H_GE;
    H_GB_All(:,:,i) = H_GB;
    
    % GIC(w) = (a(w)*Zxx(w) + b(w)*Zyx(w))*Bx(w) + (a(w)*Zxy(w) + b(w)*Zyy(w))*By(w)
    % Bx term                  a(w)         Zxx              b(w)         Zyx
    Z_GB_Alt_All(:,1,i) = Z_GE(:,1).*Z_EB(:,1) + Z_GE(:,2).*Z_EB(:,3);
    % By term                  a(w)         Zxy              b(w)         Zyy
    Z_GB_Alt_All(:,2,i) = Z_GE(:,1).*Z_EB(:,2) + Z_GE(:,2).*Z_EB(:,4);

    % Bx term                  a(w)         Zxx              b(w)         Zyx
    Z_GB_Alt_All(:,3,i) = Z_GE(:,3).*Z_EB(:,1) + Z_GE(:,4).*Z_EB(:,3);
    % By term                  a(w)         Zxy              b(w)         Zyy
    Z_GB_Alt_All(:,4,i) = Z_GE(:,3).*Z_EB(:,2) + Z_GE(:,4).*Z_EB(:,4);

    i = i + 1;
end

% Compute averages of each segment
% TODO: Determine variance based on bootstrap instead of 1/sqrt(N), which
% is not correct because spectral estimates are not independent.
N = size(Z_EB_All,3);
for i = 1:2
    SE_Ave(:,i) = mean(squeeze(SE_All(:,i,:)) ,2);
    SE_Std(:,i) = std(squeeze( abs(SE_All(:,i,:)) ) ,0, 2);
    SB_Ave(:,i) = mean(squeeze(SB_All(:,i,:)) ,2);
    SB_Std(:,i) = std(squeeze( abs(SB_All(:,i,:)) ) ,0, 2);
    SG_Ave(:,i) = mean(squeeze(SG_All(:,i,:)) ,2);
    SG_Std(:,i) = std(squeeze( abs(SG_All(:,i,:)) ) ,0, 2);

    Serr_EB_Ave(:,i) = mean(squeeze(Serr_EB_All(:,i,:)) ,2);
    Serr_EB_Std(:,i) = std(squeeze( abs(Serr_EB_All(:,i,:)) ) ,0, 2);
    Serr_GE_Ave(:,i) = mean(squeeze(Serr_GE_All(:,i,:)) ,2);
    Serr_GE_Std(:,i) = std(squeeze( abs(Serr_GE_All(:,i,:)) ) ,0, 2);
    Serr_GB_Ave(:,i) = mean(squeeze(Serr_GB_All(:,i,:)) ,2);
    Serr_GB_Std(:,i) = std(squeeze( abs(Serr_GB_All(:,i,:)) ) ,0, 2);
end

for i = 1:4
        
    Z_EB_Ave(:,i) = mean(squeeze(Z_EB_All(:,i,:)) ,2);
    Z_EB_Std(:,i) = std(squeeze( abs(Z_EB_All(:,i,:)) ) ,0, 2);
    P_EB_Ave(:,i) = (180/pi)*atan2(imag(Z_EB_Ave(:,i)),real(Z_EB_Ave(:,i)));
    H_EB_Ave(:,i) = mean(squeeze(H_EB_All(:,i,:)) ,2);

    Z_GE_Ave(:,i) = mean(squeeze(Z_GE_All(:,i,:)) ,2);
    Z_GE_Std(:,i) = std(squeeze( abs(Z_GE_All(:,i,:)) ) ,0, 2);
    P_GE_Ave(:,i) = (180/pi)*atan2(imag(Z_GE_Ave(:,i)),real(Z_GE_Ave(:,i)));
    H_GE_Ave(:,i) = mean(squeeze(H_GE_All(:,i,:)) ,2);
    
    Z_GB_Ave(:,i) = mean(squeeze(Z_GB_All(:,i,:)) ,2);
    Z_GB_Std(:,i) = std(squeeze( abs(Z_GB_All(:,i,:)) ) ,0, 2);
    P_GB_Ave(:,i) = (180/pi)*atan2(imag(Z_GB_Ave(:,i)),real(Z_GB_Ave(:,i)));
    H_GB_Ave(:,i) = mean(squeeze(H_GB_All(:,i,:)) ,2);

    Z_GB_Alt_Ave(:,i) = mean(squeeze(Z_GB_Alt_All(:,i,:)) ,2);
    Z_GB_Alt_Std(:,i) = std(squeeze( abs(Z_GB_Alt_All(:,i,:)) ) ,0, 2);
    P_GB_Alt_Ave(:,i) = (180/pi)*atan2(imag(Z_GB_Alt_Ave(:,i)),real(Z_GB_Alt_Ave(:,i)));
    
end

%plot(1./fe_EB(2:end),Z_EB_Ave(2:end,i));
%U = Z_EB_Std(2:end,i)/sqrt(N);
%L = Z_EB_Std(2:end,i)/sqrt(N);
%errorbar(1./fe_EB(2:end),Z_EB_Ave(2:end,i),L,U);

%% Plot predictions using average transfer function
All = load(sprintf('%s/main_%s.mat',dirmat,dateo));

GICp_GB_Ave = Zpredict(fe_GB,Z_GB_Ave,All.B(:,1:2));
peB = pe(All.GIC(:,3),GICp_GB_Ave(:,2));
errorB = All.GIC(:,3)-GICp_GB_Ave(:,2);

GICp_GE_Ave = Zpredict(fe_GE,Z_GE_Ave,All.E(:,1:2));
peE = pe(All.GIC(:,3),GICp_GE_Ave(:,2));
errorE = All.GIC(:,3)-GICp_GE_Ave(:,2);

fprintf('PE of GIC using GIC/E average = %.2f\n',peE);
fprintf('PE of GIC using GIC/B average = %.2f\n',peB);

