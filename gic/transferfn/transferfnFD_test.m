clear

addpath('../../time/')
addpath('../../stats/','-end') % So native spectrogram() is used.
addpath('../misc/')

writeimgs = 0;

if writeimgs == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

tau  = 10;  % Filter decay constant
Ntau = 100; % Number of filter coefficients = Ntau*tau + 1
N    = 2e4; % Simulation length
Nc   = 101;  
nR   = 2;   % Width of rectangualar window is 2*nR+1
Nss  = 4;   % Will remove Nss*Ntau*tau from start of all time series 
nb   = 0.0; % Noise in B
ne   = 0.0; % Noise in E
ndb  = 0.0; % Noise in dB

paramstring = sprintf('_ne_%.1f',ne);

% IRF for dx/dt + x/\tau = delta(0), and ICs x(t=0) = 0; dx/dt|_{t=0} = 0
% approximated using forward Euler.
dt = 1;
gamma = (1-dt/tau);
for i = 1:Ntau*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end
hstr = sprintf('(1-1/%d)^{t}; t=1 ... %d; h_{xy}(0)=0;', tau, length(h));
% Add a zero because MATLAB filter function requires it.
% (Not having it also causes phase drift with frequency.)
h  = [0;h];            % Exact IRF
th = [0:length(h)-1]'; % Exact IRF time lags

% Add extra values so length is same after cutting off non-steady state
% part of E and B.
N = N + Nss*length(h);

% Noise
NE  = [ne*randn(N,1),ne*randn(N,1)];
NB  = [nb*randn(N,1),nb*randn(N,1)];
NdB = [ndb*randn(N,1),ndb*randn(N,1)];

dim = 2;
tn = 1;

% Create signals
if dim == 1
    H(:,1) = h;
    B(:,1) = randn(N,1);
    E(:,1) = NE(:,1) + filter(H(:,1),1,B(:,1) + NB(:,1));
end
if dim == 2
    H = zeros(length(h),dim);
    if tn == 1 % Doing all equal will lead to rank deficient warnings.
        H(:,1) = 0.1*h;
        H(:,2) = 0.2*h;
    end
    if tn == 2
        H(:,1) = 0*h;
        H(:,2) = h;
    end
    B(:,1) = randn(N,1);
    B(:,2) = randn(N,1);
    E(:,1) = NE(:,1) + filter(H(:,1),1,B(:,1) + NB(:,1)) + filter(H(:,2),1,B(:,2) + NB(:,2));
end
if dim == 4
    H = zeros(length(h),dim);
    if tn == 1 % Doing all equal will lead to rank deficient warnings.
        H(:,1) = 0.1*h;
        H(:,2) = 0.2*h;
        H(:,1) = 0.3*h;
        H(:,2) = 0.4*h;
    end
    if tn == 2 % Need to explain why Zxx and Zyy are not zero for this case.
        H(:,1) = 0*h; 
        H(:,2) = h;
        H(:,3) = 0*h;
        H(:,4) = h;
    end
    B(:,1) = randn(N,1);
    B(:,2) = randn(N,1);
    E(:,1) = NE(:,1) + filter(H(:,1),1,B(:,1) + NB(:,1)) + filter(H(:,2),1,B(:,2) + NB(:,2));
    E(:,2) = NE(:,2) + filter(H(:,3),1,B(:,1) + NB(:,1)) + filter(H(:,4),1,B(:,2) + NB(:,2));
end

% Remove non-steady-state part of signals
B  = B(Nss*length(h)+1:end,:);
E  = E(Nss*length(h)+1:end,:);

NE  = NE(Nss*length(h)+1:end,:);
NB  = NB(Nss*length(h)+1:end,:);

% Remove mean
for i = 1:size(B,2)
    B(:,i)  = B(:,i) - mean(B(:,i));
end
for i = 1:size(E,2)
    E(:,i) = E(:,i) - mean(E(:,i));
end

if 0
    [~,a,b] = prewhiten(E(:,1));
    E = filter(b,a,E);
    B = filter(b,a,B);
end

N = size(B,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute exact transfer function and phase
Z = fft(H);
Z(Z==0) = eps; % So points show up on loglog plot.

Nh  = size(Z,1);
Z   = Z(1:floor(Nh/2)+1,:);
fh  = [0:floor(Nh/2)]'/Nh;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Raw periodograms
N = size(B,1);
f = [0:N/2]'/N;
ftB   = fft(B);
ftB   = ftB(1:N/2+1,:);
ftE   = fft(E);
ftE   = ftE(1:N/2+1,:);
ftNB  = fft(NB);
ftNB  = ftNB(1:N/2+1,:);
ftNE  = fft(NE);
ftNE  = ftNE(1:N/2+1,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time domain
[Z_TD,fe_TD,H_TD,t_TD,E_TD] = transferfnTD(B,E,Nc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Frequency Domain Rectangular
    for i = 1:6
        windowfn = sprintf('retangular(%d)',2*nR+1);
        [Z_FDR(:,:,i),fe_FDR,H_FDR(:,:,i),t_FDR,Ep_FDR(:,:,i)] = transferfnFD(B,E,i,'rectangular',nR);
        Z_FDR(Z_FDR == 0) = eps;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frequency Domain Parzen
for i = 1:3
    windowfn = sprintf('Parzen',2*nR+1);
    [Z_FDR(:,:,i),fe_FDR,H_FDR(:,:,i),t_FDR,Ep_FDR(:,:,i)] = transferfnFD(B,E,i,'parzen');
    Z_FDR(Z_FDR == 0) = eps;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(Z_FDR,2) == 4
    Zstrs = {'Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}'};
    Hstrs = {'h_{xx}','h_{xy}','h_{yx}','h_{yy}'};
end
if size(Z_FDR,2) == 2
    Zstrs = {'Z_{x}','Z_{y}'};
    Hstrs = {'h_{x}','h_{y}'};
end
if size(Z_FDR,2) == 1
    Zstrs = {'Z'};
    Zstrs = {'h'};    
end

fn = 0;

fn = fn+1;figure(fn);clf;hold on;grid on;box on;
    plot(B(:,1)+15,'r')
    plot(NB(:,1)+5,'Color',[1,0.5,0])
    if dim > 1
        plot(B(:,2)+30,'r');
        plot(NB(:,2)+20,'Color',[1,0.5,0]);
    end
    plot(E(:,1)-5,'k')
    plot(NE(:,1)-15,'Color',[0.5,0.5,0.5])
    if dim == 4
        plot(E(:,2)-30,'k')
        plot(NE(:,2)-20,'Color',[0.5,0.5,0.5])
    end

    xlabel('t (sample number-1)')
    %set(gca,'YLim',[-30 30])
    if dim == 1
        ts = sprintf('E = filter(h,1,B+\\deltaB) + \\deltaE; \\deltaE = \\eta(0,%.2f); \\deltaB = \\eta(0,%.2f)',ne,nb);
        title(ts);
        ls = {'B_x+15 (input)','\deltaB_x+5 (noise)',...
              'E-5 (output)','\deltaE-15 (noise)'};
    end
    if dim == 2
        ts = sprintf('E_x = filter(h_{x},1,B_x+\\deltaBx) + filter(h_{y},1,B_y+\\deltaBy) + \\deltaE_x');
        title(ts);
        ls = {'B_x+15 (input)','\deltaB_x+5 (noise)',...
              'B_y+30 (input)','\deltaB+20 (noise)',...
              'E_x-5 (output)','\deltaE_x-15 (noise)',...
              'E_y-30 (output)','\deltaE_x-20 (noise)',...
              };
    end
    legend(ls,'Location','Best');
    plotcmds(['timeseries',paramstring],writeimgs)

fn = fn+1;figure(fn);clf
    if dim >=1
        loglog(f(2:end),abs(ftB(2:end,1)),'r')
        hold on;grid on;box on;
        loglog(f(2:end),abs(ftNB(2:end,1)),'Color',[0.5,0,0])
        loglog(f(2:end),abs(ftE(2:end,1)),'k')
        loglog(f(2:end),abs(ftNE(2:end,1)),'Color',[0.5,0.5,0.5])
        ls = {'B (input)','\deltaB (noise)','E (output)','\deltaE (noise)'};
    end
    if dim == 2
        loglog(f(2:end),abs(ftB(2:end,2)),'g')
        hold on;grid on;box on;
        loglog(f(2:end),abs(ftNB(2:end,2)),'Color',[0,0.5,0])
        ls = {...
            'B_x (input)','\deltaB_x (noise)',...
            'E_x (output)','\deltaE_x (noise)',...
            'B_y (input)','\deltaB_y (noise)',...
            };
    end
    legend(ls,'Location','Best');
    title('Raw Periodograms');
    xlabel('f')
    plotcmds(['rawperiodograms',paramstring],writeimgs)

fn = fn+1;figure(fn);clf;hold on;grid on;
    xc = xcorr(E(:,1),B(:,1),'unbiased');
    tl = [-N+1:N-1];
    xc = fftshift(xc);
    plot(tl,xc,'Color','r','Marker','.','MarkerEdgeColor','r');
    set(gca,'XLim',[-3*length(h) 3*length(h)]);
    title('Raw Cross Correlation')
    xlabel('lag')
    legend('E,B')
    plotcmds(['crosscorrelation',paramstring],writeimgs)

for j = 1:size(H_FDR,2)
    fn = fn+1;figure(fn);clf;hold on;grid on;box on;;
    plot(th,H(:,j),'k','Marker','+','MarkerSize',5,'LineWidth',5);
    plot(t_TD,H_TD(:,j),'m','LineWidth',4);
    for i = 1:size(H_FDR,3)
        plot(t_FDR,H_FDR(:,j,i),'LineWidth',2);
    end
    xlabel('t')
    %set(gca,'XLim',[-3*length(h) 3*length(h)]);
    set(gca,'XLim',[-20,40]);    
    title(sprintf('%s',Hstrs{j}));
    legend(...
            'Exact',...
            sprintf('TD; n_T = %d',length(H_TD)),...
            sprintf('FD; %s; OLS; min E',windowfn),...
            sprintf('FD; %s; OLS; min E using regress()',windowfn),...
            sprintf('FD; %s; Robust; min E using robustfit()',windowfn),...
            sprintf('FD; %s; OLS; min B',windowfn),...
            sprintf('FD; %s; OLS; min B using regress()',windowfn),...
            sprintf('FD; %s; Robust; min B using robustfit()',windowfn),...
            'Location','Best')
   plotcmds(['impulse_response_functions',paramstring],writeimgs)
end

for j = 1:size(Z_FDR,2)
    fn = fn+1;figure(fn);clf;
        loglog(fh,abs(Z(:,j)),'k','Marker','+','MarkerSize',10,'LineWidth',5)
        hold on;grid on;box on;
        loglog(fe_TD,abs(Z_TD(:,j)),'m','Marker','.','MarkerSize',25,'LineWidth',3);
        for i = 1:size(Z_FDR,3)
            loglog(fe_FDR,abs(Z_FDR(:,j,i)),'Marker','.','MarkerSize',15,'LineWidth',2);
         end
        xlabel('f')
        title(sprintf('%s',Zstrs{j}));
        legend(...
                'Exact',...
                sprintf('TD; n_T = %d',length(H_TD)),...
                sprintf('FD; %s; OLS; min E',windowfn),...
                sprintf('FD; %s; OLS; min E using regress()',windowfn),...
                sprintf('FD; %s; Robust; min E using robustfit()',windowfn),...
                sprintf('FD; %s; OLS; min B',windowfn),...
                sprintf('FD; %s; OLS; min B using regress()',windowfn),...
                sprintf('FD; %s; Robust; min B using robustfit()',windowfn),...
                'Location','Best')
       plotcmds(['transfer_functions',paramstring],writeimgs)
end
   
break
if (0)
figure(5);clf;
    % Create padded impulse responses.
    tp = [min([t_FDP(1),t_FDR(1),th(1)]):max([t_FDP(end),t_FDR(end),th(end)])]';
    hp = interp1(th,h,tp);
    hp(isnan(hp)) = 0;
    for i = 1:size(H_TD,2)
        H_TDp(:,i)  = interp1(t_TD,H_TD(:,i),tp);
        H_FDRp(:,i) = interp1(t_FDR,H_FDR(:,i),tp);
        H_FDPp(:,i) = interp1(t_FDP,H_FDP(:,i),tp);
    end

    hold on;grid on;
    plot(tp,H_TDp(:,2)-hp,'m','LineWidth',4)
    plot(tp,H_FDRp(:,2)-hp,'b','LineWidth',2)
    plot(tp,H_FDPp(:,2)-hp,'g','LineWidth',2)
    xlabel('t')
    title('Impulse Response Errors')
    legend(...
            sprintf('\\deltah_{xy} time domain; n_T = %d',length(H_TD)),...
            sprintf('\\deltah_{xy} freq. domain Rectangular; n_f = %d', df),...
            sprintf('\\deltah_{xy} freq. domain Parzen; n_P = %d',length(fe_FDP))...
            )
   plotcmds(['impulse_response_errors',paramstring],writeimgs)
end

figure(6);clf;
    loglog(fh,abs(Z(:,2)),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    hold on;grid on;
    loglog(fe_TD,abs(Z_TD(:,2)),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    loglog(fe_FDR,abs(Z_FDR(:,2)),'b','Marker','.','MarkerSize',15,'LineWidth',2);
    loglog(fe_FDP,abs(Z_FDP(:,2)),'g','Marker','.','MarkerSize',10,'LineWidth',1);
    xlabel('f')
    title('Transfer Functions')
    legend(...
            'Z_{xy}',...
            sprintf('Z_{xy} time domain; n_T = %d',length(H_TD)),...
            sprintf('Z_{xy} freq. domain rectangular (n_R = %d)', df),...
            sprintf('Z_{xy} freq. domain parzen; n_P = %d',length(fe_FDP))...
            )
   plotcmds(['transfer_functions',paramstring],writeimgs)

figure(9);clf;
    hold on;grid on;
    plot(fh,abs(P(:,2)),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    plot(fe_TD,abs(P_TD(:,2)),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    plot(fe_FDR,abs(P_FDR(:,2)),'b','Marker','.','MarkerSize',25,'LineWidth',2);
    plot(fe_FDP,abs(P_FDP(:,2)),'g','Marker','.','MarkerSize',25,'LineWidth',1);
    xlabel('f');
    ylabel('degrees')
    title('Transfer Function Phases')
    legend(...
        '\phi_{xy}',...
        sprintf('\\phi_{xy} time domain; n_T = %d',length(H_TD)),...
        sprintf('\\phi_{xy} freq. domain Rectangular; n_R = %d', df),...
        sprintf('\\phi_{xy} freq. domain Parzen; n_P = %d',length(fe_FDP)),...
        'Location','SouthEast'...
    )
   plotcmds(['transfer_function_phases',paramstring],writeimgs)

if (0)
figure(10);clf;
    hold on;grid on;
    plot(fh,abs(PxyBLi)-abs(Pxy),'m','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(PxyRi)-abs(Pxy),'b','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(PxyPi)-abs(Pxy),'g','Marker','.','MarkerSize',20,'LineWidth',2);
    xlabel('f')
    ylabel('degrees')
    title('Transfer Function Phase Errors')
    legend(...
            sprintf('\\delta\\phi_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('\\delta\\phi_{xy} freq. domain Rectangular; n_R = %d', df),...
            sprintf('\\delta\\phi_{xy} freq. domain Parzen; n_P = %d',length(feP)),...
            'Location','NorthEast')
   plotcmds(['transfer_function_phase_errors',paramstring],writeimgs)
end

if (0)
figure(11);clf;
    hold on;grid on;
    plot(E(:,2),'k','LineWidth',3)
    plot(E_TD(:,2),'m')
    plot(E_FDR_wH(:,2),'b')
    plot(E_FDP_wH(:,2),'g')
    xlabel('t')
    title('Predictions (using H)')
    legend('E_y',...
            'E_y time domain',...
            'E_y freq. domain Rectangular',...
            'E_y freq. domain Parzen'...
            )
   plotcmds(['predictions_H',paramstring],writeimgs)
   
figure(12);clf;
    hold on;grid on;
    plot(E(:,2),'k','LineWidth',3)
    plot(E_TD_wZ(:,2),'m')
    plot(E_FDR(:,2),'b')
    plot(E_FDP(:,2),'g')
    xlabel('t')
    title('Predictions (using Z)')
    legend('E_y',...
            'E_y time domain',...
            'E_y freq. domain Rectangular',...
            'E_y freq. domain Parzen'...
            )
   plotcmds(['predictions_Z',paramstring],writeimgs)
end

figure(13);clf;
    hold on;grid on;
    plot(E(:,2)-E_TD(:,2)+10,'m')
    plot(E(:,2)-E_FDR_wH(:,2),'b')
    plot(E(:,2)-E_FDP_wH(:,2)-10,'g')
    peTD = pe_nonflag(E(:,2),E_TD(:,2));
    peFDR  = pe_nonflag(E(:,2),E_FDR_wH(:,2));
    peFDP  = pe_nonflag(E(:,2),E_FDP_wH(:,2));

    xlabel('t')
    title('Prediction Errors (using H)')
    set(gca,'YLim',[-20 20])
    legend(...
        sprintf('\\DeltaE_y+10 time domain; PE = %.3f',peTD),...        
        sprintf('\\DeltaE_y freq. domain Rectangular; PE = %.3f',peFDR),...
        sprintf('\\DeltaE_y-10 freq. domain Parzen; PE = %.3f',peFDP)...
        );
    plotcmds(['prediction_H_errors',paramstring],writeimgs)

figure(14);clf;
    hold on;grid on;
    plot(E(:,2)-E_TD_wZ(:,2)+10,'m')
    plot(E(:,2)-E_FDR(:,2),'b')
    plot(E(:,2)-E_FDP(:,2)-10,'g')
    peTD = pe_nonflag(E(:,2),E_TD_wZ(:,2));
    peFDR = pe_nonflag(E(:,2),E_FDR(:,2));
    peFDP = pe_nonflag(E(:,2),E_FDP(:,2));
    xlabel('t')
    title('Prediction Errors (using Z)')
    set(gca,'YLim',[-20 20])
    legend(...
        sprintf('\\DeltaE_y+10 time domain; PE = %.3f',peTD),...        
        sprintf('\\DeltaE_y freq. domain Rectangular; PE = %.3f',peFDR),...
        sprintf('\\DeltaE_y-10 freq. domain Parzen; PE = %.3f',peFDP)...
        );
    plotcmds(['prediction_Z_errors',paramstring],writeimgs)
