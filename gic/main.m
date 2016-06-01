clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');
addpath('./misc');

mainInfo;

writeimgs = 0;
input     = 'dB';
dim       = 2;
hpNf      = 10000;
hpNf      = 0;

label      = sprintf('input-%s_dim-%d_hp-%d',input,dim,hpNf); 
consolestr = sprintf('\n  Site: %s;\n  Agency: %s;\n  Label: %s',...
		     short,agent,label);
labelt     = regexprep(label,'_',', ');
labelt     = regexprep(labelt,'-','=');
titlestrs  = sprintf('%s/%s',short,agent); % Short title string
titlestr   = sprintf('%s/%s; %s',long,agent,labelt); 

labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
cs      = ['r','g','b','r','g','b','m','k'];

fprintf('main: Working on %s\n',consolestr);

% Read data
[B,dB,E,dn] = mainPrepare(short, agent);

if ~isempty(Ikeep)
    B = B(Ikeep,:);
    dB = dB(Ikeep,:);
    E = E(Ikeep,:);
    dn = dn(Ikeep);
end

% Scale data
for i = 1:size(B,2)
  B(:,i)  = B(:,i)*sfB(i);
  dB(:,i) = dB(:,i)*sfB(i);
end
for i = 1:size(E,2)
  E(:,i) = E(:,i)*sfE(i); 
end
[B,dB,E,dn] = mainInterpolate(B,dB,E,dn);
xlab = ['Days since ',datestr(dn(1),31)];
ts1  = datestr(dn(1),29); % Time string for filename
ts2  = datestr(dn(end),29);

[fX,pX,fA,pA,p] = mainCompute(B,dB,E,ppd);
t = [0:size(B,1)-1]'/ppd;

fn = 0;

%mainPlot
mainZ
mainZPlot

