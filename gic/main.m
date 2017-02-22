clear;
addpath('../stats');
addpath('../plot');
addpath('../set');
addpath('../time');
addpath('./transferfn');
addpath('./misc');

Sites= {'UTP17','GAA54','ORF03','RET54'};
%Sites = {'UTP17'};
%Sites = {'RET54'};
if (0)
    for idx = 1:length(Sites)
        load(sprintf('tmp/%s',Sites{idx}))
    %    mainZPlot
        mainZPlotPaper
        mainZTablePaper
    end
    break
end

Tl = 9.1;
Th = 18725;

%Tl = 0;
%Th = Inf;

Sites= {'UTP17','GAA54','ORF03','RET54'};
%Sites = {'GAA54'};
%Sites = {'ORF03'};
Sites = {'RET54'};
for idx = 1:length(Sites)
    
    Info = mainInfo(Sites{idx});

    writeimgs = 0;
    input     = 'dB'; % or B
    dim       = 2;
    modelsf   = 1; % Scale factor on 1-D model Z

    label      = sprintf('input-%s_dim-%d_hp-%d',input,dim,Info.hpNf); 
    consolestr = sprintf('\n  Site: %s;\n  Agency: %s;\n  Label: %s',...
			 Info.short,Info.agent,label);
    labelt     = regexprep(label,'_',', ');
    labelt     = regexprep(labelt,'-','=');
    titlestrs  = sprintf('%s/%s',Info.short,Info.agent); % Short title string
    titlestr   = sprintf('%s/%s; %s',Info.long,Info.agent,labelt); 

    labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
    labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
    cs      = ['r','g','b','r','g','b','m','k'];

    fprintf('main: Working on %s\n',consolestr);

    % Read data
    [B,dB,E,dn] = mainPrepare(Info.short, Info.agent);
    
    if ~isempty(Info.Ikeep)
        B  = B(Info.Ikeep,:);
        dB = dB(Info.Ikeep,:);
        E  = E(Info.Ikeep,:);
        dn = dn(Info.Ikeep);
    end

    % Scale data
    for i = 1:size(B,2)
        B(:,i)  = B(:,i)*Info.sfB(i);
        dB(:,i) = dB(:,i)*Info.sfB(i);
    end
    for i = 1:size(E,2)
    	E(:,i) = E(:,i)*Info.sfE(i); 
    end

    [B,dB,E,dn] = mainInterpolate(B,dB,E,dn);
    
    xlab = ['Days since ',datestr(dn(1),31)];
    ts1  = datestr(dn(1),29); % Time string for filename
    ts2  = datestr(dn(end),29);

    [fX,pX,fA,pA,p] = mainCompute(B,dB,E,Info.ppd);

    t = [0:size(B,1)-1]'/Info.ppd;

    fn = 0;
    mainZ
    Sites_ = Sites;clear Sites;
    idx_ = idx;clear idx;
    %save(sprintf('tmp/%s',Sites{idx}),'-regexp','!Sites'); 
    % Negation does not work with regexp in save.
    save(sprintf('tmp/%s',Sites_{idx_}))
    Sites = Sites_;
    idx = idx_;
    mainZPlot
    %mainZPlotPaper
end



