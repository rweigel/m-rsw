function mainCompute1(GIC,E,B,Ix,dateo,intervalno)

dirmat = sprintf('mat/%s',dateo);

% Important: Inputs/outputs must be zero mean.

% Pulkkinen et al. 2007 method.
% Compute ao and bo using 2007 method
d = (mean_nonflag(E(Ix,1).*E(Ix,2)))^2-mean_nonflag(E(Ix,1).*E(Ix,1))*mean_nonflag(E(Ix,2).*E(Ix,2));
an = mean_nonflag(GIC(Ix,2).*E(Ix,2))*mean_nonflag(E(Ix,1).*E(Ix,2)) - mean_nonflag(GIC(Ix,2).*E(Ix,1))*mean_nonflag(E(Ix,2).*E(Ix,2));
aoP = an/d;
bn = mean_nonflag(GIC(Ix,2).*E(Ix,1))*mean_nonflag(E(Ix,1).*E(Ix,2)) - mean_nonflag(GIC(Ix,2).*E(Ix,2))*mean_nonflag(E(Ix,1).*E(Ix,1));
boP = bn/d;
fprintf('ao = %.4f; bo = %.4f (Pulkkinen 2007 et al. method)\n',aoP,boP);

% Matrix method to compute ao and bo
% GIC(:,1) = aoE(:,1) + boE(:,2);
LIN = basic_linear(E(Ix,:),GIC(Ix,2));
GICp2_TD0(:,1) = basic_linear(E(Ix,:),LIN.Weights,'predict');
ao = LIN.Weights(1);
bo = LIN.Weights(2);

fprintf('ao = %.4f; bo = %.4f (matrix method)\n',ao,bo);

% Attempt to reproduce Watari by averaging to 1 minute
E1m = block_mean(E(Ix,:),60);
E1m = block_detrend_nonflag(E1m,size(E1m,1));
GIC1m = block_mean(GIC(Ix,2),60);
GIC1m = block_detrend_nonflag(GIC1m,size(GIC1m,1));

% GIC(:,2) = aoE(:,1) + boE(:,2); for 1-minute data.
% Shift by one minute to see if it matters.
LIN = basic_linear(E1m,GIC1m);
ao1m = LIN.Weights(1);
bo1m = LIN.Weights(2);

fprintf('ao = %.4f; bo = %.4f (matrix method; 1-min aves)\n',ao1m,bo1m);

if (0)
    N = 100;
    fprintf('Computing %d bootstrap ao and bo values\n',N);
    % Compute N bootstrap ao and bo values to get standard deviation.
    % Take random sample (without replacement) of 1/2 of the values.
    Er = E(Ix,:);
    GICr = GIC(Ix,2);
    for i = 1:N
        Ir = randi(length(Ix),size(Ix));
        Er0 = block_detrend_nonflag(Er(Ir,:),size(Er,1));
        GICr0 = block_detrend_nonflag(GICr(Ir),size(GICr,1));
        LIN = basic_linear(Er0,GICr0);
        aoboot(i) = LIN.Weights(1);
        boboot(i) = LIN.Weights(2);
    end
    aobootstd = std(aoboot);
    bobootstd = std(boboot);

    fprintf('Computing 201 lagged ao and bo values\n');
    % See how ao and bo depend on shift of 1-second data.
    tl = [-100:100];
    for i = tl
        j = i-tl(1)+1;
        [T,X] = time_delay(GIC(:,2),E,1,i);
        LIN = basic_linear(X,T);
        arvlag(j) = LIN.ARVtrain;
        aolag(j) = LIN.Weights(1);
        bolag(j) = LIN.Weights(2);
    end
end

% GIC(:,1) = aoE(:,1) + boE(:,2); % (LPF version is second GIC column)
LIN = basic_linear(E(Ix,:),GIC(Ix,1));
GICp2_TD0(:,1) = basic_linear(E(Ix,:),LIN.Weights,'predict');

% GIC(:,2) = aoE(:,1) + boE(:,2); % (LPF version is second GIC column)
LIN = basic_linear(E(Ix,:),GIC(Ix,2));
GICp2_TD0(:,2) = basic_linear(E(Ix,:),LIN.Weights,'predict');

% GIC(:,1) = aoB(:,1) + boB(:,2); % (LPF version is second column)
LIN = basic_linear(B(Ix,1:2),GIC(Ix,1));
GICp3_TD0(:,1) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');
aoB = LIN.Weights(1);
boB = LIN.Weights(2);

fprintf('ao = %.4f; bo = %.4f (Using magnetic field)\n',aoB, boB);

% GIC(:,2) = aoB(:,1) + boB(:,2); % (LPF version is second column)
LIN = basic_linear(B(Ix,1:2),GIC(Ix,2));
GICp3_TD0(:,2) = basic_linear(B(Ix,1:2),LIN.Weights,'predict');

% GIC(:,1) = aoB(:,1) + boB(:,2) + coB(:,3);
LIN = basic_linear(B(Ix,1:3),GIC(Ix,1));
GICp3_TD03(:,1) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');

% GIC(:,2) = aoB(:,1) + boB(:,2) + coB(:,3);
LIN = basic_linear(B(Ix,1:3),GIC(Ix,2));
GICp3_TD03(:,2) = basic_linear(B(Ix,1:3),LIN.Weights,'predict');

save(sprintf('%s/mainCompute1_%s-%d.mat',dirmat,dateo,intervalno))
