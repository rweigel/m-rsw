clear

addpath('../../time/')
addpath('../../stats/')
addpath('../misc/')

writeimgs = 0;

tau  = 10;  % Filter decay constant
Ntau = 10;  % Number of filter coefficients = Ntau*tau + 1
N    = 2e4; % Simulation length
Nc   = 101;  
df   = 1;   % Width of rectangualar window
Nss  = 4;   % Will remove Nss*Ntau*tau from start of all time series 
nb   = 0.0; % Noise in B
ne   = 0.0; % Noise in E
ndb  = 0.0; % Noise in dB

paramstring = sprintf('_ne_%.1f',ne);

% IRF for dx/dt + x/tau = delta(0), and ICs
% x_0 = 0 dx_0/dt = 0 approximated using forward Euler.
dt = 1;
gamma = (1-dt/tau);
for i = 1:Ntau*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end
hstr = sprintf('(1-1/%d)^{t}; t=1 ... %d; h_{xy}(0)=0;', tau, length(h));
% Add a zero because MATLAB filter function requires it.  Also,
% not having it causes non-physical phase drift with frequency.
h  = [0;h];            % Exact IRF
th = [0:length(h)-1]'; % Exact IRF time lags

% Add extra values to get nice length
% (because we cut off non-steady state).
N = N + Nss*length(h);

% Noise
NE  = [ne*randn(N,1),ne*randn(N,1)];
NB  = [nb*randn(N,1),nb*randn(N,1)];
NdB = [ndb*randn(N,1),ndb*randn(N,1)];

% Create signals
B(:,1) = randn(N,1);
B(:,2) = randn(N,1);

E(:,2) = filter(h,1,B(:,1)+NB(:,1)) + NE(:,2);
E(:,1) = filter(h,1,B(:,2)+NB(:,2)) + NE(:,1);

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

N = size(B,1);

%% Window in time domain.
if (1)
    % TODO: Train on windowed data and re-scale predictions by window
    % W = parzenwin(length(B))
    % Bp(2:end-1) = Bp(2:end-1)./W
    for i = 1:size(B,2)
        B(:,i) = B(:,i).*parzenwin(length(B));
    end
    for i = 1:size(E,2)
    	E(:,i) = E(:,i).*parzenwin(length(E));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute exact transfer function and phase
Z(:,2) = fft(h);
Nh     = size(Z,1);
Z      = Z(1:floor(Nh/2)+1,:);
fh     = [0:floor(Nh/2)]'/Nh;
P(:,2) = (180/pi)*atan2(imag(Z(:,2)),real(Z(:,2)));
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
P_TD = (180/pi)*atan2(imag(Z_TD),real(Z_TD));
E_TD_wZ = Zpredict(fe_TD,Z_TD,B); % Prediction of E using convolving B with Z and IFT.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frequency Domain Rectangular
[Z_FDR,fe_FDR,H_FDR,t_FDR,E_FDR] = transferfnFD(B,E,1,'rectangular',df);
P_FDR  = (180/pi)*atan2(imag(Z_FDR),real(Z_FDR));
E_FDR_wH = Hpredict(t_FDR,H_FDR,B);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frequency Domain Parzen
[Z_FDP,fe_FDP,H_FDP,t_FDP,E_FDP] = transferfnFD(B,E,1,'parzen');
P_FDP  = (180/pi)*atan2(imag(Z_FDP),real(Z_FDP));
E_FDP_wH = Hpredict(t_FDP,H_FDP,B);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(0,'DefaultFigureWindowStyle','docked')
%set(0,'DefaultFigureWindowStyle','normal')

figure(1);clf;hold on; grid on;
    plot(NaN*B(1:2,1),'r','LineWidth',3)
    plot(NaN*E(1:2,2),'Color',[1,0.5,0],'LineWidth',3)
    plot(NaN*E(1:2,2),'k','LineWidth',3)
    plot(NaN*E(1:2,2),'Color',[0.5,0.5,0.5],'LineWidth',3)

    ts = sprintf('E_y = filter(h_{xy},1,B_x+\\deltaBx) + \\deltaE_y; \\deltaE_y = \\eta(0,%.2f); \\deltaB_x = \\eta(0,%.2f)',ne,nb);
    title(ts);
    plot(B(:,1)+15,'r')
    plot(NB(:,1)+5,'Color',[1,0.5,0])
    plot(E(:,2)-5,'k')
    plot(NE(:,2)-15,'Color',[0.5,0.5,0.5])
    xlabel('t (sample number-1)')
    set(gca,'YLim',[-30 30])
    legend('B_x+15 (input)','\deltaB_x+5 (noise)','E_y-5 (output)','\deltaE_y-15 (noise)')
    plotcmds(['timeseries',paramstring],writeimgs)

figure(2);clf;
    % Set line thicknesses in legend to be larger
    loglog(NaN*ftB(1:2,1),'r','LineWidth',3)
    hold on;grid on;
    loglog(NaN*ftE(1:2,2),'Color',[1,0.5,0],'LineWidth',3)
    loglog(NaN*ftNB(1:2,1),'k','LineWidth',3)
    loglog(NaN*ftNE(1:2,2),'Color',[0.5,0.5,0.5],'LineWidth',3)

    title('Raw Periodograms')
    loglog(f(2:end),abs(ftB(2:end,1)),'r')
    loglog(f(2:end),abs(ftNB(2:end,1)),'Color',[1,0.5,0])
    loglog(f(2:end),abs(ftE(2:end,2)),'k')
    loglog(f(2:end),abs(ftNE(2:end,2)),'Color',[0.5,0.5,0.5])
    xlabel('f')
    legend('B_x (input)','\deltaB_x (noise)','E_y (output)','\deltaE_y (noise)')
    plotcmds(['rawperiodograms',paramstring],writeimgs)

figure(3);clf;grid on;
    me = mean(E(:,2));
    mb = mean(B(:,1));
    xc = xcorr(E(:,2)-me,B(:,1)-mb,'unbiased');
    tl = [-N+1:N-1];
    xc = fftshift(xc);
    plot(tl,xc,'Color','r','Marker','.','MarkerEdgeColor','k');grid on;
    set(gca,'XLim',[-3*length(h) 3*length(h)]);
    title('Raw Cross Correlation')
    xlabel('lag')
    legend('E_y,B_x')
    plotcmds(['crosscorrelation',paramstring],writeimgs)

figure(4);clf;
    hold on;grid on;
    plot(th,h,'k','Marker','+','MarkerSize',5,'LineWidth',5)
    plot(t_TD,H_TD(:,2),'m','LineWidth',4)
    plot(t_FDR,H_FDR(:,2),'b','LineWidth',2)
    plot(t_FDP,H_FDP(:,2),'g','LineWidth',2)
    set(gca,'XLim',[-3*length(h) 3*length(h)]);    
    xlabel('t')
    title('Impulse Responses')
    legend( sprintf('h_{xy} = %s',hstr),...
            sprintf('h_{xy} time domain; n_T = %d',length(H_TD)),...
            sprintf('h_{xy} freq. domain Rectangular; n_R = %d', df),...
            sprintf('h_{xy} freq. domain Parzen; n_P = %d',length(fe_FDP))...
           )
   plotcmds(['impulse_responses',paramstring],writeimgs)

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
