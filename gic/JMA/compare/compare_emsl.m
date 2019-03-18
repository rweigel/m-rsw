clear

Xo = load('emslab/emsl01.csv');
rhoxy = load('emslab/Jones_1989_Method-2-Figure-5-rho_xy.dat');
rhoyx = load('emslab/Jones_1989_Method-2-Figure-5-rho_yx.dat');
Txy = 10.^(1.5*rhoxy(:,1)+1);
Tyx = 10.^(1.5*rhoyx(:,1)+1);
rho(:,2) = 10.^(rhoxy(:,2)+1);
rho(:,3) = 10.^(rhoyx(:,2)+1);
%rho(:,1) = NaN*rho(:,1);
%rho(:,4) = rho(:,1);


t = [1:size(Xo,1)]';

for i = 1:size(Xo,2)
    I = find(Xo(:,i) ~= -9999);
    X(:,i) = interp1(t(I),Xo(I,i),t);
    fprintf('%d NaN values in column %d\n',length(t)-length(I),i);
    N = find(~isnan(X(:,i)));
    a(i) = N(1);
    b(i) = N(end);
end

%plot(X)

%a = 3*60*24*(datenum('1985-09-02')-datenum('1985-07-18'));
%b = 3*60*24*(datenum('1985-09-06')-datenum('1985-07-18'));

% Active Interval
a = 3*60*24*(datenum('1985-09-13')-datenum('1985-07-18'));
b = 3*60*24*(datenum('1985-09-17')-datenum('1985-07-18'));

t = [1:size(X,1)]';
dn = datenum(1985,7,18) + t/(3*60*24);
%ta = block_mean_nonflag(dn,6*60);
%Xa = block_mean_nonflag(X,6*60);

%plot(dn(a:b),X(a:b,3))
%datetick('x','yyyy-mm-dd');

addpath('..');
opts = main_options(1);
opts.td.window.width = 86400/20;
opts.td.window.shift = 86400/20;

for i = 1:size(X,2)
    X(a:b,i) = X(a:b,i)-mean(X(a:b,i));
end
Sc{1} = transferfnFD(X(a:b,1:2),X(a:b,4:5),opts);


for i = 2:size(Sc{1}.In_FT,1) % Loop over evaluation frequencies
    for j = 1:2 % Loop over outputs (Ex and Ey)
        cols = [1,2];
        if j == 2
            cols = [3,4];
        end
        x = Sc{1}.In_FT{i,j,1};
        y = Sc{1}.Out_FT{i,j,1};
        for k = 2:size(Sc{1}.In_FT,3) % Loop over days
            xk = Sc{1}.In_FT{i,j,k};
            yk = Sc{1}.Out_FT{i,j,k};
            x = cat(1,x,xk);
            y = cat(1,y,yk);
        end
        
        % x/y now has all input/output FTs
        Zols1(i,cols) = x\y;
        Zols2(i,cols) = (ctranspose(x)*x)^(-1)*ctranspose(x)*y;
        Zols3(i,cols) = regress(y,x);
        %Zrob(i,cols)  = robustfit(x,y,'bisquare',[],'off');
    end
end

site = 'EMSL01';
opts.td.Ntrim = 1;
Sa{1} = transferfnAverage(Sc{1},opts);



components = {'$\rho_{xx}$','$\rho_{xy}$','$\rho_{yx}$','$\rho_{yy}$'};
figprep(1,1000,800);
c = {[255/255,168/255,0],'r','b','g'};

Txy = 10.^(1.5*rhoxy(:,1)+1);
Tyx = 10.^(1.5*rhoyx(:,1)+1);

methods = {'OLS Stack','OLS','Method 2 Jones et al. 1989'};
figure();
sf = 0.2;
for i = 1:4
    subplot(2,2,i)
    for m = 1:length(Sc)
        T = 20./Sa{m}.Mean.fe(2:end);
        loglog(T,sf*T.*abs(Sa{m}.Mean.Z(2:end,i)).^2,...
                 'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        if m == 1
            hold on;grid on;
        end
        loglog(T,sf*T.*abs(Zols3(2:end,i)).^2,...
                 'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20); 
        if i == 2 || i == 3
            loglog(Txy,rho(:,i),...
                 'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);                 
        end
        title=components{i};
    end
    %title(sprintf('Site: %s; Data Interval: %s-%s',upper(site),dateo,datef),'FontWeight','normal');
    legend(methods,'Location','Best');
    xlabel('Period');
    ylabel('[(mV/km)/nT]');
end

%figsave(sprintf('figures/%s-%s-%s.pdf',upper(site),dateo,datef));
