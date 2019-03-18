clear;

Ib = [];


% Note that the differences between Kelbert 2017 and what is found here for CC
% in Ex for 2003-10-29 through 2003-10-31 is probably due to the fact that
% Ex is clipped in the data from JMA. She must have used different data.
% Her PE table is definitely wrong. PEs should be lower than CC.

%dateo = '20150110';
%datef = '20150116';

%dateo = '20031030';
%datef = '20031031';

%dateo = '20031029';
%datef = '20031031';

%dateo = '20031110';
%datef = '20031118';

%dateo = '20031108';
%datef = '20031113';

%dateo = '20150110';
%datef = '20150116';

dateo = '20031030';
datef = '20031101';
Ib = [];

dateo = '20031202';
datef = '20031222';
Ib = [1.487153e+06:1.488627e+06];
%datef = '20031231';

dateo = '20041202';
datef = '20041231';
IbE = [1.668208e+06:1.670850e+06];
IbB = [];


% Matches Fujii
dateo = '20051202';
datef = '20051226';
IbE = [1051358:1052475,1570893:1571885];
IbB = [1389888:1390322];


dateo = '20060302';
datef = '20060331';
IbE = [1.663546e+06:1.664708e+06];
IbB = [];


dateo = '20060502';
datef = '20060530';
IbE = [];
IbB = [];

% Does not match Fujii
dateo = '20060106';
datef = '20060131';
IbE = [457658:457682,871643:872792];
IbB = [957879:958349,881469:888762];

% Does not match Fujii
% Consider this interval leaving spike in. Here robust full fails, but
% stack is better.
dateo = '20060203';
datef = '20060228';
IbE = [9.64944e+05:9.66299e+05];
IbB = [];

dateo = '20060403';
datef = '20060430';
IbE = [882227:882233,1323746:1324585,1402202:1403151];
IbB = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts = main_options(1);
prepdirs(dateo,opts.filestr);

regen = 0;
site = 'mmb';
remote = 'kak';

if strcmp(site,'mmb')
    [tE,E,tB,B] = prep_EB(dateo,datef,'mmb',regen);
    %[tEr,Er,tBr,Br] = prep_EB(dateo,datef,'kak',regen);
else
    [tE,E,tB,B] = prep_EB(dateo,datef,'kak',regen);
    %[tEr,Er,tBr,Br] = prep_EB(dateo,datef,'mmb',regen);
end

if ~isempty(IbB)
    B(IbB,:) = NaN;
    Ig = setdiff([1:size(B,1)],IbB);
    for i = 1:size(B,2)
        B(:,i) = interp1(tB(Ig),B(Ig,i),tB);
    end
end

if ~isempty(IbE)
    E(IbE,:) = NaN;
    Ig = setdiff([1:size(E,1)],IbE);
    for i = 1:size(E,2)
        E(:,i) = interp1(tE(Ig),E(Ig,i),tE);
    end
end

if 0
    figure(1);clf;
        plot(B);
        zoom off;
        hB = zoom(gca);
        hB.ActionPreCallback = @(obj,evd) fprintf('');
        hB.ActionPostCallback = @(obj,evd) fprintf('Showing B([%d:%d],:)\n',round(evd.Axes.XLim));
    figure(2);clf;
        plot(E);
        zoom off;
        hB = zoom(gca);
        hB.ActionPreCallback = @(obj,evd) fprintf('');
        hB.ActionPostCallback = @(obj,evd) fprintf('Showing E([%d:%d],:)\n',round(evd.Axes.XLim));

    keyboard
end

t = tE;
tGIC = tE;
GIC = E;

[GIC,E,B] = removemean(GIC,E,B);

opts.td.window.width = 86400;
opts.td.window.shift = 86400;

opts.fd.regression.method = 1;
methods{1} = 'OLS';
Sc{1} = transferfnFD(B(:,1:2,1),E,opts);
    Sa{1} = transferfnAverage(Sc{1},opts);
    transferfnSummary(Sc{1},Sa{1},methods{1});

    Z{1} = Sa{1}.Mean.Z;
    fe{1} = Sa{1}.Mean.fe;

opts.fd.regression.method = 3;
methods{2} = 'Robust';
Sc{2} = transferfnFD(B(:,1:2,1),E,opts);
    Sa{2} = transferfnAverage(Sc{2},opts);
    transferfnSummary(Sc{2},Sa{2},methods{2});
    Z{2} = Sa{2}.Mean.Z;
    fe{2} = Sa{2}.Mean.fe;

methods{3} = 'No Stack';
Sc{3} = transferfnFD2(Sc{2},opts);
    Z{3} = Sc{3}.OLS.Z;
    fe{3} = Sc{3}.OLS.fe;
    methods{3} = 'OLS No Stack';
    
    Z{4} = Sc{3}.Robust2.Z;
    fe{4} = Sc{3}.Robust2.fe;
    methods{4} = 'Robust No Stack';

methods{5} = 'Fujii et al. 2015';    
Sc{5} = transferfnFuji(Sc{1},site,opts);
    fe{5} = Sc{5}.fe;
    Z{5}  = Sc{5}.Z;


Np = 0;
Ezp = [zeros(86400*Np,2);E;zeros(86400*Np,2)];
Bzp = [zeros(86400*Np,3);B;zeros(86400*Np,3)];
I = [1:size(Bzp,1)];
opts.td.window.width = length(I);
opts.td.window.shift = length(I);
opts.fd.regression.method = 3;
%tE = [tE(1)-5:1/86400:tE(end)+5];

if 0
    w = parzenwin(length(I));
    for i = 1:2
        Ezp(:,i) = w.*Ezp(:,i);
        Bzp(:,i) = w.*Bzp(:,i);
    end
end

opts.description = 'Parzen window in FD';
opts.fd.window.function = @parzenwin; 
opts.fd.window.functionstr = 'parzen';

Sc{6} = transferfnFD(Bzp(I,1:2,1),Ezp(I,:),opts);
    fe{6} = Sc{6}.fe;
    Z{6} = Sc{6}.Z;
    methods{6} = 'Robust Full + Parzen';
Sc{6} = transferfnMetrics(Sc{1}.In,Sc{1}.Out,fe{6},Z{6},opts);

a = 600;
b = size(B,1)-600;

[N,xfe] = smoothSpectra(E(a:b,:));

for i = 1:length(Z)
    I = find(fe{i}(2:end) >= fe{1}(2) & fe{i}(2:end) <= fe{1}(end));
    I = I+1;
    I = [1;I(1)-1;I];
    fer{i} = fe{i}(I);
    Zr{i} = Z{i}(I,:);
    Ep{i} = Zpredict(fe{i}(I),Z{i}(I,:),B(:,1:2));
    SN{i} = N./smoothSpectra(E(a:b,:)-Ep{i}(a:b,:));
end

comp = ['x','y'];
for i = 1:length(Ep)
    M{i}(1,:) = pe(E(a:b,:),Ep{i}(a:b,:));
    M{i}(2,:) = cc(E(a:b,:),Ep{i}(a:b,:));
    M{i}(3,:) = mse(E(a:b,:),Ep{i}(a:b,:));
    for j = 1:2
        LL{i,j} = sprintf('%s PE/CC/MSE = %.2f/%.2f/%.2f',methods{i},M{i}(:,j)'); 
        fprintf('%s %s\n',comp(j),LL{i,j});
    end
end

S = struct();
S.OLS = Sa{1}.Mean;
S.Robust = Sa{2}.Mean;
S.OLS_No_Stack = Sc{3}.OLS;
S.Robust_No_Stack = Sc{3}.Robust2;
S.Fujii = Sc{5};
S.OLS_Full = Sc{6};
transferfnSummary(Sc{1},S,'');

keys = fieldnames(S);
for k = 1:length(keys)
    SNx{k} = mean(S.(keys{k}).SN,3);
    fex{k} = Sa{1}.Mean.fe;
end


% In case prep_EB does not return data over full time range requested.
dateo = datestr(tE(1),'yyyymmdd');
datef = datestr(tE(end),'yyyymmdd');

%c = {[255/255,168/255,0],'r','b','g','m','c','k'};
components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};

figprep(1,1200,1200);
figure(1);clf;
for i = 1:4
    subplot(2,2,i)
    for m = 1:length(Z)
        loglog(1./fe{m}(2:end),abs(Z{m}(2:end,i)),...
              'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',25-3*m);
        hold on;grid on;
        lstr{m} = sprintf('%s %s',components{i},methods{m});
    end
    title(sprintf('%s %s; %s-%s',upper(site),components{i},dateo,datef),'FontWeight','normal');
    legend(lstr,'Location','Best');
    xlabel('Period [s]');
    ylabel('[(mV/km)/nT]');
end
%figsave(sprintf('figures/%s-Z-%s-%s.pdf',upper(site),dateo,datef));

t = tE;

m1 = 2;
m2 = 6;

figprep(1,800,1000);
figure(2);clf;
subplot(4,1,1);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1),'k');
    plot(t(a:b),Ep{m1}(a:b,1),'b');
    plot(t(a:b),Ep{m2}(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x');
    ylabel('mV/m');    
    legend('$E_x$ Measured',methods{m1},methods{m2},'Location','Best');        
    title(sprintf('%s',upper(site)),'FontWeight','normal');
    hx = zoom(gca);
    hx.ActionPreCallback = @(obj,evd) fprintf('');
    hx.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,2);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1)-Ep{m1}(a:b,1),'b');
    plot(t(a:b),E(a:b,1)-Ep{m2}(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_x$ Prediction Error','VerticalAlignment','top');
    legend(LL{m1,1},LL{m2,1},'Location','Best');    
subplot(4,1,3);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2),'k');
    plot(t(a:b),Ep{m1}(a:b,2),'b');
    plot(t(a:b),Ep{m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x')    
    ylabel('mV/m');
    legend('$E_y$ Measured',methods{m1},methods{m2},'Location','Best');        
    hy = zoom(gca);
    hy.ActionPreCallback = @(obj,evd) fprintf('');
    hy.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,4);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2)-Ep{m1}(a:b,2),'b');
    plot(t(a:b),E(a:b,2)-Ep{m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_y$ Prediction Error','VerticalAlignment','top');
    xl = cellstr(get(gca,'XTickLabel'));
    xl{1} = [xl{1},'/',dateo(1:4)];
    set(gca,'XTickLabel',xl);
    legend(LL{m1,2},LL{m2,2},'Location','Best');    

%figsave(sprintf('figures/%s-Predictions-%s-%s.pdf',upper(site),dateo,datef));

figure(3);clf;
    subplot(2,1,1)
        for i = 1:length(SN)
            loglog(1./xfe(2:end),SN{i}(2:end,1),'LineWidth',2);
            grid on; hold on;
        end
        ylabel('SN for $E_x$')
        legend(methods);        
    subplot(2,1,2)
        for i = 1:length(SN)
            loglog(1./xfe(2:end),SN{i}(2:end,2),'LineWidth',2);
            grid on; hold on;
        end
        ylabel('SN for $E_y$')
        legend(methods,'Location','Best');        

figure(4);clf;
    subplot(2,1,1)
        for i = 1:length(keys)
            loglog(1./fex{i}(2:end),SNx{i}(2:end,1),'LineWidth',2);
            grid on; hold on;
        end
        ylabel('SN for $E_x$')
        legend(methods,'Location','Best');        
    subplot(2,1,2)
        for i = 1:length(keys)
            loglog(1./fex{i}(2:end),SNx{i}(2:end,2),'LineWidth',2);
            grid on; hold on;
        end
        ylabel('SN for $E_y$')
        legend(methods,'Location','Best');        

    
    
