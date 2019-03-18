function f = summaryPlots()
    f = struct();
    
    function compareHplots(GEo,GE,GB,filestr,png)

        figure();clf;box on;grid on;hold on;

        n = (size(GE.H,1)-1)/2;
        t = [-n:n]';
        sf = 1e3;

        tlims = [-40 60];
        I = find(t >= tlims(1) & t <= tlims(2));

        plot(0,sf*GEo.ao(2)/10,'k.','MarkerSize',25);
        plot(0,sf*GEo.bo(2)/10,'ko','MarkerSize',8);

        plot(t(I),sf*GE.H(I,3),'r','LineWidth',2);
        plot(t(I),sf*GE.H(I,4),'r--','LineWidth',2);

        plot(t(I),sf*GB.H(I,3),'b','LineWidth',2);
        plot(t(I),sf*GB.H(I,4),'b--','LineWidth',2);

        errorbars(t(I),sf*GE.H(I,3),sf*GE.H_StdErr(I,3),sf*GE.H_StdErr(I,3),'y','r');
        errorbars(t(I),sf*GE.H(I,4),sf*GE.H_StdErr(I,4),sf*GE.H_StdErr(I,4),'y','r');
        errorbars(t(I),sf*GB.H(I,3),sf*GB.H_StdErr(I,3),sf*GB.H_StdErr(I,3),'y','b');
        errorbars(t(I),sf*GB.H(I,4),sf*GB.H_StdErr(I,4),sf*GB.H_StdErr(I,4),'y','b');

        % Plot again so on top
        plot(0,sf*GEo.ao(2)/10,'k.','MarkerSize',25);
        plot(0,sf*GEo.bo(2)/10,'ko','MarkerSize',8);

        lh = legend(...
                '($\overline{a}_o$ [A/(V/km)])/10',...
                sprintf('($\\overline{b}_o$ [A/(V/km)])/10'),...    
                sprintf('$h_a(\\tau) = IFT(a(\\omega))$ [A/(V/km)]'),...
                sprintf('$h_b(\\tau) = IFT(b(\\omega))$ [A/(V/km)]'),...    
                sprintf('$h_x(\\tau) = IFT(z_x(\\omega))$ [mA/nT]'),...
                sprintf('$h_y(\\tau) = IFT(z_y(\\omega))$ [mA/nT]'),...    
                'Location','Best');
        set(lh,'interpreter','latex')
        xlabel('Time [s]');

        if png
            figsave(sprintf('figures/combined/plot_model_summary_H-%s.pdf',filestr));
        end

    end
    f.compareHplots = @compareHplots;

    function compareZplots(GEo,GE,GB,GBa,filestr,png)

        figure();clf;box on;          

        sf = 1e3;
        loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.ao(2)),length(GE.fe(2:end)),1),'k');
        hold on;grid on;
        loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.bo(2)),length(GE.fe(2:end)),1),'k--');        

        loglog(1./GE.fe(2:end),sf*GE.Zabs(2:end,3),'r','LineWidth',2);
        loglog(1./GE.fe(2:end),sf*GE.Zabs(2:end,4),'r--','LineWidth',2);
        loglog(1./GB.fe(2:end),sf*GB.Zabs(2:end,3),'b--','LineWidth',2);
        loglog(1./GB.fe(2:end),sf*GB.Zabs(2:end,4),'b','LineWidth',2);

        %loglog(1./GE.fe(2:end),GE.Zabs(2:end,4)./GE.Zabs(2:end,3),'k');

        errorbars(1./GE.fe(2:end),sf*GE.Zabs(2:end,3),sf*GE.Zabs_StdErr(2:end,3),sf*GE.Zabs_StdErr(2:end,3),'y','r');
        errorbars(1./GE.fe(2:end),sf*GE.Zabs(2:end,4),sf*GE.Zabs_StdErr(2:end,4),sf*GE.Zabs_StdErr(2:end,4),'y','r');    
        errorbars(1./GE.fe(2:end),sf*GB.Zabs(2:end,3),sf*GB.Zabs_StdErr(2:end,3),sf*GB.Zabs_StdErr(2:end,3),'y','b');
        errorbars(1./GE.fe(2:end),sf*GB.Zabs(2:end,4),sf*GB.Zabs_StdErr(2:end,4),sf*GB.Zabs_StdErr(2:end,4),'y','b');
        yl = get(gca,'YLim');
        yl(1) = 1;
        yl(2) = 300;
        set(gca,'YLim',yl);
        vlines(1./GE.fe(2));
        lh = legend(...
                sprintf('$|\\overline{a}_o|$ [A/(V/km)]'),...
                sprintf('$|\\overline{b}_o|$ [A/(V/km)]'),...    
                sprintf('$|a(\\omega)|$ [A/(V/km)]'),...
                sprintf('$|b(\\omega)|$ [A/(V/km)]'),...    
                sprintf('$|z_x(\\omega)|$ [mA/nT]'),...
                sprintf('$|z_y(\\omega)|$ [mA/nT]'),...
                'Location','NorthWest');
        set(lh,'interpreter','latex');
        xlabel('Period [s]');
        exponent_relabel(gca,'x');

        if png
            figsave(sprintf('figures/combined/plot_model_summary_Z-%s.pdf',filestr));
        end

    end
    f.compareZplots = @compareZplots;


    function comparePhiplots(GE,GB,filestr,png)

        figure();clf;    

        sf = 180/pi;
        T = 1./GE.fe(2:end);

        semilogx(T,0*ones(size(T)),'k.','MarkerSize',20);
        hold on;box on;grid on;
        semilogx(T,180*ones(size(T)),'ko','MarkerSize',5);

        semilogx(T,sf*GE.Phi2(2:end,3),'r.','MarkerSize',20);
        semilogx(T,sf*GE.Phi2(2:end,4),'ro');
        semilogx(T,sf*GB.Phi2(2:end,3),'b.','MarkerSize',20);
        semilogx(T,sf*GB.Phi2(2:end,4),'bo');

        errorbars(T,sf*GE.Phi2(2:end,3),sf*GE.Phi_StdErr(2:end,3),sf*GE.Phi_StdErr(2:end,3),'y','r');
        errorbars(T,sf*GE.Phi2(2:end,4),sf*GE.Phi_StdErr(2:end,4),sf*GE.Phi_StdErr(2:end,4),'y','r');
        errorbars(T,sf*GB.Phi2(2:end,3),sf*GB.Phi_StdErr(2:end,3),sf*GB.Phi_StdErr(2:end,3),'y','b');
        errorbars(T,sf*GB.Phi2(2:end,4),sf*GB.Phi_StdErr(2:end,4),sf*GB.Phi_StdErr(2:end,4),'y','b');

        set(gca,'ytick',[-180:30:180])
        ylim([-210,210])
        vlines(1./GE.fe(2));
        exponent_relabel(gca,'x');

        lh = legend(...
                sprintf('$\\phi_{ao}$'),...
                sprintf('$\\phi_{bo}$'),...    
                sprintf('$\\phi_{a}$'),...
                sprintf('$\\phi_{b}$'),...    
                    sprintf('$\\phi_{zx}$'),...
                    sprintf('$\\phi_{zy}$'),...    
                'Location','Best');
        set(lh,'interpreter','latex')
        xlabel('Period [s]');
        ylabel('[degrees]');

        if png
            figsave(sprintf('figures/combined/plot_model_summary_Phi-%s.pdf',filestr));
        end

    end
    f.comparePhiplots = @comparePhiplots;

    
    function compareSN2(GEo,GE,GB,GBa,titlestr,filestr,png)

        figure();clf;
        T = 1./GB.fe;

        GEo_SNm = mean(GEo.SN,3);
        GE_SNm  = mean(GE.SN,3);
        GBa_SNm = mean(GBa.SN,3);
        GB_SNm  = mean(GB.SN,3);

        loglog(T,GEo_SNm(:,2),'k','Marker','.','MarkerSize',2,'LineWidth',2);
        hold on;grid on;
        loglog(T,GE_SNm(:,2),'r','Marker','.','MarkerSize',2,'LineWidth',2);
        loglog(T,GBa_SNm(:,2),'g','Marker','.','MarkerSize',2,'LineWidth',2)
        loglog(T,GB_SNm(:,2),'b','Marker','.','MarkerSize',2,'LineWidth',2);

        ye = boot(squeeze(GEo.SN(:,2,:))',@mean,1000,159);
        errorbars(T,GEo_SNm(:,2),GEo_SNm(:,2)-ye(:,1),ye(:,2)-GEo_SNm(:,2),'y','k');

        ye = boot(squeeze(GE.SN(:,2,:))',@mean,1000,159);
        errorbars(T,GE_SNm(:,2),GE_SNm(:,2)-ye(:,1),ye(:,2)-GE_SNm(:,2),'y','r');

        ye = boot(squeeze(GBa.SN(:,2,:))',@mean,1000,159);
        errorbars(T,GBa_SNm(:,2),GBa_SNm(:,2)-ye(:,1),ye(:,2)-GBa_SNm(:,2),'y','g');

        ye = boot(squeeze(GB.SN(:,2,:))',@mean,1000,159);
        errorbars(T,GB_SNm(:,2),GB_SNm(:,2)-ye(:,1),ye(:,2)-GB_SNm(:,2),'y','b');        

        ylabel('Signal to Noise');
        vlines(1/GE.fe(2))

        set(gca,'YLim',[0.099,40.1]);        
        title(titlestr);
        legend('Model 1','Model 2','Model 3','Model 4','Location','NorthWest');
        
        xlabel('Period [s]');
        exponent_relabel(gca);
        
        if png
            figsave(sprintf('figures/combined/plot_model_summary_SN-%s.pdf',filestr));
        end
    end    
    f.compareSN2 = @compareSN2;
    
end