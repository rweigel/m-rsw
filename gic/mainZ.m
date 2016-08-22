s = dbstack;
n = s(1).name;

hpNf = Info.hpNf;
ppd  = Info.ppd;

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
if (0)
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
end
Eo = E;
E = filterE(Eo,Tl,Th);
Ef = Eo-E;

%figure(1);clf;
%plot(f,abs(fft(Ef(:,1))),'LineWidth',2);hold on;grid on;
%plot(f,abs(fft(E(:,1))))

cut = floor(size(IN,1)/2);

reverse = 1;
if (reverse)
    Itr = [2e4+1:cut];
    Ite = [cut+1:size(IN,1)-2e4];
    Itro = [1:cut];
    Iteo = [cut+1:size(IN,1)];
else
    Ite = [2e4+1:cut];
    Itr = [cut+1:size(IN,1)-2e4];
    Iteo = [1:cut];
    Itro = [cut+1:size(IN,1)];
end
%Itr = Itro;
%Ite = Iteo;

if mod(length(Itr),2) ~= 0
    Itr = Itr(1:end-1);
end
if mod(length(Ite),2) ~= 0
    Ite = Ite(1:end-1);
end

%Itr = [1:size(IN,1)];
%Ite = [1:size(IN,1)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use USGS apparent resistivity to compute transfer function
addpath('zplanewave')

M = 1;
[rho,h] = ModelInfo(Info.modelstr);

s        = 1./rho'; % 1/[ohm-m]
h        = h'; % in [m]

% C = Ex/(i*2*pi*By)
C      = zplanewave(s,h,f(2:end)); % in [m] or [V/m/(T-s)];
C      = [0;transpose(C)];
Z_U    = j*2*pi*f.*C; % [V/m / T] or [m/s]
Z_U    = Z_U*1e-3; % Convert to mV/km / nT or [km/s]
Z_U    = -Z_U; % zplanwave has z direction downwards.  In my coordinate
               % system, z is upwards.
Ep_U   = real(Zpredict(f,Z_U,B)); % Gives E in [mV/km]; B is in [nT]

H_U = Z2H(f,Z_U,f);
H_U = fftshift(H_U,1);
N_U = (size(H_U,1)-1)/2;
t_U = [-N_U:N_U]';

E_U  = E-Ep_U;

[cctr_U,petr_U,EPtr_U,ftr_U] = computeMetrics(E(Itr,:),Ep_U(Itr,:),ppd,Tl,Th);
[ccte_U,pete_U,EPte_U,fte_U] = computeMetrics(E(Ite,:),Ep_U(Ite,:),ppd,Tl,Th);

Ep_U = filterE(Ep_U,Tl,Th);
E_U  = filterE(E_U,Tl,Th);

[Cxy_U,f_Cxy] = mscohere(E,Ep_U);

fprintf('  USGS %s\n',Info.modelstr)
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_U(1),cctr_U(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_U(2),cctr_U(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_U(1),ccte_U(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_U(2),ccte_U(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('  transferfnFD parzen window; logarithmic frequencies\n')
[Z_FDP,fe_FDP,H_FDP,t_FDP] = transferfnFD(IN(Itr,:),E(Itr,:),dim,'parzen');

Ep_FDP = Zpredict(fe_FDP,Z_FDP,IN);
Ep_FDP = real(Ep_FDP);

E_FDP  = E-Ep_FDP;
[cctr_FDP,petr_FDP,EPtr_FDP,ftr_FDP] = computeMetrics(E(Itr,:),Ep_FDP(Itr,:),ppd,Tl,Th);
[ccte_FDP,pete_FDP,EPte_FDP,fte_FDP] = computeMetrics(E(Ite,:),Ep_FDP(Ite,:),ppd,Tl,Th);

[Cxy_FDP,f_Cxy] = mscohere(E,Ep_FDP);

fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_FDP(1),cctr_FDP(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_FDP(2),cctr_FDP(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_FDP(1),ccte_FDP(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_FDP(2),ccte_FDP(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(Info.agent,'IRIS')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OSU-calculated Z
addpath('iris');
fprintf('  OSU:\n');
xmlfile = sprintf('./data/iris/%s/%s.xml',Info.short,Info.short);
addpath('../xml');
D   = readEDIXML(Info.short,'iris/SPUD_bundle_2016-03-23T17.38.28',0,0);
fe_O = transpose(1./D.PERIOD);
Z_O  = transpose(D.Z);
% Z units are [mV/km]/[nT] (see xml file)
fprintf('   Data quality = %d; Note: %s\n',...
	D.DataQualityRating,D.DataQualityNotes);

fprintf('   Period range %.1f/%1.f\n',1/fe_O(2),1/fe_O(end));

% In my notation, x = East, y = North.
% In OSU's notation, x' = North, y' = East
% So
%  Zx'x' corresponds to Zyy
%  Zy'y' corresponds to Zxx
%  Zx'y' corresponds to Zyx
%  Zy'x' corresponds to Zxy
% Columns of Z_O are [Zx'x',Zx'y',Zy'x',Zy'y']
Z_O = fliplr(Z_O); % Transform to x = East, y = North system

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

H_O  = Z2H(fe_O,Z_O,f);
H_O  = fftshift(H_O,1);
N_O  = (size(H_O,1)-1)/2;
t_O  = [-N_O:N_O]';

% Predict using interpolated transfer function
%fprintf('%s: Computing predictions.\n',n)
Ep_O = Zpredict(fe_O,Z_O,[B(:,1),B(:,2)]);
Ep_O = real(Ep_O);

E_O  = E-Ep_O;

%sf = [0.5:0.05:2.0];
%for i = 1:length(sf)
%[cctr_O,petr_O,EPtr_O,ftr_O] = computeMetrics(E(Itr,:),sf(i)*Ep_O(Itr,:),ppd,Tl,Th);
%[ccte_O,pete_O,EPte_O,fte_O] = computeMetrics(E(Ite,:),sf(i)*Ep_O(Ite,:),ppd,Tl,Th);
[cctr_O,petr_O,EPtr_O,ftr_O] = computeMetrics(E(Itr,:),Ep_O(Itr,:),ppd,Tl,Th);
[ccte_O,pete_O,EPte_O,fte_O] = computeMetrics(E(Ite,:),Ep_O(Ite,:),ppd,Tl,Th);

Ep_O = filterE(Ep_O,Tl,Th);
E_O  = filterE(E_O,Tl,Th);

[Cxy_O,f_Cxy] = mscohere(E,Ep_O);
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_O(1),cctr_O(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_O(2),cctr_O(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_O(1),ccte_O(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_O(2),ccte_O(2))
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('  transferfnFD rectangular; logarithmic frequencies\n')

[Z_FDRe,fe_FDRe,H_FDRe,t_FDRe] = transferfnFD(IN(Itr,:),E(Itr,:),2,'rectangular');

Ep_FDRe = Zpredict(fe_FDRe,Z_FDRe,IN);
Ep_FDRe = real(Ep_FDRe);

E_FDRe  = E-Ep_FDRe;

[cctr_FDRe,petr_FDRe,EPtr_FDRe,ftr_FDRe] = computeMetrics(E(Itr,:),Ep_FDRe(Itr,:),ppd,Tl,Th);
[ccte_FDRe,pete_FDRe,EPte_FDRe,fte_FDRe] = computeMetrics(E(Ite,:),Ep_FDRe(Ite,:),ppd,Tl,Th);

Ep_FDRe = filterE(Ep_FDRe,Tl,Th);
E_FDRe  = filterE(E_FDRe,Tl,Th);

[Cxy_FDRe,f_Cxy] = mscohere(E,Ep_FDRe);
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_FDRe(1),cctr_FDRe(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_FDRe(2),cctr_FDRe(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_FDRe(1),ccte_FDRe(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_FDRe(2),ccte_FDRe(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('  transferfnFD rectangular; 100 uniformly spaced frequencies per bin\n')
[Z_FDR,fe_FDR,H_FDR,t_FDR] = transferfnFD(IN(Itr,:),E(Itr,:),dim,'rectangular',100);

Ep_FDR = Zpredict(fe_FDR,Z_FDR,IN);
Ep_FDR = real(Ep_FDR);

E_FDR  = E-Ep_FDR;

[cctr_FDR,petr_FDR,EPtr_FDR,ftr_FDR] = computeMetrics(E(Itr,:),Ep_FDR(Itr,:),ppd,Tl,Th);
[ccte_FDR,pete_FDR,EPte_FDR,fte_FDR] = computeMetrics(E(Ite,:),Ep_FDR(Ite,:),ppd,Tl,Th);

[Cxy_FDR,f_Cxy] = mscohere(E,Ep_FDR);

fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_FDR(1),cctr_FDR(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_FDR(2),cctr_FDR(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_FDR(1),ccte_FDR(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_FDR(2),ccte_FDR(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute transfer function using transferfnTD.m
Nc = 10;
if ppd == 86400
    %Nc = [1:120,121:10:1000];
    %Nc = [1:500,501:100:2000];
    %Nc = [3:10:1000];
    %Nc = 1500;
    Nc = 10;
    [Z_TD,f_TD,H_TD,t_TD] = transferfnTD(IN(Itr,:),E(Itr,:),Nc,0);
    Ep_TD = Hpredict(t_TD,H_TD,IN);
    %[Z_TD,f_TD,H_TD,t_TD,Ep_TD] = transferfnTD(IN,E,Nc,0);    
    %Ep_TD2 = Hpredict(t_TD,H_TD,IN);
else
    [Z_TD,f_TD,H_TD,t_TD,E_TD] = transferfnTD(IN,E,Nc,0);    
end

[cctr_TD,petr_TD,EPtr_TD,ftr_TD] = computeMetrics(E(Itr,:),Ep_TD(Itr,:),ppd,Tl,Th);
[ccte_TD,pete_TD,EPte_TD,fte_TD] = computeMetrics(E(Ite,:),Ep_TD(Ite,:),ppd,Tl,Th);

%[Cxy,f] = mscohere(E,Ep_TD);
fprintf('  TD:\n');
fprintf('   train\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',petr_TD(1),cctr_TD(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',petr_TD(2),cctr_TD(2))
fprintf('   test\n');
fprintf('    Ex: pe = %0.2f; cc = %.2f\n',pete_TD(1),ccte_TD(1))
fprintf('    Ey: pe = %0.2f; cc = %.2f\n',pete_TD(2),ccte_TD(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

