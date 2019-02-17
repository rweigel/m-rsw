addpath('./m');
addpath('./m/LIBRA');
addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

%mtplots(SI)

opts = main_options(4);

dateo = '20031029';
datef = '20031031';

dateo = '20031029';
datef = '20031031';

dateo = '20031101';
datef = '20031109';

dateo = '20060403';
datef = '20060410';

%dateo = '20150110';
%datef = '20150116';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts = main_options(1);
prepdirs(dateo,opts.filestr);

[tE,E,tB,B] = prep_EB(dateo,datef,0);
t = tE;
tGIC = tE;
GIC = E;

[GIC,E,B] = removemean(GIC,E,B);

B = B(1:86400,:);
E = E(1:86400,:);

S = transferfnFD(B(:,1:2),E,opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D = readEDIXML([fileparts(mfilename('fullpath')),'/MMB.xml']);

fe = transpose(1./D.PERIOD);

% Convert Z from having columns of period to rows of period
Z  = transpose(D.Z);

% Sort fe and Z so they are increasing in frequency instead of period
[fe,I] = sort(fe);
Z = Z(I,:);

% Coordinate system appears to be x = East, y = South. Convert to
% y = North.
Z(:,2) = -Z(:,2);
Z(:,4) = -Z(:,4);

% Add zero frequency (need to remove need for this in Zpredict; Zpredict
% should check if fe(1) == 0 and if not, add a zero frequency)
Z  = [0,0,0,0;Z];
fe = [0;fe];

Ep = Zpredict(fe,Z,B(:,1:2));
pe(E,Ep)
break
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = {[255/255,168/255,0],'r','b','g'};
figure(1);clf;
    for i = 1:2
        semilogx(1./S.fe(2:end),imag(S.Z(2:end,i)),'Color',c{i},...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};
    legend(components);
    for i = 1:2
        semilogx(1./SI.fe(2:end),imag(SI.Z(2:end,i)),'Color',c{i},...
            'LineStyle','-','LineWidth',1,'Marker','x','MarkerSize',5);
        hold on;
    end
    
   
break
clear;

dateo = '20031029';
datef = '20031031';

dateo = '20031101';
datef = '20031109';

dateo = '20060403';
datef = '20060410';

dateo = '20150110';
datef = '20150116';

rho_xx = dlmread('data/fuji/yellowPlot1.dat',' ',1,0);
rho_xy = dlmread('data/fuji/redPlot1.dat',' ',1,0);
rho_yx = dlmread('data/fuji/bluePlot1.dat',' ',1,0);
rho_yy = dlmread('data/fuji/greenPlot1.dat',' ',1,0);
T = mean([rho_xx(:,1),rho_xy(:,1),rho_yx(:,1),rho_yy(:,1)],2);
rho = [rho_xx(:,2),rho_xy(:,2),rho_yx(:,2),rho_yy(:,2)];

phi_xx = dlmread('data/fuji/yellowPlot2.dat',' ',1,0);
phi_xy = dlmread('data/fuji/redPlot2.dat',' ',1,0);
phi_yx = dlmread('data/fuji/bluePlot2.dat',' ',1,0);
phi_yy = dlmread('data/fuji/greenPlot2.dat',' ',1,0);
T = mean([phi_xx(:,1),phi_xy(:,1),phi_yx(:,1),phi_yy(:,1)],2);
phi = [phi_xx(:,2),phi_xy(:,2),phi_yx(:,2),phi_yy(:,2)];

T = mean(T,2);

T = 10.^T;
rho = 10.^rho;
phi = 10.^phi;


opts = main_options(4);

prepdirs(dateo,opts.filestr);
[tE,E,tB,B] = prep_EB(dateo,datef,0);

t = tE;
tGIC = tE;
GIC = E;

[GIC,E,B] = removemean(GIC,E,B);

S = transferfnFD(B(:,1:2),E,opts);
S.Bunits = 'nT';
S.Eunits = 'mV/km';

mtplots(S);

c = {[255/255,168/255,0],'r','b','g'};
figure(2)
    for i = 1:4
        loglog(T,rho(:,i),'Color',c{i},...
            'LineStyle','-','LineWidth',1,'Marker','x','MarkerSize',5);
        hold on;
    end
    
    
    
break

opts.td.window.width = 86400;
opts.td.window.shift = 86400;
S = transferfnFD(B(:,1:2),E,opts);

Savg = struct();
Savg.fe = S.fe;
Savg.Z = mean(S.Z,3);

Savg.Phi = atan2(imag(Savg.Z),real(Savg.Z));
Savg.Bunits = 'nT';
Savg.Eunits = 'mV/km';

mtplots(Savg);
break

dateos = {dateo};
aggregate_TFs(dateos,filestr);

diary off
diary(sprintf('log/compute_TF_aves_%s.txt',filestr));
compute_TF_aves(filestr);
diary off

plot_TF_aves(1,filestr);