
function f = summaryPlotFunctions()
    f = struct();

    fdir = sprintf('figures/summary');
    if ~exist(fdir,'dir')
        mkdir(fdir);
    end
    
    function legendadjust(lh)
        pa = get(gca,'Position');
        p = get(lh,'Position');
        p(1) = pa(1)*1.02;
        p(2) = p(2) + 0.022; % TODO: Use legend height + axis position to move.
        set(lh,'Position',p);
    end

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
            figsave(sprintf('figures/summary/plot_model_summary_H-%s.pdf',filestr));
        end

    end
    f.compareHplots = @compareHplots;

    function compareZplots(GEo,GE,GB,EB,filestr,png)

        figure();clf;box on;          

        loglog(1./EB.fe(2:end),EB.Zabs(2:end,1),'r','LineWidth',2);
        hold on;grid on;
        loglog(1./EB.fe(2:end),EB.Zabs(2:end,2),'r--','LineWidth',2);
        loglog(1./EB.fe(2:end),EB.Zabs(2:end,3),'b--','LineWidth',2);
        loglog(1./EB.fe(2:end),EB.Zabs(2:end,4),'b','LineWidth',2);

        % Multiply x by a fraction so vertical error bars don't exactly
        % overlap.
        errorbars(0.98*1./EB.fe(2:end),EB.Zabs(2:end,1),EB.Zabs_StdErr(2:end,1),EB.Zabs_StdErr(2:end,1),'y','r');
        errorbars(0.99*1./EB.fe(2:end),EB.Zabs(2:end,2),EB.Zabs_StdErr(2:end,2),EB.Zabs_StdErr(2:end,2),'y','r--');    
        errorbars(1./EB.fe(2:end),EB.Zabs(2:end,3),EB.Zabs_StdErr(2:end,3),EB.Zabs_StdErr(2:end,3),'y','b--');
        errorbars(1.01*1./EB.fe(2:end),EB.Zabs(2:end,4),EB.Zabs_StdErr(2:end,4),EB.Zabs_StdErr(2:end,4),'y','b');

        yl = get(gca,'YLim');
        yl(1) = 0.04;
        yl(2) = 2;
        set(gca,'YLim',yl);
        vlines(1./EB.fe(2));
        lh = legend(...
                sprintf('$|Z_{xx}(\\omega)|$'),...
                sprintf('$|Z_{xy}(\\omega)|$'),...
                sprintf('$|Z_{yx}(\\omega)|$'),...
                sprintf('$|Z_{yy}(\\omega)|$'),...
                'Location','NorthWest');
        set(lh,'interpreter','latex');
        xlabel('Period [s]');
        ylabel('[(mV/km)/nT]');
        exponent_relabel(gca,'x');
        exponent_relabel(gca,'y');
        
        legendadjust(lh);

        if png
            figsave(sprintf('figures/summary/plot_model_summary_Z_MT-%s.pdf',filestr));
        end
        
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

        errorbars(0.98*1./GE.fe(2:end),sf*GE.Zabs(2:end,3),sf*GE.Zabs_StdErr(2:end,3),sf*GE.Zabs_StdErr(2:end,3),'y','r');
        errorbars(0.99*1./GE.fe(2:end),sf*GE.Zabs(2:end,4),sf*GE.Zabs_StdErr(2:end,4),sf*GE.Zabs_StdErr(2:end,4),'y','r');    
        errorbars(1./GE.fe(2:end),sf*GB.Zabs(2:end,3),sf*GB.Zabs_StdErr(2:end,3),sf*GB.Zabs_StdErr(2:end,3),'y','b');
        errorbars(1.01*1./GE.fe(2:end),sf*GB.Zabs(2:end,4),sf*GB.Zabs_StdErr(2:end,4),sf*GB.Zabs_StdErr(2:end,4),'y','b');
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
        exponent_relabel(gca,'y');
        
        legendadjust(lh);

        if png
            figsave(sprintf('figures/summary/plot_model_summary_Z-%s.pdf',filestr));
        end

    end
    f.compareZplots = @compareZplots;

    function comparePhiplots(GE,GB,EB,filestr,png)

        figure();clf;box on;    

        sf = 180/pi;
        T = 1./GE.fe(2:end);

        % Manually unwrap certain parts
        In = find(EB.Phi2(:,1) < 0);
        EB.Phi2(In,1) = EB.Phi2(In,1)+2*pi;
        semilogx(T,sf*EB.Phi2(2:end,1),'r.','MarkerSize',20);
        hold on;grid on;

        %In = find(EB.Phi2(:,2) > 0);
        %EB.Phi2(In,2) = EB.Phi2(In,2)-2*pi;
        semilogx(T,sf*EB.Phi2(2:end,2),'ro');

        In = find(EB.Phi2(:,3) > 0);
        EB.Phi2(In,3) = EB.Phi2(In,3)-2*pi;
        semilogx(T,sf*EB.Phi2(2:end,3),'bo');

        %semilogx(T,sf*EB.Phi2(2:end,3),'b.','MarkerSize',20);
        
        %In = find(EB.Phi2(:,4) < 0);
        %EB.Phi2(In,4) = EB.Phi2(In,4)+2*pi;
        semilogx(T,sf*EB.Phi2(2:end,4),'b.','MarkerSize',20);


        errorbars(0.98*T,sf*EB.Phi2(2:end,1),sf*EB.Phi_StdErr(2:end,1),sf*EB.Phi_StdErr(2:end,1),'y','r');
        errorbars(0.99*T,sf*EB.Phi2(2:end,2),sf*EB.Phi_StdErr(2:end,2),sf*EB.Phi_StdErr(2:end,2),'y','r--');
        errorbars(T,sf*EB.Phi2(2:end,3),sf*EB.Phi_StdErr(2:end,3),sf*EB.Phi_StdErr(2:end,3),'y','b--');
        errorbars(1.01*T,sf*EB.Phi2(2:end,4),sf*EB.Phi_StdErr(2:end,4),sf*EB.Phi_StdErr(2:end,4),'y','b');

        set(gca,'ytick',[-270:45:270])
        ylim([-270,270])
        vlines(1./EB.fe(2));
        exponent_relabel(gca,'x');

        lh = legend(...
                sprintf('$\\phi_{xx}$'),...
                sprintf('$\\phi_{xy}$'),...
                sprintf('$\\phi_{yx}$'),...
                sprintf('$\\phi_{yy}$'),...
                'Location','NorthWest');
        set(lh,'interpreter','latex')
        xlabel('Period [s]');
        ylabel('[degrees]');
        
        legendadjust(lh);
        
        
        if png
            figsave(sprintf('figures/summary/plot_model_summary_Phi_MT-%s.pdf',filestr));
        end

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

        errorbars(0.98*T,sf*GE.Phi2(2:end,3),sf*GE.Phi_StdErr(2:end,3),sf*GE.Phi_StdErr(2:end,3),'y','r');
        errorbars(0.99*T,sf*GE.Phi2(2:end,4),sf*GE.Phi_StdErr(2:end,4),sf*GE.Phi_StdErr(2:end,4),'y','r');
        errorbars(T,sf*GB.Phi2(2:end,3),sf*GB.Phi_StdErr(2:end,3),sf*GB.Phi_StdErr(2:end,3),'y','b');
        errorbars(1.01*T,sf*GB.Phi2(2:end,4),sf*GB.Phi_StdErr(2:end,4),sf*GB.Phi_StdErr(2:end,4),'y','b');

        set(gca,'ytick',[-180:60:180])
        ylim([-210,210])
        vlines(1./GE.fe(2));
        exponent_relabel(gca,'x');

        [lh,lg] = legend(...
                sprintf('$\\phi_{ao}$'),...
                sprintf('$\\phi_{bo}$'),...    
                sprintf('$\\phi_{a}$'),...
                sprintf('$\\phi_{b}$'),...    
                    sprintf('$\\phi_{zx}$'),...
                    sprintf('$\\phi_{zy}$'),...    
                'Location','NorthWest');
        set(lh,'interpreter','latex')
        xlabel('Period [s]');
        ylabel('[degrees]');

        legendadjust(lh);

        if png
            figsave(sprintf('figures/summary/plot_model_summary_Phi-%s.pdf',filestr));
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
        errorbars(0.98*T,GEo_SNm(:,2),GEo_SNm(:,2)-ye(:,1),ye(:,2)-GEo_SNm(:,2),'y','k');

        ye = boot(squeeze(GE.SN(:,2,:))',@mean,1000,159);
        errorbars(0.99*T,GE_SNm(:,2),GE_SNm(:,2)-ye(:,1),ye(:,2)-GE_SNm(:,2),'y','r');

        ye = boot(squeeze(GBa.SN(:,2,:))',@mean,1000,159);
        errorbars(T,GBa_SNm(:,2),GBa_SNm(:,2)-ye(:,1),ye(:,2)-GBa_SNm(:,2),'y','g');

        ye = boot(squeeze(GB.SN(:,2,:))',@mean,1000,159);
        errorbars(1.01*T,GB_SNm(:,2),GB_SNm(:,2)-ye(:,1),ye(:,2)-GB_SNm(:,2),'y','b');        

        ylabel('Signal to Noise');
        vlines(1/GE.fe(2))

        set(gca,'YLim',[0.099,40.1]);        
        title(titlestr,'FontWeight','normal');
        lh = legend('Model 1','Model 2','Model 3','Model 4','Location','NorthWest');

        legendadjust(lh);
        
        xlabel('Period [s]');
        exponent_relabel(gca);
        
        if png
            figsave(sprintf('figures/summary/plot_model_summary_SN-%s.pdf',filestr));
        end
    end    
    f.compareSN2 = @compareSN2;

    function parameterHistograms(GEo,GEo_avg,filestr,png)

        %figprep(png,1000,500);

        figure();box on;grid on;hold on;

        edgesao = [0:20:180]';
        edgesbo = [-300:50:100]';

        [nao,xao] = histc(1e3*squeeze(GEo.ao(1,2,:)),edgesao);
        [nbo,xbo] = histc(1e3*squeeze(GEo.bo(1,2,:)),edgesbo);

        edgesao = [edgesao(1);edgesao];
        nao = [0;nao];
        edgesbo = [edgesbo(1);edgesbo];
        nbo = [0;nbo];

        stairs(edgesao,nao,'k','LineWidth',2)
        stairs(edgesbo,nbo,'k--','LineWidth',2)

        plot(1e3*GEo_avg.Mean.ao(2),0,'k.','MarkerSize',30);
        plot(1e3*GEo_avg.Mean.bo(2),0,'ko','MarkerSize',7);

        set(gca,'XLim',[-320,200])
        set(gca,'XTick',[-300:50:200]);
        set(gca,'YTick',[0:9]);
        ylabel('Count');
        xlabel('A/(V/km)');
        [lh,lo] = legend({'$a_o$','$b_o$','$\overline{a}_o$','$\overline{b}_o$'},...
                'Interpreter','latex','Location','NorthWest');

        legendadjust(lh);

        if png
            figsave(sprintf('figures/summary/plot_model_summary_aobo_histograms-%s.pdf',filestr));
        end
    end
    f.parameterHistograms = @parameterHistograms;

end