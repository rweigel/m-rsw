s = dbstack;
n = s(1).name;

fprintf('mainZ:\n')
mu_0 = 4*pi*1e-7; % Vacuum permeability

if strcmp(input,'dB')
    IN = dB; % Input
end
if strcmp(input,'B')
    IN = B; % Input
end

N = size(B,1);
if mod(N,2) ~= 0
  fprintf('%s: Removing last value to make # values even.\n');
  B = B(1:end-1,:);
  dB = dB(1:end-1,:);
  E = E(1:end-1,:);
  t = t(1:end-1);
  dn = dn(1:end-1);
  IN = IN(1:end-1,:);
end
N = size(B,1);

f = [0:N/2]'/N;

fstr = 'measured';
if (hpNf > 0)
    tx      = exp(-[0:hpNf]/hpNf);
    Ef(:,1) = filter([0,tx/sum(tx)],1,E(:,1));
    Ef(:,2) = filter([0,tx/sum(tx)],1,E(:,2));
    tit     = 'Using filtered E to derive TF';
    fstr    = 'filtered';
else
    Ef    = 0*E;
    tit   = 'Using measured E to derive TF';
end

E = E-Ef;

cut = floor(size(IN,1)/2);
Itr = [1:cut];
Ite = [cut+1:size(IN,1)];

%Itr = [1:size(IN,1)];
%Ite = [1:size(IN,1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute transfer function using transferfnTD.m
Nc = 10;
Ns = 86400;
if ppd == 86400
    [Z_TD,f_TD,H_TD,t_TD,E_TD] = transferfnTD2ave(IN,E,Nc,0,Ns);
else
    [Z_TD,f_TD,H_TD,t_TD,E_TD] = transferfnTD(IN,E,Nc,0);    
end
E_TD2 = Hpredict(t_TD,H_TD,IN);

pev_TD(1)  = pe_nonflag(E(:,1),E_TD(:,1));
pev_TD(2)  = pe_nonflag(E(:,2),E_TD(:,2));
tmp        = corrcoef(E(:,1),E_TD(:,1),'rows','pairwise');
ccv_TD(1)  = tmp(2);
tmp        = corrcoef(E(:,2),E_TD(:,2),'rows','pairwise');
ccv_TD(2)  = tmp(2);

fprintf('  TD:\n');
fprintf('   Ex: pe = %0.2f; cc = %.2f\n',pev_TD(1),ccv_TD(1))
fprintf('   Ey: pe = %0.2f; cc = %.2f\n',pev_TD(2),ccv_TD(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute transfer function using transferfnFD.m
[Z_FDRe,fe_FDRe] = transferfnFD(IN(Itr,:),E(Itr,:),2,'rectangular');

Z_FDRe(1,:) = 0;

H_FDRe = Z2H(fe_FDRe,Z_FDRe,f);
H_FDRe = fftshift(H_FDRe,1);
N_FDRe = (size(H_FDRe,1)-1)/2;
t_FDRe = [-N_FDRe:N_FDRe]';

% Apparent Resistivity
for k = 1:size(Z_FDRe,2)
    R_FDRe(:,k) = 1e6*(mu_0./(2*pi*fe_FDRe(2:end))).*(abs(Z_FDRe(2:end,k)).^2);
end
Z_FDRei = Zinterp(fe_FDRe,Z_FDRe,f);

fprintf('  transferfnFD rectangular logarithmic frequencies\n')
Ep_FDRe = Zpredict(fe_FDRe,Z_FDRe,IN);
Ep_FDRe = real(Ep_FDRe);

E_FDRe  = E-Ep_FDRe;
for i = 1:2
    tmp = E_FDRe(1:ppd*floor(size(E_FDRe,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f_FDRe  = [0:NA/2]'/NA;
f_FDRe  = f_FDRe(2:end);
EP_FDRe = pa(2:NA/2+1,:);

% Transfer Function Phase
P_FDRe  = (180/pi)*atan2(imag(Z_FDRe),real(Z_FDRe));

pev_FDRe(1) = pe(E(Itr,1),Ep_FDRe(Itr,1));
pev_FDRe(2) = pe(E(Itr,2),Ep_FDRe(Itr,2));
tmp         = corrcoef(E(Itr,1),Ep_FDRe(Itr,1));
ccv_FDRe(1) = tmp(2);
tmp         = corrcoef(E(Itr,2),Ep_FDRe(Itr,2));
ccv_FDRe(2) = tmp(2);
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pev_FDRe(1),ccv_FDRe(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pev_FDRe(2),ccv_FDRe(2))

pete_FDRe(1) = pe(E(Ite,1),Ep_FDRe(Ite,1));
pete_FDRe(2) = pe(E(Ite,2),Ep_FDRe(Ite,2));
tmp         = corrcoef(E(Ite,1),Ep_FDRe(Ite,1));
ccte_FDRe(1) = tmp(2);
tmp         = corrcoef(E(Ite,2),Ep_FDRe(Ite,2));
ccte_FDRe(2) = tmp(2);
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_FDRe(1),ccte_FDRe(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_FDRe(2),ccte_FDRe(2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute transfer function using transferfnFD.m
[Z_FDR,fe_FDR] = transferfnFD(IN(Itr,:),E(Ite,:),2,'rectangular',100);

Z_FDR(1,:) = 0;

H_FDR = Z2H(fe_FDR,Z_FDR,f);
H_FDR = fftshift(H_FDR,1);
N_FDR = (size(H_FDR,1)-1)/2;
t_FDR = [-N_FDR:N_FDR]';

% Apparent Resistivity
for k = 1:size(Z_FDR,2)
    R_FDR(:,k) = 1e6*(mu_0./(2*pi*fe_FDR(2:end))).*(abs(Z_FDR(2:end,k)).^2);
end
Z_FDRi = Zinterp(fe_FDR,Z_FDR,f);

fprintf('  transferfnFD rectangular\n')
Ep_FDR = Zpredict(fe_FDR,Z_FDR,IN);
Ep_FDR = real(Ep_FDR);

E_FDR  = E-Ep_FDR;
for i = 1:2
    tmp = E_FDR(1:ppd*floor(size(E_FDR,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f_FDR  = [0:NA/2]'/NA;
f_FDR  = f_FDR(2:end);
EP_FDR = pa(2:NA/2+1,:);

% Transfer Function Phase
P_FDR  = (180/pi)*atan2(imag(Z_FDR),real(Z_FDR));

pev_FDR(1) = pe(E(:,1),Ep_FDR(:,1));
pev_FDR(2) = pe(E(:,2),Ep_FDR(:,2));
tmp        = corrcoef(E(:,1),Ep_FDR(:,1));
ccv_FDR(1) = tmp(2);
tmp        = corrcoef(E(:,2),Ep_FDR(:,2));
ccv_FDR(2) = tmp(2);
fprintf('   Ex: pe = %0.2f; cc = %.2f\n',pev_FDR(1),ccv_FDR(1))
fprintf('   Ey: pe = %0.2f; cc = %.2f\n',pev_FDR(2),ccv_FDR(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute transfer function using transferfnFD.m
[Z_FDP,fe_FDP] = transferfnFD(IN,E,dim,'parzen');

Z_FDP(1,:) = 0;

H_FDP = Z2H(fe_FDP,Z_FDP,f);
H_FDP = fftshift(H_FDP,1);
N_FDP = (size(H_FDP,1)-1)/2;
t_FDP = [-N_FDP:N_FDP]';

% Apparent Resistivity
for k = 1:size(Z_FDP,2)
    RR(:,k) = 1e6*(mu_0./(2*pi*fe_FDP(2:end))).*(abs(Z_FDP(2:end,k)).^2);
end
%fprintf('\n')
%fprintf('%s: Computing interpolated transfer function.\n',n)
% Interpolate transfer function onto original frequency grid
Z_FDPi = Zinterp(fe_FDP,Z_FDP,f);

fprintf('  transferfnFD parzen\n')
%fprintf('%s: Computing predictions.\n',n)
% Predict using interpolated transfer function
Ep_FDP = Zpredict(fe_FDP,Z_FDP,IN);
Ep_FDP = real(Ep_FDP);

E_FDP  = E-Ep_FDP;
for i = 1:2
    tmp = E_FDP(1:ppd*floor(size(E_FDP,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f_FDP  = [0:NA/2]'/NA;
f_FDP  = f_FDP(2:end);
EP_FDP = pa(2:NA/2+1,:);

% Transfer Function Phase
P_FDP  = (180/pi)*atan2(imag(Z_FDP),real(Z_FDP));

pev_FDP(1) = pe(E(:,1),Ep_FDP(:,1));
pev_FDP(2) = pe(E(:,2),Ep_FDP(:,2));
tmp        = corrcoef(E(:,1),Ep_FDP(:,1));
ccv_FDP(1) = tmp(2);
tmp        = corrcoef(E(:,2),Ep_FDP(:,2));
ccv_FDP(2) = tmp(2);
fprintf('   Ex: pe = %0.2f; cc = %.2f\n',pev_FDP(1),ccv_FDP(1))
fprintf('   Ey: pe = %0.2f; cc = %.2f\n',pev_FDP(2),ccv_FDP(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use USGS apparent resistivity to compute transfer function
addpath('zplanewave')

M = 1;
[rho,h] = ModelInfo(modelstr);

s        = 1./rho'; % 1/[ohm-m]
h        = h'; % in [m]

% C = Ex/(i*2*pi*By)
C      = zplanewave(s,h,f(2:end)); % in [m] or [V/m/(T-s)];
C      = [0;transpose(C)];
Z_U    = j*2*pi*f.*C; % [V/m / T] or [m/s]
Z_U    = Z_U*1e-3; % Convert to mV/km / nT or [km/s]
Z_U    = Z_U/modelsf;
Ep_U   = real(Zpredict(f,Z_U,-B)); % Give E in [mV/km]; B is in [nT]

% ?????? Why does -B give better results ????????

E_U  = E-Ep_U;
for i = 1:2
    tmp = E_U(1:ppd*floor(size(E_U,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f_U  = [0:NA/2]'/NA;
f_U  = f_U(2:end);
EP_U = pa(2:NA/2+1,:);

pev_U(1) = pe(E(:,1),Ep_U(:,1));
pev_U(2) = pe(E(:,2),Ep_U(:,2));
tmp      = corrcoef(E(:,1),Ep_U(:,1));
ccv_U(1) = tmp(2);
tmp      = corrcoef(E(:,2),Ep_U(:,2));
ccv_U(2) = tmp(2);

H_U = Z2H(f,Z_U,f);
H_U = fftshift(H_U,1);
N_U = (size(H_U,1)-1)/2;
t_U = [-N_U:N_U]';

% Transfer Function Phase
P_U = (180/pi)*atan2(imag(Z_U),real(Z_U));

fprintf('  USGS %s\n',modelstr);
fprintf('   Ex: pe = %0.2f; cc = %.2f\n',pev_U(1),ccv_U(1))
fprintf('   Ey: pe = %0.2f; cc = %.2f\n',pev_U(2),ccv_U(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(agent,'IRIS')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OSU-calculated Z
addpath('iris');
fprintf('  OSU:\n');
xmlfile = sprintf('./data/iris/%s/%s.xml',short,short);
addpath('../xml');
D   = readEDIXML(short,'iris/SPUD_bundle_2016-03-23T17.38.28',0,0);
fe_O = transpose(1./D.PERIOD);
Z_O  = transpose(D.Z);
% Z units are [mV/km]/[nT] (see xml file)
fprintf('   Data quality = %d; Note: %s\n',...
	D.DataQualityRating,D.DataQualityNotes);

% Zxx Zxy Zyx Zyy -> (Zyy Zyx Zxy Zxx)
% Unless this is done, predictions using OSU model are very poor
% (PE < 0) and inconsistencies with my calculation of Z
% (Zxx and Zyy are reversed)
Z_O = fliplr(Z_O);

% Order fe and Z by increasing frequency.
[fe_O,I] = sort(fe_O);
Z_O = Z_O(I,:);

% Add zero frequency
Z_O  = [0,0,0,0;Z_O];
fe_O = [0;fe_O];

% Apparent Resistivity
for k = 1:size(Z_O,2)
  R_O(:,k) = 1e6*(mu_0./(2*pi*fe_O(2:end))).*(abs(Z_O(2:end,k)).^2);
end

% Interpolate transfer function onto original frequency grid
Z_Oi = Zinterp(fe_O,Z_O,f);

% Predict using interpolated transfer function
%fprintf('%s: Computing predictions.\n',n)
Ep_O = Zpredict(fe_O,Z_O,[B(:,1),B(:,2)]);
Ep_O = real(Ep_O);

E_O  = E-Ep_O;
for i = 1:2
    tmp = E_O(1:ppd*floor(size(E_O,1)/ppd),i);
    tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
    p   = fft(tmp);
    pa(:,i) = mean(abs(p),2);
end
NA   = size(pa,1);
f_O  = [0:NA/2]'/NA;
f_O  = f_O(2:end);
EP_O = pa(2:NA/2+1,:);

Ipe = [60*10:size(E,1)-60*10];

pev_O(1) = pe(E(Itr,1),Ep_O(Itr,1));
pev_O(2) = pe(E(Itr,2),Ep_O(Itr,2));
tmp      = corrcoef(E(Itr,1),Ep_O(Itr,1));
ccv_O(1) = tmp(2);
tmp      = corrcoef(E(Itr,2),Ep_O(Itr,2));
ccv_O(2) = tmp(2);
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pev_O(1),ccv_O(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pev_O(2),ccv_O(2))

pete_O(1) = pe(E(Ite,1),Ep_O(Ite,1));
pete_O(2) = pe(E(Ite,2),Ep_O(Ite,2));
tmp       = corrcoef(E(Ite,1),Ep_O(Ite,1));
ccte_O(1) = tmp(2);
tmp       = corrcoef(E(Ite,2),Ep_O(Ite,2));
ccte_O(2) = tmp(2);
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_O(1),ccte_O(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_O(2),ccte_O(2))

H_O  = Z2H(fe_O,Z_O,f);
H_O  = fftshift(H_O,1);
N_O  = (size(H_O,1)-1)/2;
t_O  = [-N_O:N_O]';

% Transfer Function Phase
P_O  = (180/pi)*atan2(imag(Z_O),real(Z_O));
%fprintf('%s\n',repmat('-',80,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
