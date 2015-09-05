clear

addpath('../../time/')
addpath('../../stats/')
addpath('../misc/')

writeimgs = 1;

tau = 10;  % Filter decay constant
N   = 1e4; % Simulation length
Nc  = 51;  % Comment out to use Nc = length(h)
df  = 50;  % Width of rectangualar window
nb  = 0.0; % Noise in B
ne  = 0.5; % Noise in E
ndb = 0.0; % Noise in dB

paramstring = sprintf('_ne_%.1f',ne);

% IRF for dx/dt + x/tau = delta(0), and ICs
% x_0 = 0 dx_0/dt = 0 approximated using forward Euler.
dt = 1;
gamma = (1-dt/tau);
for i = 1:10*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end
hstr = sprintf('(1-1/%d)^{t}; t=1 ... %d; h_{xy}(0)=0;', tau, length(h));
h  = [0;h];
th = [0:length(h)-1];

% Exact transfer function
Zxy = fft(h);
Nh  = length(Zxy);
Zxy = Zxy(1:floor(Nh/2)+1);
fh  = [0:Nh/2]'/Nh;

% Exact transfer Function Phase
Pxy = (180/pi)*atan2(imag(Zxy),real(Zxy));

% Add extra values to get nice length
% (because we cut off non-steady state).
N = N + 2*length(h);

% Noise
NE  = [ne*randn(N,1),ne*randn(N,1)];
NB  = [nb*randn(N,1),nb*randn(N,1)];
NdB = [ndb*randn(N,1),ndb*randn(N,1)];

% Create signals
B(:,1) = randn(N,1);
B(:,2) = randn(N,1);

E(:,2) = filter(h,1,B(:,1)+NB(:,1)) + NE(:,2);
E(:,1) = filter(h,1,B(:,2)+NB(:,2)) + NE(:,1);

dB = diff(B);
dB = [dB;dB(end,:)];

% Remove non-steady-state part of signals
B  = B(2*length(h)+1:end,:);
E  = E(2*length(h)+1:end,:);
dB = dB(2*length(h)+1:end,:);

NE  = NE(2*length(h)+1:end,:);
NB  = NB(2*length(h)+1:end,:);
NdB = NdB(2*length(h)+1:end,:);

N = size(B,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Raw periodograms

N = size(B,1);
f = [0:N/2]'/N;

X    = [B,dB,E,NB,NdB,NE];
ftX  = fft(X);
pX   = ftX;

ftB   = pX(:,1:2);
ftdB  = pX(:,3:4);
ftE   = pX(:,5:6);
ftNB  = pX(:,7:8);
ftNdB = pX(:,9:10);
ftNE  = pX(:,11:12);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time Domain
Na = 0; % The number of acausal coefficients
if ~exist('Nc')
    Nc = length(h); % The number of causal coefficients
end
Ts = 0; % Shift input with respect to output

% T is the output, X is the input.
% Each row of X contains time delayed values of u
[T,X] = time_delay(E(:,2),B(:,1),(Nc-1),Ts,Na,'pad');

% Compute model by solving for H = {h0,h1,...} in overdetermined set
% of equations
% ym(n)   = h0 + u(n-1)*h(1) + u(n-2)*h(2) + ...
% ym(n+1) = h0 + u(n-0)*h(1) + u(n-1)*h(2) + ...
% ...
% If any row above contains a NaN, it is omitted from the computation.
% Solve for Ym = X*H -> H = Ym\U 
LIN = basic_linear(X,T);

% Impulse response function using basic_linear() (last element is h0)
hBL = LIN.Weights(1:end-1) + LIN.Weights(end);
hBL = [0;hBL]; % Zero is because Na = 0 -> h(t<=0) = 0.
tBL = [0:length(hBL)-1];

[HBL,TBL] = impedanceTD(B,E,Nc);
[ZBL,fBL,HBLi,fBLi] = H2Z(TBL,HBL,th);
EpBL = Hpredict(TBL,HBL,B);

ZxyBL  = ZBL(:,2);
ZxyBLi = ZBLi(:,2);
hBL    = HBL(:,2);
EyBL   = EpBL(:,2);

break
% Transfer Function
ZxyBL = fft(hBL);
NBL   = length(ZxyBL);
ZxyBL = ZxyBL(1:floor(NBL/2)+1);
feBL  = [0:NBL/2]'/NBL;

% Transfer Function Phase
PxyBL = (180/pi)*atan2(imag(ZxyBL),real(ZxyBL));

[ZxyBLi,PxyBLi] = H2Z(feBL,hBL,fh);

% Prediction
EyBL = filter(hBL,1,B(:,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency Domain Rectangular

[ZR,feR]        = impedanceFD(B,E,'rectangular');
[HR,tR,ZRi,fRi] = Z2H(feR,ZR,fh);
EpR             = Hpredict(tR,HR,B);

ZxyR  = ZR(:,2);
ZxyRi = ZRi(:,2);
hR    = HR(:,2);
EyR   = EpR(:,2);

% Transfer Function Phase
PxyR  = (180/pi)*atan2(imag(ZxyR),real(ZxyR));
PxyRi = (180/pi)*atan2(imag(ZxyRi),real(ZxyRi));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency Domain Parzen
[ZP,feP]        = impedanceFD(B,E,'parzen');
[HP,tP,ZPi,fPi] = Z2H(feP,ZP,fh);
EpP             = Hpredict(tP,HP,B);

ZxyP  = ZP(:,2);
ZxyPi = ZPi(:,2);
hP    = HP(:,2);
EyP   = EpP(:,2);

% Transfer Function Phase
PxyP  = (180/pi)*atan2(imag(ZxyP),real(ZxyP));
PxyPi = (180/pi)*atan2(imag(ZxyPi),real(ZxyPi));
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
    loglog(NaN*ftB(1:2,1),'r','LineWidth',3)
    hold on;grid on;

    loglog(NaN*ftE(1:2,2),'Color',[1,0.5,0],'LineWidth',3)
    loglog(NaN*ftNB(1:2,1),'k','LineWidth',3)
    loglog(NaN*ftNE(1:2,2),'Color',[0.5,0.5,0.5],'LineWidth',3)
    %ts = sprintf('E_y = filter(h_{xy},1,B_x+\\deltaBx) + \\deltaE_y; \\deltaE_y = \\eta(0,%.2f); \\deltaB_x = \\eta(0,%.2f)',ne,nb);
    %title(ts);
    title('Raw Periodograms')
    loglog(f(2:end),abs(ftB(2:N/2+1,1)),'r')
    loglog(f(2:end),abs(ftNB(2:N/2+1,1)),'Color',[1,0.5,0])
    loglog(f(2:end),abs(ftE(2:N/2+1,2)),'k')
    loglog(f(2:end),abs(ftNE(2:N/2+1,2)),'Color',[0.5,0.5,0.5])
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
    plot(tBL,hBL,'m','LineWidth',4)
    plot(tR,hR,'b','LineWidth',2)
    plot(tP,hP,'g','LineWidth',2)
    xlabel('t')
    title('Impulse Response')
    legend( sprintf('h_{xy} = %s',hstr),...
            sprintf('h_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('h_{xy} freq. domain Rectangular; n_R = %d', df),...
            sprintf('h_{xy} freq. domain Parzen; n_P = %d',length(feP))...
           )
   plotcmds(['impulse_responses',paramstring],writeimgs)

figure(5);clf;
    % Create padded impulse responses.
    tp = [tP(1):th(end)];
    Nl = length(tp)-length(h);

    if (length(hBL) >= length(h))
        Nr   = Nc - length(h);
        tp   = [tP(1):length(h)+Nr-1];
        hp   = [zeros(Nl,1);h;zeros(Nr,1)];
        hBLp = [zeros(Nl,1);hBL];
    else
        Nr = length(h)-length(hBL);
        hp   = [zeros(Nl,1);h];
        hBLp = [zeros(Nl,1);hBL;zeros(Nr,1)];
    end
    
    Nr = length(hBLp)-length(hP);
    hPp = [hP;zeros(Nr,1)];
    hRp = [hR;zeros(Nr,1)];

    hold on;grid on;
    plot(tp,hBLp-hp,'m','LineWidth',4)
    plot(tp,hRp-hp,'b','LineWidth',2)
    plot(tp,hPp-hp,'g','LineWidth',2)
    xlabel('t')
    title('Impulse Response Error')
    legend(...
            sprintf('\\deltah_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('\\deltah_{xy} freq. domain Rectangular; n_f = %d', df),...
            sprintf('\\deltah_{xy} freq. domain Parzen; n_P = %d',length(feP))...
            )
   plotcmds(['impulse_response_errors',paramstring],writeimgs)

figure(6);clf;
    hold on;grid on;
    plot(fh,abs(Zxy),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    plot(feBL,abs(ZxyBL),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    plot(feR,abs(ZxyR),'b','Marker','.','MarkerSize',15,'LineWidth',2);
    plot(feP,abs(ZxyP),'g','Marker','.','MarkerSize',10,'LineWidth',1);
    xlabel('f')
    title('Transfer Function')
    legend(...
            'Z_{xy}',...
            sprintf('Z_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('Z_{xy} freq. domain rectangular (n_R = %d)', df),...
            sprintf('Z_{xy} freq. domain parzen; n_P = %d',length(feP))...
            )
   plotcmds(['transfer_functions',paramstring],writeimgs)

figure(6);clf;
    hold on;grid on;
    plot(fh,abs(Zxy),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    plot(feBL,abs(ZxyBL),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    plot(fRi,abs(ZxyRi),'b','Marker','.','MarkerSize',15,'LineWidth',2);
    plot(fPi,abs(ZxyPi),'g','Marker','.','MarkerSize',10,'LineWidth',1);
    xlabel('f')
    title('Interpolated Transfer Functions')
    legend(...
            'Z_{xy}',...
            sprintf('Z_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('Z_{xy} freq. domain rectangular (n_R = %d)', df),...
            sprintf('Z_{xy} freq. domain parzen; n_P = %d',length(feP))...
            )
   plotcmds(['transfer_functions_interpolated',paramstring],writeimgs)

figure(7);clf;
    hold on;grid on;
    plot(fh,abs(ZxyBLi)-abs(Zxy),'m','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(ZxyRi)-abs(Zxy),'b','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(ZxyPi)-abs(Zxy),'g','Marker','.','MarkerSize',20,'LineWidth',2);
    xlabel('f')
    title('Transfer Function Error')
    legend(...
            sprintf('\\deltaZ_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('\\deltaZ_{xy} freq. domain Rectangular; n_R = %d', df),...
            sprintf('\\deltaZ_{xy} freq. domain Parzen; n_P = %d',length(feP)),...
            'Location','SouthEast')
   plotcmds(['transfer_function_errors',paramstring],writeimgs)

figure(8);clf;
    hold on;grid on;
    plot(fh,abs(Pxy),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    plot(feBL,abs(PxyBL),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    plot(feR,abs(PxyR),'b','Marker','.','MarkerSize',15,'LineWidth',2);
    plot(feP,abs(PxyP),'g','Marker','.','MarkerSize',10,'LineWidth',1);
    xlabel('f')
    title('Transfer Function Phase')
    legend(...
        '\phi_{xy}',...
        sprintf('\\phi_{xy} time domain; n_T = %d',length(hBL)),...
        sprintf('\\phi_{xy} freq. domain Rectangular; n_R = %d', df),...
        sprintf('\\phi_{xy} freq. domain Parzen; n_P = %d',length(feP)),...
        'Location','SouthEast'...
    )
   plotcmds(['transfer_function_phases',paramstring],writeimgs)

figure(9);clf;
    hold on;grid on;
    plot(fh,abs(PxyBLi)-abs(Pxy),'m','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(PxyRi)-abs(Pxy),'b','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(PxyPi)-abs(Pxy),'g','Marker','.','MarkerSize',20,'LineWidth',2);
    xlabel('f')
    title('Transfer Function Phase Error')
    legend(...
            sprintf('\\delta\\phi_{xy} time domain; n_T = %d',length(hBL)),...
            sprintf('\\delta\\phi_{xy} freq. domain Rectangular; n_R = %d', df),...
            sprintf('\\delta\\phi_{xy} freq. domain Parzen; n_P = %d',length(feP)),...
            'Location','NorthEast')
   plotcmds(['transfer_function_phase_errors',paramstring],writeimgs)

figure(10);clf;
    hold on;grid on;
    plot(E(:,2),'k','LineWidth',3)
    plot(EyBL,'m')
    plot(EyR,'b')
    plot(EyP,'g')
    xlabel('t')
    title('Prediction')
    legend('E_y',...
            'E_y time domain',...
            'E_y freq. domain Rectangular',...
            'E_y freq. domain Parzen'...
            )
   plotcmds(['predictions',paramstring],writeimgs)

figure(11);clf;
    hold on;grid on;
    plot(E(:,2)-EyBL+10,'m')
    plot(E(1:length(EyR),2)-EyR,'b')
    plot(E(1:length(EyP),2)-EyP-10,'g')
    peP = pe(E(1:length(EyP),2),EyP);
    peR = pe(E(1:length(EyR),2),EyR);
    peBL = pe(E(:,2),EyBL);
    xlabel('t')
    title('Prediction Error')
    set(gca,'YLim',[-20 20])
    legend(...
        sprintf('\\DeltaE_y+10 time domain; PE = %.3f',peBL),...        
        sprintf('\\DeltaE_y freq. domain Rectangular; PE = %.3f',peR),...
        sprintf('\\DeltaE_y-10 freq. domain Parzen; PE = %.3f',peP)...
        );
    plotcmds(['prediction_errors',paramstring],writeimgs)
