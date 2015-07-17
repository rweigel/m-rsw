clear

addpath('../time/')
addpath('../stats/')

writeimgs = 1;

N = 1e4;

% Compute IRF for dx/dt + x/tau = delta(0), and IC of x_0 = 0 dx_0/dt = 0
% using forward Euler.
tau = 10;
dt = 1;
gamma = (1-dt/tau);
for i = 1:10*tau
    h(i,1) = gamma^(i-1);
    t(i,1) = dt*(i-1);
end

h  = [0;h];
th = [0:length(h)-1];

% Transfer function
Zxy = fft(h);
Nh  = length(Zxy);
Zxy = Zxy(1:floor(Nh/2)+1);
fh  = [0:Nh/2]'/Nh;

% Noise
ne = 0.1;
NE = [ne*randn(N,1),ne*randn(N,1)];
NB = [0*randn(N,1),0*randn(N,1)];

% Create an input signal
B(:,1) = randn(N,1);
E(:,2) = filter(h,1,B(:,1)+NB(:,1)) + NE(:,2);
B(:,2) = randn(N,1);
E(:,1) = filter(h,1,B(:,2)+NB(:,2)) + NE(:,1);

dB = diff(B);
dB = [dB;dB(end,:)];

% Remove non-steady-state part of input and output
B  = B(2*length(h)+1:end,:);
dB = dB(2*length(h)+1:end,:);
E  = E(2*length(h)+1:end,:);
NE = NE(2*length(h)+1:end,:);
NB = NB(2*length(h)+1:end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time Domain
Na = 0;         % The number of acausal coefficients
Nc = length(h); % The number of causal coefficients
Ts = 0;         % Shift input with respect to output

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

ZxyBL = fft(hBL);
NBL   = length(ZxyBL);
ZxyBL = ZxyBL(1:floor(NBL/2)+1);
feBL  = [0:NBL/2]'/NBL;

EyBL = filter(hBL,1,B(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency Domain Rectangular

% Raw periodograms
X    = [B,dB,E];
ftX  = fft(X);
pX   = ftX;

ftB = pX(:,1:2);
ftE = pX(:,5:6);

f   = [0:N/2]'/N;

% Smooth in frequency domain with Rectangular window.
df = 50;
IcR = [df+1:df:length(f)];
for i = 1:size(X,2)
    for j = 1:length(IcR)
        feR(j) = f(IcR(j));
        NeR(j) = df;
        r      = [IcR(j)-df:IcR(j)+df];
        parts{j,i} = pX(r,i); % Parts to apply window to.
        pR(j,i) = sum(parts{j,i})/(2*df+1);
    end
end
% Add zero frequency.
feR = [0,feR];
NeR = [0,NeR];
IcR = [1,IcR];

% Compute transfer function.  No scaling window scaling needed
% because ratio.
for j = 1:length(feR)
    r = [IcR(j)-NeR(j):IcR(j)+NeR(j)];
    ZxyR(j) = sum(ftE(r,1).*conj(ftB(r,2)))/sum(ftB(r,2).*conj(ftB(r,2)));
end

ZxyRi = interp1(feR(2:end),ZxyR(2:end),fh(2:end));
ZxyRi(isnan(ZxyRi)) = 0;
ZxyRifull = [ZxyR(1);ZxyRi;flipud(conj(ZxyRi))];

ZxyRi = [ZxyR(1);ZxyRi];

% Compute impulse response
hR = fftshift(ifft(ZxyRifull));
NR = (length(hR)-1)/2;
tR = [-NR:NR];

EyR  = filter(hR,1,B(:,1));
EyR  = EyR(NR:end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency Domain Parzen

% Evaluation frequencies for frequency domain smoothing
fprintf('--\nComputing evaluation frequencies for smoothing.\n--\n')
k = 1;
feP(k) = f(end)/2;
NeP(k) = feP(k)/(2*(1/N));
IcP(k) = find(f-feP(1) > 0,1);
fprintf('Computed evaluation frequency:      %.8f\n',feP(k));
fprintf('Nearest larger frequency available: %.8f\n',f(IcP(k))); 
while feP(k) > f(2)
    k = k+1;
    tmp = feP(1)/sqrt(2^(k-1));
    if (tmp < f(2)),break,end
    feP(k) = tmp;
    IcP(k) = find(f-feP(k) > 0,1);
    fprintf('Computed evaluation frequency:      %.8f\n',feP(k));
    fprintf('Nearest larger frequency available: %.8f\n',f(IcP(k))); 
    feP(k) = f(IcP(k));
    % Number of points to left and right of fe to apply window to.
    NeP(k) = floor(feP(k)/(2*(1/N)));
end
fprintf('Created %d evaluation frequencies.\n',length(feP));
feP = fliplr(feP);
NeP = fliplr(NeP);
IcP = fliplr(IcP);

lo = length(feP);
[feP,Iu] = unique(feP);
NeP = NeP(Iu);
IcP = IcP(Iu);
if (lo > length(feP))
    fprintf('Removed %d duplicate frequencie(s).\n',lo-length(feP));
end
% Add zero frequency.
feP = [0,feP];
NeP = [0,NeP];
IcP = [1,IcP];

fprintf('--\nUsing windows to compute smooth spectra and cross spectra.\n--\n')
% Smooth spectra in frequency domain with Parzen window.
for i = 1:size(X,2)
    for j = 1:length(feP)
        pw{j}   = parzenwin(2*NeP(j)+1); % Create window.
        pw{j}   = pw{j}/sum(pw{j});     % Normalize window function.
        r       = [IcP(j)-NeP(j):IcP(j)+NeP(j)];
        fa      = f(IcP(j)-NeP(j));
        fb      = f(IcP(j)+NeP(j));
        if (i == 1)
            fprintf('Window at f = %.8f has %d points; fl = %.8f fh = %.8f\n',feP(j),length(r),fa,fb)
        end
        parts{j,i} = pX(r,i); % Parts to apply window to.
        pP(j,i) = sum(pw{j}.*parts{j,i}); % Apply window for freqency j.
    end
end

for j = 1:length(feP)
    r = [IcP(j)-df:IcP(j)+df];
    pw{j}   = parzenwin(2*NeP(j)+1); 
    pw{j}   = pw{j}/sum(pw{j});     
    r = [IcP(j)-NeP(j):IcP(j)+NeP(j)];
    ZxyP(j) = sum(pw{j}.*ftE(r,1).*conj(ftB(r,2)))/sum(pw{j}.*ftB(r,2).*conj(ftB(r,2)));
end

% Interpolate onto (uniform) frequency grid of Zxy
% (uniform needed so ifft can be used).
ZxyPi = interp1(feP(2:end),ZxyP(2:end),fh(2:end));
ZxyPi(isnan(ZxyPi)) = 0;
ZxyPifull = [ZxyP(1);ZxyPi;flipud(conj(ZxyPi))];
ZxyPi = [ZxyP(1);ZxyPi];

%ZxyPi = [0;ZxyPi;flipud(conj(ZxyPi))];

hP = fftshift(ifft(ZxyPifull));
NP = (length(hP)-1)/2;
tP = [-NP:NP];

EyP  = filter(hP,1,B(:,1));
EyP  = EyP(NP:end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);clf;hold on; grid on;
    plot(NaN*B(1:2,1),'r','LineWidth',3)
    plot(NaN*E(1:2,2),'Color',[1,0.5,0],'LineWidth',3)
    plot(NaN*E(1:2,2),'k','LineWidth',3)
    plot(NaN*E(1:2,2),'Color',[0.5,0.5,0.5],'LineWidth',3)

    title('E_y = filter(h_{xy},1,B_x+\deltaBx) + \deltaE_y');
    plot(B(:,1)+15,'r')
    plot(NB(:,1)+5,'Color',[1,0.5,0])
    plot(E(:,2)-5,'k')
    plot(NE(:,2)-15,'Color',[0.5,0.5,0.5])
    xlabel('t')
    set(gca,'YLim',[-25 25])
    legend('B_x+15 (input)','\deltaB_x+5 (noise)','E_y-5 (output)','\deltaE_y-15 (noise)')
    plotcmds('timeseries',writeimgs)

figure(2);clf;
    hold on;grid on;
    plot(fh,abs(Zxy),'k','Marker','+','MarkerSize',10,'LineWidth',5)
    plot(feBL,abs(ZxyBL),'m','Marker','.','MarkerSize',25,'LineWidth',3);
    plot(feR,abs(ZxyR),'b','Marker','.','MarkerSize',15,'LineWidth',2);
    plot(feP,abs(ZxyP),'g','Marker','.','MarkerSize',10,'LineWidth',1);
    xlabel('f')
    title('Transfer Function')
    legend(...
            'Z_{xy}',...
            'Z_{xy} time domain',...
            'Z_{xy} freq. domain Rectangular',...
            'Z_{xy} freq. domain Parzen'...
            )
   plotcmds('transfer_functions',writeimgs)

figure(3);clf;
    hold on;grid on;
    plot(fh,abs(ZxyBL)-abs(Zxy),'m','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(ZxyRi)-abs(Zxy),'b','Marker','.','MarkerSize',20,'LineWidth',2);
    plot(fh,abs(ZxyPi)-abs(Zxy),'g','Marker','.','MarkerSize',20,'LineWidth',2);
    xlabel('f')
    title('Transfer Function Error')
    legend(...
            '\deltaZ_{xy} time domain',...
            '\deltaZ_{xy} freq. domain Rectangular',...
            '\deltaZ_{xy} freq. domain Parzen',...
            'Location','SouthWest')
   plotcmds('transfer_function_errors',writeimgs)

figure(4);clf;
    hold on;grid on;
    plot(th,h,'k','Marker','+','MarkerSize',5,'LineWidth',5)
    plot(tBL,hBL,'m','LineWidth',4)
    plot(tR,hR,'b','LineWidth',2)
    plot(tP,hP,'g','LineWidth',2)
    xlabel('t')
    title('Impulse Response')
    legend('h_{xy}',...
            'h_{xy} time domain',...            
            'h_{xy} freq. domain Rectangular',...
            'h_{xy} freq. domain Parzen'...
           )
   plotcmds('impulse_responses',writeimgs)

% Create padded impulse responses.
tp  = [tP(1):th(end)];
Np  = length(tp)-length(h);
hp  = [zeros(Np,1);h];
hPp = [hP;zeros(Np,1)];
hRp = [hR;zeros(Np,1)];
hBLp = [zeros(Np,1);hBL];

figure(5);clf;
    hold on;grid on;
    plot(tp,hBLp-hp,'m','LineWidth',4)
    plot(tp,hRp-hp,'b','LineWidth',2)
    plot(tp,hPp-hp,'g','LineWidth',2)
    xlabel('t')
    title('Impulse Response Error')
    legend(...
            '\deltah_{xy} time domain',...
            '\deltah_{xy} freq. domain Rectangular',...
            '\deltah_{xy} freq. domain Parzen'...            
            )
   plotcmds('impulse_response_errors',writeimgs)

figure(6);clf;
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
   plotcmds('predictions',writeimgs)

figure(7);clf;
    hold on;grid on;
    plot(E(:,2)-EyBL+10,'m')
    plot(E(1:length(EyR),2)-EyR,'b')
    plot(E(1:length(EyP),2)-EyP-10,'g')
    peP = pe(E(1:length(EyP),2),EyP);
    peR = pe(E(1:length(EyR),2),EyR);
    peBL = pe(E(:,2),EyBL);
    xlabel('t')
    title('Prediction Error')
    legend(...
        sprintf('\\Delta E_y-10 time domain; PE = %.2f',peBL),...        
        sprintf('\\Delta E_y freq. domain Rectangular; PE = %.2f',peR),...
        sprintf('\\Delta E_y+10 freq. domain Parzen; PE = %.2f',peP)...
        );
    plotcmds('prediction_errors',writeimgs)
