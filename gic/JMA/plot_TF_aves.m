function plot_TF_aves(png,filestr)

dirfig = sprintf('figures/combined');
if ~exist(dirfig,'dir')
    mkdir(dirfig);
end

orient portrait;

if png == 0
    set(0,'DefaultFigureWindowStyle','docked');
end

file = sprintf('mat/compute_TF_aves-%s.mat',filestr);
fprintf('plot_TF_aves: Loading from %s\n',file);
File = load(file);

fn = 0;

if png == 1
    % Open each figure in new window
    set(0,'DefaultFigureWindowStyle','normal');
else
    % Dock figure windows
    set(0,'DefaultFigureWindowStyle','docked');
end

File.EB.title = '$\mathbf{E} = \mathcal{Z}\mathbf{B}$; E in mV/m, B in nT';
File.GE.title = '$G_B(\omega) = A(\omega)E_{x}(\omega) + B(\omega)E_{y}$';
File.GB.title = '$G_E(\omega) = Z_x(\omega)B_{x}(\omega) + Z_y(\omega)B_{y}$';

if png
    %set(0,'DefaultAxesFontSize',10);
end

signaltonoise(File.GE,File.GB);
return
mtZplots(File.EB);
mtrhoplots(File.EB);
mtphiplots(File.EB);

%errorhistograms(File.GE);
genZplots(File.EB);

parameterhistograms(File.GE);
compareHplots(File.GE,File.GB);
compareZplots(File.GE,File.GB);
comparePhiplots(File.GE,File.GB);    

function signaltonoise(GE,GB)
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,squeeze(GE.Output_PSD_Mean(:,1,:)./GE.Erroro_PSD_Mean(:,1,:)),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,squeeze(GE.Output_PSD_Mean(:,2,:)./GE.Error_PSD_Mean(:,2,:)),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,squeeze(GB.Output_PSD_Mean(:,2,:)./GB.Error_PSD_Mean(:,2,:)),...
                'Marker','.','MarkerSize',20,'LineWidth',2)
        loglog(1./GB.fe,squeeze(GB.Output_PSD_Mean(:,2,:)./GB.Error_Alt_PSD_Mean(:,2,:)),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        grid on;
        title('Signal to noise');
        legend('Model 1','Model 2','Model 3','Model 4','Location','Best');
        xlabel('Period [s]');
end

function errorhistograms(GE)

    File2 = load('mat/aggregate_TFs.mat');
    
    p = 90; % percentile
    pv = prctile(abs(File2.IO.GIC(:,2)),p); % percentile value

    Po = GE.Predictiono_Mean(:);
    P  = GE.Prediction_Mean(:,2,:);
    P  = P(:);

    fn=fn+1;figure(fn);clf;
        [no,xo] = hist(abs(Po),logspace(-2,1,100));
        loglog(xo,no,'r.','MarkerSize',20);
        hold on;box on;grid on;hold on;

        [n,x] = hist(abs(P),logspace(-2,1,100));
        loglog(x,n,'b.','MarkerSize',20);
        
        fo = length(find(abs(Po)>pv))/length(Po);        
        f = length(find(abs(P)>pv))/length(P);

        ylabel('Fraction in bin')
        xlabel('|GIC| [A]');
        legend('Model 1 predictions','Model 2 predictions')

        fprintf('Percent above |GIC| = %.2f (%dth percentile): Static: %.3f%% Dynamic: %.3f%% Ratio = %.2f\n',...
            pv,p,100*fo,100*f,fo/f);

end
 
function parameterhistograms(GE)

    fn=fn+1;figure(fn);clf;box on;grid on;hold on;

        edgesao = [0:20:180];
        %edgesao = [-300:50:300];
        edgesbo = [-300:50:300];

        [nao,xao] = histc(1e3*GE.aobo(:,1),edgesao);
        [nbo,xbo] = histc(1e3*GE.aobo(:,2),edgesbo);

        edgesao = [edgesao(1),edgesao];
        nao = [0,nao'];
        edgesbo = [edgesbo(1),edgesbo];
        nbo = [0,nbo'];

        stairs(edgesao,nao,'r','LineWidth',2)
        stairs(edgesbo,nbo,'r--','LineWidth',2)

        plot(mean(1e3*GE.aobo(:,1)),0,'r.','MarkerSize',30);
        plot(mean(1e3*GE.aobo(:,2)),0,'ro','MarkerSize',10);

        %bh = bar(edgesao,nao,'histc')
        %set(bh,'FaceAlpha',0.5,'FaceColor','r','EdgeAlpha',0);

        %bh = bar(edgesbo,nbo,'histc')
        %set(bh,'FaceAlpha',0.5,'FaceColor','b','EdgeAlpha',0);

        ylabel('Count');
        xlabel('A/(V/km)');
        [lh,lo] = legend('a_o','b_o');
        if png
            set(gcf, 'Position', [0 0 1000 500])
            export_fig(sprintf('%s/plot_TF_aves_aobo_histograms-%s.pdf',dirfig,filestr),'-transparent');
        end

end

function errorbars(x,y,yl,yu,scale)

    if nargin < 5
        scale = 'linear';
    end
    if nargin == 4 && isa(yu,'char')
        % errorbars(x,y,yl,scale)
        scale = yu;
        yu = yl; % Set yu = yl
    end
    if nargin == 3
        yu = yl;
    end
    if strmatch(scale,'linear','exact')
        for i = 1:length(x)
            plot([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end
    if strmatch(scale,'loglog','exact')    
        for i = 1:length(x)
            loglog([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end
    if strmatch(scale,'semilogx','exact')    
        for i = 1:length(x)
            semilogx([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end    
end

function comparePhiplots(GE,GB,pn)
    
    if nargin == 3
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    

    semilogx(1./GE.fe(2:end),0*GE.Phi_Mean(2:end,3),'r-','MarkerSize',5);
    hold on;box on;
    semilogx(1./GE.fe(2:end),0*GE.Phi_Mean(2:end,4),'r--','MarkerSize',5);

    y = GE.Phi_Mean(2:end,3);
    %y(y<-90) = 360-y(y<-90);
    semilogx(1./GE.fe(2:end),y,'r.','MarkerSize',20);
    hold on;grid on;  

    y = GE.Phi_Mean(2:end,4);
    %y(y<-90) = 360+y(y<-90);
    semilogx(1./GE.fe(2:end),y,'ro');

    semilogx(1./GB.fe(2:end),GB.Phi_Mean(2:end,3),'b.','MarkerSize',20);
    semilogx(1./GB.fe(2:end),GB.Phi_Mean(2:end,4),'bo');
    
    %set(gca,'ytick',[-60:30:210])
    %ylim([-60,210])        

    set(gca,'ytick',[-210:30:210])
    ylim([-210,210])
    %errorbars(1./GE.fe(2:end),sf*GE.Phi_Mean(2:end,3),sf*GE.Phi_Standard_Error(2:end,3),'linear');
    %errorbars(1./GE.fe(2:end),sf*GE.Phi_Mean(2:end,4),sf*GE.Phi_Standard_Error(2:end,4),'linear');
    %errorbars(1./GE.fe(2:end),sf*GB.Phi_Mean(2:end,3),sf*GB.Phi_Standard_Error(2:end,3),'linear');
    %errorbars(1./GE.fe(2:end),sf*GB.Phi_Mean(2:end,4),sf*GB.Phi_Standard_Error(2:end,4),'linear');
    %set(gca,'ytick',[-180:30:180])
    %ylim([-180,180])
    lh = legend(...
            sprintf('$\\phi_{ao}$'),...
            sprintf('$\\phi_{bo}$'),...    
            sprintf('$\\phi_{a}$'),...
            sprintf('$\\phi_{b}$'),...    
                sprintf('$\\phi_{Zx}$'),...
                sprintf('$\\phi_{Zy}$'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    if (0)
        lh = legend(...
                sprintf('$\\phi_{a}$'),...
                sprintf('$\\phi_{b}$'),...    
                sprintf('$\\phi_{Zx}$'),...
                sprintf('$\\phi_{Zy}$'),...    
                'Location','Best');
        set(lh,'interpreter','latex')
    end
    %th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
    %set(th,'interpreter','latex','fontweight','normal')

    xlabel('Period [s]');
    ylabel('[degrees]');
    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_GE_Phi-%s.pdf',dirfig,filestr),'-transparent')
    end

end

function compareHplots(GE,GB,pn)

    if nargin == 3
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    
    box on;grid on;hold on;
    n = (size(GE.H_Mean,1)-1)/2;
    t = [-n:n]';
    sf = 1e3;

    tlims = [-40 100];
    I = find(t >= tlims(1) & t <= tlims(2));


    plot(0,sf*GE.aobo_Mean(1)/10,'r.','MarkerSize',20);
    plot(0,sf*GE.aobo_Mean(2)/10,'ro','MarkerSize',5);

    plot(t(I),sf*GE.H_Mean(I,3),'r','LineWidth',2);
    plot(t(I),sf*GE.H_Mean(I,4),'r--','LineWidth',2);

    %plot(0,sf*GB.aobo_Mean(1),'b.','MarkerSize',20);
    %plot(0,sf*GB.aobo_Mean(2),'bo','MarkerSize',5);

    plot(t(I),sf*GB.H_Mean(I,3),'b','LineWidth',2);
    plot(t(I),sf*GB.H_Mean(I,4),'b--','LineWidth',2);

    %errorbars(0,sf*GE.aobo_Mean(1)/10,sf*GE.aobo_Standard_Error(1)/10)
    %errorbars(0,sf*GE.aobo_Mean(2)/10,sf*GE.aobo_Standard_Error(2)/10)

    errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Standard_Error(I,3));
    %errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Mean_Standard_Error_Lower(I,3),sf*GE.H_Mean_Standard_Error_Upper(I,3));
    errorbars(t(I),sf*GE.H_Mean(I,4),sf*GE.H_Standard_Error(I,4));

    %errorbars(0,sf*GB.aobo_Mean(1),sf*GE.aobo_Standard_Error(1))
    %errorbars(0,sf*GB.aobo_Mean(2),sf*GE.aobo_Standard_Error(2))

    errorbars(t(I),sf*GB.H_Mean(I,3),sf*GB.H_Standard_Error(I,3));
    errorbars(t(I),sf*GB.H_Mean(I,4),sf*GB.H_Standard_Error(I,4));

    xlabel('Time [s]');
    %lim(tlims);

    if (0)
    lh = legend(...
            sprintf('$a(\\tau) = IFT(A(\\omega))$ [A/(V/km)]'),...
            sprintf('$b(\\tau) = IFT(B(\\omega))$ [A/(V/km)]'),...    
            sprintf('$H_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
            sprintf('$H_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    end
    
    if (1)
    lh = legend(...
            '($a_o$ [A/(V/km)])/10',...
            sprintf('($b_o$ [A/(V/km)])/10'),...    
            sprintf('$a(\\tau) = IFT(A(\\omega))$ [A/(V/km)]'),...
            sprintf('$b(\\tau) = IFT(B(\\omega))$ [A/(V/km)]'),...    
            sprintf('$h_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
            sprintf('$h_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    end

    %th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
    %set(th,'interpreter','latex','fontweight','normal')
    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_GE_H-%s.pdf',dirfig,filestr),'-transparent')
    end

    return

    fn=fn+1;figure(fn);clf;box on;
        n = (size(GE.H_Mean,1)-1)/2;
        t = [-n:n]';
        sf = 1e3;
        I = find(t>=10);
        semilogx(t(I),sf*GE.H_Mean(I,3),'r--','LineWidth',2);
        hold on;grid on
        semilogx(t(I),sf*GE.H_Mean(I,4),'r','LineWidth',2);
        semilogx(t(I),sf*GB.H_Mean(I,3),'b','LineWidth',2);
        semilogx(t(I),sf*GB.H_Mean(I,4),'b--','LineWidth',2);
        xlabel('Time [s]');
        tlims = [10 1000];
        xlim(tlims);
        I = find(t >= tlims(1) & t <= tlims(2));
        %errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Standard_Error(I,3),'semilogx');
        %errorbars(t(I),sf*GE.H_Mean(I,4),sf*GE.H_Standard_Error(I,4),'semilogx');
        %errorbars(t(I),sf*GB.H_Mean(I,3),sf*GB.H_Standard_Error(I,3),'semilogx');
        %errorbars(t(I),sf*GB.H_Mean(I,4),sf*GB.H_Standard_Error(I,4),'semilogx');
        
        lh = legend(...
                sprintf('$a(\\tau) = IFT(A(\\omega))$ [A/(V/km)]'),...
                sprintf('$b(\\tau) = IFT(B(\\omega))$ [A/(V/km)]'),...    
                sprintf('$H_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
                sprintf('$H_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex')

        th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
        set(th,'interpreter','latex','fontweight','normal')

        if png,print('-dpng',sprintf('%s/plot_TF_aves_GE_GB_Hzoom-%s.png',dirfig,filestr));end

end

function compareZplots(GE,GB,pn)

    fprintf('ao average = %.1f +/- %.1f [mA/(mV/km)]\n',1e3*GE.aobo_Mean(1),1e3*GE.aobo_Standard_Error(1));
    fprintf('bo average = %.1f +/- %.1f [mA/(mV/km)]\n',1e3*GE.aobo_Mean(2),1e3*GE.aobo_Standard_Error(2));
    cc = corrcoef(GE.aobo(:,1),GE.aobo(:,2));
    fprintf('corr(ao,bo) = %.2f\n',cc(2));
    
    if nargin == 3
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end

    box on;          
    sf = 1e3;
    %sf = 1;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GE.aobo_Mean(1)),length(GE.fe(2:end)),1),'r');
    hold on;grid on;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GE.aobo_Mean(2)),length(GE.fe(2:end)),1),'r--');        

    loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),'r','LineWidth',2);
    
    loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),'r--','LineWidth',2);

    loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,3),'b--','LineWidth',2);
    loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,4),'b','LineWidth',2);

    %loglog(1./GB.fe(2:end),sf*GB.Zabs_Alt_Mean(2:end,3),'k--','LineWidth',2);
    %loglog(1./GB.fe(2:end),sf*GB.Zabs_Alt_Mean(2:end,4),'k','LineWidth',2);
    
    errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),sf*GE.Zabs_Standard_Error(2:end,3),'loglog');
    errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),sf*GE.Zabs_Standard_Error(2:end,4),'loglog');    
    errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,3),sf*GB.Zabs_Standard_Error(2:end,3),'loglog');
    errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,4),sf*GB.Zabs_Standard_Error(2:end,4),'loglog');

    lh = legend(...
            sprintf('$|A_o|$ [A/(V/km)]'),...
            sprintf('$|B_o|$ [A/(V/km)]'),...    
            sprintf('$|A(\\omega)|$ [A/(V/km)]'),...
            sprintf('$|B(\\omega)|$ [A/(V/km)]'),...    
            sprintf('$|Z_x(\\omega)|$ [mA/nT]'),...
            sprintf('$|Z_y(\\omega)|$ [mA/nT]'),...
            'Location','Best');
    set(lh,'interpreter','latex');

    if (0)        
        loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,3),'b--','LineWidth',2);
        loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,4),'b','LineWidth',2);

        errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,3),sf*GB.Zabs_Standard_Error(2:end,3),'loglog');
        errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,4),sf*GB.Zabs_Standard_Error(2:end,4),'loglog');

        lh = legend(...
                sprintf('$|A(\\omega)|$ [A/(V/km)]'),...
                sprintf('$|B(\\omega)|$ [A/(V/km)]'),...    
                sprintf('$|Z_x(\\omega)|$ [mA/nT]'),...
                sprintf('$|Z_y(\\omega)|$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex');
    end

    %th = title(sprintf('%s and %s',GE.title,GB.title));
    %set(th,'interpreter','latex','fontweight','normal')
    xlabel('Period [s]');
    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_GE_Z-%s.pdf',dirfig,filestr),'-transparent')
    end        

end

function genZplots(S)

    components = {'xx','xy','yx','yy'};
        
    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;            
            loglog(1./S.fe(2:end),4*pi*S.Zabs_Mean(2:end,i),'k','LineWidth',2);
            hold on;
            loglog(1./S.fe(2:end),4*pi*S.Zabs_Median(2:end,i),'b','LineWidth',2)
            loglog(1./S.fe(2:end),4*pi*S.Zabs_Huber(2:end,i),'r','LineWidth',2)

            loglog(1./S.fe(2:end),4*pi*abs(S.Z_Mean(2:end,i)),'k--','LineWidth',2)
            loglog(1./S.fe(2:end),4*pi*abs(S.Z_Median(2:end,i)),'b--','LineWidth',2)
            loglog(1./S.fe(2:end),4*pi*abs(S.Z_Huber(2:end,i)),'r--','LineWidth',2)

            legend(...
                    sprintf('mean(|Z_{%s}|)',components{i}),...
                    sprintf('median(|Z_{%s}|)',components{i}),...
                    sprintf('Huber(|Z_{%s}|)',components{i}),...
                    sprintf('|mean(Z_{%s})|',components{i}),...
                    sprintf('|median(Z_{%s})|',components{i}),...
                    sprintf('|Huber(Z_{%s})|',components{i}),...
                    'Location','Best');
            xlabel('Period [s]');
            ylabel('V/A');
            %title(titlestr,'interpreter','latex')
    end

    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_EB_Z-%s.pdf',dirfig,filestr),'-transparent')
    end        
    
%    keyboard
    
    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;
            semilogx(1./S.fe(2:end),S.Phi_Mean(2:end,i),'k','LineWidth',2);
            hold on;
            semilogx(1./S.fe(2:end),S.Phi_Median(2:end,i),'b','LineWidth',2)
            semilogx(1./S.fe(2:end),S.Phi_Huber(2:end,i),'r','LineWidth',2)
            legend(...
                    sprintf('\\phi_{%s} (mean)',components{i}),...
                    sprintf('\\phi_{%s} (median)',components{i}),...
                    sprintf('\\phi_{%s} (Huber)',components{i}),...
                    'Location','Best')
            xlabel('Period [s]');
            ylabel('[degrees]');
            %title(titlestr,'interpreter','latex')

    end

    
end

function mtZplots(S)    
    
    sf = 1e3;
    components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};
    c = ['k','r','b','g'];
    fn=fn+1;figure(fn);clf;
    for i = 1:size(S.Z,2)
        loglog(1./S.fe(2:end),sf*S.Zabs_Mean(2:end,i),c(i),...
            'LineStyle','-','LineWidth',2,'Marker','.','MarkerSize',20);
        hold on;
    end

    for i = 1:size(S.Z,2)
        errorbars(1./S.fe(2:end),sf*S.Zabs_Mean(2:end,i),sf*S.Zabs_Standard_Error(2:end,i),'loglog');
        hold on;
    end

    grid on;
    xlabel('Period [s]');
    ylabel('A/(V/km)');
    lh = legend(components,'Location','best');
    set(lh,'interpreter','latex')
    %title(titlestr,'interpreter','latex')

    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_EB_Z-%s.pdf',dirfig,filestr),'-transparent')
    end        

end

function mtrhoplots(S)    
    
    sf = 0.2;
    components = {'$\rho_{xx}$','$\rho_{xy}$','$\rho_{yx}$','$\rho_{yy}$'};
    c = ['k','r','b','g'];
    fn=fn+1;figure(fn);clf;
    for i = 1:size(S.Z,2)
        loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Mean(2:end,i).^2,c(i),...
            'LineStyle','-','LineWidth',2,'Marker','.','MarkerSize',20);
        hold on;
    end
    lh = legend(components,'Location','Best');
    set(lh,'interpreter','latex');
    xlabel('Period [s]');
    ylabel('V/A');
    grid on;
    %title(titlestr,'interpreter','latex')
    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_EB_rho-%s.pdf',dirfig,filestr),'-transparent')
    end        
    
end

function mtphiplots(S)
    
    c = {'k.','r.','b.','g.'};
    components = {'$\phi_{xx}$','$\phi_{xy}$','$\phi_{yx}$','$\phi_{yy}$'};
    fn=fn+1;figure(fn);clf;
    for i = 1:size(S.Z,2)
        semilogx(1./S.fe(2:end),S.Phi_Mean(2:end,i),c{i},...
            'Marker','.','MarkerSize',20);
        hold on;
    end
    lh = legend(components,'Location','Best');
    set(lh,'interpreter','latex');    
    xlabel('Period [s]');
    ylabel('[degrees]');
    grid on;
    %title(titlestr,'interpreter','latex')
    if png
        set(gcf, 'Position', [0 0 1000 500])
        export_fig(sprintf('%s/plot_TF_aves_EB_phi-%s.pdf',dirfig,filestr),'-transparent')
    end        
    
end
    
function genRhoplots(S,titlestr)
    
    fn = 0;
    sf = 0.2;
    components = {'xx','xy','yx','yy'};
    
    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;            
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Mean(2:end,i).^2,'k','LineWidth',2);
            hold on;
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Median(2:end,i).^2,'b','LineWidth',2)
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Huber(2:end,i).^2,'r','LineWidth',2)

            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*abs(S.Z_Mean(2:end,i)).^2,'k--','LineWidth',2)
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*abs(S.Z_Median(2:end,i)).^2,'b--','LineWidth',2)
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*abs(S.Z_Huber(2:end,i)).^2,'r--','LineWidth',2)

            legend(...
                    sprintf('mean(|\\rho_{%s}|)',components{i}),...
                    sprintf('median(|\\rho_{%s}|)',components{i}),...
                    sprintf('Huber(|\\rho_{%s}|)',components{i}),...
                    sprintf('|mean(\\rho_{%s})|',components{i}),...
                    sprintf('|median(\\rho_{%s})|',components{i}),...
                    sprintf('|Huber(\\rho_{%s})|',components{i}),...
                    'Location','Best');
            xlabel('Period [s]');
            ylabel('$$\Omega\cdot m$$','interpreter','latex');
            title(titlestr,'interpreter','latex')
    end
    
    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;
            semilogx(1./S.fe(2:end),S.Phi_Mean(2:end,i),'k','LineWidth',2);
            hold on;
            semilogx(1./S.fe(2:end),S.Phi_Median(2:end,i),'b','LineWidth',2)
            semilogx(1./S.fe(2:end),S.Phi_Huber(2:end,i),'r','LineWidth',2)
            legend(...
                    sprintf('\\phi_{%s} (mean)',components{i}),...
                    sprintf('\\phi_{%s} (median)',components{i}),...
                    sprintf('\\phi_{%s} (Huber)',components{i}),...
                    'Location','Best')
            xlabel('Period [s]');
            ylabel('[degrees]');
            title(titlestr,'interpreter','latex')
    end

    return;
    
    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;    
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Mean(2:end,i).^2,'k','LineWidth',2);
            hold on;
            F = repmat(sf./S.fe(2:end),1,size(S.Z,3));
            loglog(1./S.fe(2:end),F.*squeeze(abs(S.Z(2:end,i,:))).^2)
            loglog(1./S.fe(2:end),(sf./S.fe(2:end)).*S.Zabs_Mean(2:end,i).^2,'k','LineWidth',2);
            
            legend(sprintf('median(|\\rho_{%s}|)',components{i}));
            xlabel('Period [s]');
            ylabel('$$\Omega\cdot m$$','interpreter','latex');
            title(titlestr,'interpreter','latex')
    end
    
end


end
