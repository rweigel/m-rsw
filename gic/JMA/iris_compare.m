%F = load('./../data/iris/MBB03/data/MBB03-counts-cleaned.mat');
F = load('./../data/iris/UTP17/data/UTP17-counts-cleaned.mat');
Ikeep = [86400*1+1:86400*5];
B = F.D(Ikeep,1:3)*1e-2;
E = F.D(Ikeep,4:5)*3.0e-5;

%[Z,W] = transferfuncGIC(E(:,1),B(:,1),B(:,2),1,1,86400,1,10);

addpath('../iris');
addpath('~/git/m-rsw/xml')
%D = readEDIXML('MBB03','../iris/SPUD_bundle_2016-03-23T17.38.28',0,0);
D = readEDIXML('UTP17','../iris/SPUD_bundle_2016-03-23T17.38.28',0,0);

fe_O = transpose(1./D.PERIOD);
Z_O  = transpose(D.Z);
[fe_O,I] = sort(fe_O);
Z_O = Z_O(I,:);
Z_O  = [0,0,0,0;Z_O];
fe_O = [0;fe_O];

N = size(B,1);
f = [0:N/2]'/N;

%Z_O = fliplr(Z_O); % Transform to x = East, y = North system

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

opts = main_options(1);
opts.td.window.width = 86400;
opts.td.window.shift = 86400;
S = transferfnFD(B(:,1:2),E,opts);

Savg = struct();
Savg.fe = S.fe;
Savg.Z = mean(S.Z,3);

Savg.Phi = atan2(imag(Savg.Z),real(Savg.Z));
Savg.Bunits = 'nT';
Savg.Eunits = 'mV/km';

Ep = Zpredict(Savg.fe,Savg.Z,B(:,1:2));

I = 1:size(B,1);
pe_nonflag(E(I,:),Ep(I,:))
pe_nonflag(E(I,:),-Ep_O(I,:))
figure(1);clf;
    plot(-Ep_O(I,1),'g');
    hold on;
    plot(E(I,1),'k');
    plot(Ep(I,1),'r');
    
figure(2);clf;
    plot(-Ep_O(1:86400,2),'g');
    hold on;
    plot(E(1:86400,2),'k');
    plot(Ep(1:86400,2),'r');    
%
break

components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};
c = ['y','r','b','g'];

figure(1);clf;
fe = Savg.fe;
T = D.PERIOD;
for i = 2:3
    loglog(1./fe(2:end),abs(Savg.Z(2:end,i)),'r');
    hold on;grid on;
    loglog(T,abs(D.Z(i,:)),'g');    
end