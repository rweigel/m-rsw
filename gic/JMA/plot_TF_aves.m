function plot_TF_aves(png,filestr)

dirfig = sprintf('figures/combined');
if ~exist(dirfig,'dir')
    mkdir(dirfig);
end

fprintf('plot_TF_aves: Loading from mat/compute_TF_aves.mat\n');
File = load('mat/compute_TF_aves.mat');

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

%genZplots(File.EB,titleEB)
%genZplots(File.GE,titleGE)
%genZplots(File.GB,titleGB)
fn = 0;
compareZplots(File.GE,File.GB);
compareHplots(File.GE,File.GB);
comparePhiplots(File.GE,File.GB);

function errorbars(x,y,yl,yu,scale)

    if nargin < 5
        scale = 'linear';
    end
    if nargin == 4 && isa(yu,'char')
        scale = yu;
        yu = yl;
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

function comparePhiplots(GE,GB)
    
    fn=fn+1;figure(fn);clf;box on;          
        semilogx(1./GE.fe(2:end),GE.Phi_Mean(2:end,3),'ro');
        hold on;grid on;  
        semilogx(1./GE.fe(2:end),GE.Phi_Mean(2:end,4),'r.','MarkerSize',20);
        semilogx(1./GB.fe(2:end),GB.Phi_Mean(2:end,3),'bo');
        semilogx(1./GB.fe(2:end),GB.Phi_Mean(2:end,4),'b.','MarkerSize',20);
        set(gca,'ytick',[-210:30:210])
        %errorbars(1./GE.fe(2:end),sf*GE.Phi_Mean(2:end,3),sf*GE.Phi_Standard_Error(2:end,3),'linear');
        %errorbars(1./GE.fe(2:end),sf*GE.Phi_Mean(2:end,4),sf*GE.Phi_Standard_Error(2:end,4),'linear');
        %errorbars(1./GE.fe(2:end),sf*GB.Phi_Mean(2:end,3),sf*GB.Phi_Standard_Error(2:end,3),'linear');
        %errorbars(1./GE.fe(2:end),sf*GB.Phi_Mean(2:end,4),sf*GB.Phi_Standard_Error(2:end,4),'linear');
        set(gca,'ytick',[-180:30:180])
        ylim([-180,180])
        lh = legend(...
                sprintf('$\\phi_{a}$'),...
                sprintf('$\\phi_{b}$'),...    
                sprintf('$\\phi_{Zx}$'),...
                sprintf('$\\phi_{Zy}$'),...    
                'Location','Best');
        set(lh,'interpreter','latex')

        th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
        set(th,'interpreter','latex','fontweight','normal')

        xlabel('Period [s]');
        ylabel('[degrees]');
        if png,print('-dpng',sprintf('%s/plot_TF_aves_GE_GB_Phi-%s.png',dirfig,filestr));end

end

function compareHplots(GE,GB)

    fn=fn+1;figure(fn);clf;box on;grid on;hold on;
        n = (size(GE.H_Mean,1)-1)/2;
        t = [-n:n]';
        sf = 1e3;
        plot(t,sf*GE.H_Mean(:,3),'r--','LineWidth',2);
        plot(t,sf*GE.H_Mean(:,4),'r','LineWidth',2);
        plot(t,sf*GB.H_Mean(:,3),'b','LineWidth',2);
        plot(t,sf*GB.H_Mean(:,4),'b--','LineWidth',2);
        xlabel('Time [s]');
        tlims = [-40 100];
        xlim(tlims);
        I = find(t >= tlims(1) & t <= tlims(2));
        errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Standard_Error(I,3));
        %errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Mean_Standard_Error_Lower(I,3),sf*GE.H_Mean_Standard_Error_Upper(I,3));

        errorbars(t(I),sf*GE.H_Mean(I,4),sf*GE.H_Standard_Error(I,4));
        errorbars(t(I),sf*GB.H_Mean(I,3),sf*GB.H_Standard_Error(I,3));
        errorbars(t(I),sf*GB.H_Mean(I,4),sf*GB.H_Standard_Error(I,4));
        
        lh = legend(...
                sprintf('$a(\\tau) = IFT(A(\\omega))$ [mA/(mV/km)]'),...
                sprintf('$b(\\tau) = IFT(B(\\omega))$ [mA/(mV/km)]'),...    
                sprintf('$H_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
                sprintf('$H_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex')

        th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
        set(th,'interpreter','latex','fontweight','normal')
        if png,print('-dpng',sprintf('%s/plot_TF_aves_GE_GB_H-%s.png',dirfig,filestr));end


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
        errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_Standard_Error(I,3),'semilogx');
        errorbars(t(I),sf*GE.H_Mean(I,4),sf*GE.H_Standard_Error(I,4),'semilogx');
        errorbars(t(I),sf*GB.H_Mean(I,3),sf*GB.H_Standard_Error(I,3),'semilogx');
        errorbars(t(I),sf*GB.H_Mean(I,4),sf*GB.H_Standard_Error(I,4),'semilogx');
        
        lh = legend(...
                sprintf('$a(\\tau) = IFT(A(\\omega))$ [mA/(mV/km)]'),...
                sprintf('$b(\\tau) = IFT(B(\\omega))$ [mA/(mV/km)]'),...    
                sprintf('$H_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
                sprintf('$H_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex')

        th = title(sprintf('%s $\\qquad\\quad$ %s',GE.title,GB.title));
        set(th,'interpreter','latex','fontweight','normal')

        if png,print('-dpng',sprintf('%s/plot_TF_aves_GE_GB_Hzoom-%s.png',dirfig,filestr));end

end

function compareZplots(GE,GB)

    fn=fn+1;figure(fn);clf;box on;          
        sf = 1e3;
        %sf = 1;
        loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),'r--','LineWidth',2);
        hold on;grid on;  
        loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),'r','LineWidth',2);
        loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,3),'b--','LineWidth',2);
        loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,4),'b','LineWidth',2);
        errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),sf*GE.Zabs_Standard_Error(2:end,3),'loglog');
        %errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),sf*GE.Zabs_Mean_Standard_Error_Lower(2:end,3),sf*GE.Zabs_Mean_Standard_Error_Upper(2:end,3),'loglog');

        errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),sf*GE.Zabs_Standard_Error(2:end,4),'loglog');
        errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,3),sf*GB.Zabs_Standard_Error(2:end,3),'loglog');
        errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,4),sf*GB.Zabs_Standard_Error(2:end,4),'loglog');

        lh = legend(...
                sprintf('$|A(\\omega)|$ [mA/(mV/km)]'),...
                sprintf('$|B(\\omega)|$ [mA/(mV/km)]'),...    
                sprintf('$|Z_x(\\omega)|$ [mA/nT]'),...
                sprintf('$|Z_y(\\omega)|$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex');
        th = title(sprintf('%s and %s',GE.title,GB.title));
        set(th,'interpreter','latex','fontweight','normal')
        xlabel('Period [s]');
        if png,print('-dpng',sprintf('%s/plot_TF_aves_GE_GB_Z-%s.png',dirfig,filestr));end

end


function genZplots(S,titlestr)
    
    fn = 0;

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

    for i = 1:size(S.Z,2)
        fn=fn+1;figure(fn);clf;box on;grid on;    
            loglog(1./S.fe(2:end),4*pi*S.Zabs_Mean(2:end,i),'k','LineWidth',2);
            hold on;
            loglog(1./S.fe(2:end),4*pi*squeeze(abs(S.Z(2:end,i,:))))
            loglog(1./S.fe(2:end),4*pi*S.Zabs_Mean(2:end,i),'k','LineWidth',2);
            
            legend(sprintf('median(|Z_{%s}|)',components{i}));
            xlabel('Period [s]');
            ylabel('V/A');
            title(titlestr,'interpreter','latex')
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
