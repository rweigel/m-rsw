%clear
%addpath('m-statrobust'); % So one can put breakpoints in MATLAB's code.
load('mat/main_options-1.mat','GE');
for i = 2:size(GE.In_FT,1)
    for j = 1:2;
        x = GE.In_FT{i,j,1};
        y = GE.Out_FT{i,j,1};
        if j == 1
            Zk(i,1:2,1) = regress(y,x);
        end
        if j == 2
            Zk(i,3:4,1) = regress(y,x);
        end
        for k = 2:size(GE.In_FT,3)
            xk = GE.In_FT{i,j,k};
            yk = GE.Out_FT{i,j,k};
            x = cat(1,x,xk);
            y = cat(1,y,yk);
            if j == 1
                Zk(i,1:2,k) = regress(yk,xk);
            end
            if j == 2
                Zk(i,3:4,k) = regress(yk,xk);
            end
        end
        Er_act{i,j} = real(y);
        Ei_act{i,j} = imag(y);
        if j == 1
            Zols1(i,1:2) = x\y;
            Zols2(i,1:2) = (ctranspose(x)*x)^(-1)*ctranspose(x)*y;
            Zols3(i,1:2) = regress(y,x);
            Er_ols{i,1} = real(x*Zols1(i,1:2).');
            Ei_ols{i,1} = imag(x*Zols1(i,1:2).');
            Zrob1(i,1:2) = robustfit(x,y,'bisquare',[],'off');
            %Zrob2(i,1:2) = robustfit(real(x),real(y),[],[],'off') + sqrt(-1)*robustfit(imag(x),imag(y),[],[],'off');
            Er_rob{i,1} = real(x*Zrob1(i,1:2).');
            Ei_rob{i,1} = imag(x*Zrob1(i,1:2).');
        end
        if j == 2
            Zols1(i,3:4) = x\y;
            Zols2(i,3:4) = (ctranspose(x)*x)^(-1)*ctranspose(x)*y;
            Zols3(i,3:4) = regress(y,x);
            Er_ols{i,2} = real(x*Zols1(i,3:4).');
            Ei_ols{i,2} = imag(x*Zols1(i,3:4).');
            Zrob1(i,3:4) = robustfit(x,y,'bisquare',[],'off');
            %Zrob2(i,3:4) = robustfit(real(x),real(y),[],[],'off') + sqrt(-1)*robustfit(imag(x),imag(y),[],[],'off');
            Er_rob{i,2} = real(x*Zrob1(i,3:4).');
            Ei_rob{i,2} = imag(x*Zrob1(i,3:4).');
            if i == 11
                Zi = regress(y,x);
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
end


fe = GE.fe;
figure(2);
    loglog(1./fe(2:end),sf*abs(Zols1(2:end,4)),'c--','LineWidth',3);
    loglog(1./fe(2:end),sf*abs(Zrob1(2:end,4)),'k--','LineWidth',3);    

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