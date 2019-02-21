%load('mat/main_options-1.mat','GE');
for i = 1:size(GE.In_FT,1)
    CIn(i)  = cc(squeeze(GE.In_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));
    COut(i) = cc(squeeze(GE.Out_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));    
    CErr(i) = cc(squeeze(GE.Error_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));    
    CPE(i)  = cc(squeeze(GE.PE(1,2,:)),squeeze(abs(GE.Z(i,3,:))));    

    %[~,I] = sort(squeeze(GE.In_PSD(i,2,:)));
    [~,I] = sort(squeeze(GE.PE(1,2,:)));    
    Zmin(i,3) = mean(abs(GE.Z(i,3,I(1:end/2))),3);
    Zave(i,3) = mean(abs(GE.Z(i,3,:)),3);
    Zmax(i,3) = mean(abs(GE.Z(i,3,I(end/2:end))),3);    
end

T = 1./GE.fe;

figure(2);clf;
    loglog(T,Zmax(:,3),'r');
    hold on;
    loglog(T,Zmin(:,3),'g');    
    loglog(T,Zave(:,3),'b');

figure(1);clf;
    semilogx(T,CIn,'r');
    hold on;grid on;
    semilogx(T,COut,'g');
    semilogx(T,CErr,'b');
    semilogx(T,CPE,'k');    
break
clear
%addpath('m-statrobust'); % So one can put breakpoints in MATLAB's code.

for i = 2:size(GE.In_FT,1) % Loop over evaluation frequencies
    i
    for j = 1:2 % Loop over outputs (Ex and Ey)
        cols = [1,2];
        if j == 1
            cols = [3,4];
        end
        x = GE.In_FT{i,j,1};
        y = GE.Out_FT{i,j,1};
        Zk(i,cols,1) = regress(y,x);
        %Zk(i,cols,1) = mvregress(x,y);
        for k = 2:size(GE.In_FT,3) % Loop over days
            xk = GE.In_FT{i,j,k};
            yk = GE.Out_FT{i,j,k};
            x = cat(1,x,xk);
            y = cat(1,y,yk);
            Zk(i,cols,k) = regress(yk,xk);
            %Zk(i,cols,1) = mvregress(x,y);            
        end
        
        % x/y now has all input/output FTs
        Zols1(i,cols) = x\y;
        Zols2(i,cols) = (ctranspose(x)*x)^(-1)*ctranspose(x)*y;
        Zols3(i,cols) = regress(y,x);
        %Zmvr(i,cols)  = mvregress(x,y);
        Zrob(i,cols)  = robustfit(x,y,'bisquare',[],'off');

        Eols1{i,1} = y - x*Zols1(i,cols).';
        Nr{i,1} = mean(Eols1{i,1}.*conj(Eols1{i,1}))/mean(y.*conj(y));
        %Emvr{i,1}  = y - x*Zmvr(i,cols).';
        Erob{i,1}  = y - x*Zrob(i,cols).';

        if 0 && i == 11
            Zi = regress(y,x);
            % Ad-hoc robust.
            for i = 1:1
                R = y - x*Zi;
                Rs = sort(abs(R));
                p = 2;
                s = median(Rs(max(1,p):end))/0.6745;
                tune = 4.685;
                R = R/(s*tune);
                w = (abs(R)<1) .* (1 - R.^2).^2;
                Zi = regress(y.*sqrt(w),x.*sqrt([w,w]));
                Zi.'
            end
            keyboard
        end

    end
end

sf = 1;
%fe = GE.fe;
fe = GE.fe(1:size(Zols1,1));
figure(2);
    loglog(1./fe(2:end),sf*abs(Zols1(2:end,3)),'c--','LineWidth',3);
    hold on;
    %loglog(1./fe(2:end),sf*abs(Zmvr(2:end,3)),'r--','LineWidth',3);    
    loglog(1./fe(2:end),sf*abs(Zrob(2:end,3)),'k--','LineWidth',3);        
    loglog(1./fe(2:end),sf*mean(abs(Zk(2:end,3)),3),'b--','LineWidth',3);        
    
break

Zka = mean(Zk,3);

S = struct();
S.Z = Zrob;

Nint = size(GE.Z,3);
for k = 1:Nint

    S.fe = GE.fe;
    S.In(:,:,k) = GE.In(:,:,k);
    S.Out(:,:,k) = GE.Out(:,:,k);
        
    N = size(GE.In,1);
    f = [0:N/2]'/N; % Assumes N is even.
    S.H = Z2H(GE.fe,S.Z,f);

    S.Predicted(:,:,k) = Zpredict(GE.fe,S.Z,GE.In(:,:,k));

    S.PE(1,:,k)  = pe_nonflag(GE.Out(:,:,k),S.Predicted(:,:,k));
    S.MSE(1,:,k) = mse_nonflag(GE.Out(:,:,k),S.Predicted(:,:,k));
    S.CC(1,:,k)  = cc_nonflag(GE.Out(:,:,k),S.Predicted(:,:,k));

    S.In_PSD(:,:,k)     = smoothSpectra(GE.In(:,:,k),opts);
    S.Out_PSD(:,:,k)    = smoothSpectra(GE.Out(:,:,k),opts);
    S.Error_PSD(:,:,k)  = smoothSpectra(GE.Out(:,:,k) - S.Predicted(:,:,k),opts);
    S.SN(:,:,k)         = S.Out_PSD(:,:,k)./S.Error_PSD(:,:,k);
    S.Coherence(:,:,k)  = smoothCoherence(GE.Out(:,:,k),S.Predicted(:,:,k),opts);

    S.Phi(:,:,k) = atan2(imag(S.Z),real(S.Z));
    
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',k,Nint,S.PE(1,1,k),S.CC(1,1,k),S.MSE(1,1,k)); 
    fprintf('transferfnAlt.m: Interval %d/%d: PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',k,Nint,S.PE(1,2,k),S.CC(1,2,k),S.MSE(1,2,k)); 
end
mean(S.PE,3)