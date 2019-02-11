function plot_model_summary(GEo,GE,GBo,GB,GBa,EB,filestr,png)

if isfield(GEo,'Mean')
    GEo = GEo.Mean;
    GE  = GE.Mean;
    GBo = GBo.Mean;
    GB  = GB.Mean;
    GBa = GBa.Mean;
    Eb  = EB.Mean;
end

fn = 1;
allfigs = 0;

figprep(png,1000,500)

compareHplots(GE,GEo,GB);
compareZplots(GE,GEo,GB);
comparePhiplots(GE,GB);

if allfigs
    spectraAverages(GE,GB);

    errorSpectraInSample(GE,GEo,GB,GBa,EB);
    errorSpectraMean(GE,GEo,GB,GBa,EB);
    errorSpectraMedian(GE,GEo,GB,GBa,EB);

    signaltoNoiseInSample1(GE,GEo,GB,GBa);
    signaltoNoiseInSample2(GE,GEo,GB,GBa);

    signaltoNoiseMean1(GE,GEo,GB,GBa);
end

signaltoNoiseMean2(GE,GEo,GB,GBa);

if allfigs
    coherenceInSample(GE,GEo,GB,GBa);
    coherenceMean(GE,GEo,GB,GBa);
end

function compareHplots(GE,GEo,GB,pn)

    if nargin == 4
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    
    box on;grid on;hold on;
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
            sprintf('$a(\\tau) = IFT(A(\\omega))$ [A/(V/km)]'),...
            sprintf('$b(\\tau) = IFT(B(\\omega))$ [A/(V/km)]'),...    
            sprintf('$h_x(\\tau) = IFT(Z_x(\\omega))$ [mA/nT]'),...
            sprintf('$h_y(\\tau) = IFT(Z_y(\\omega))$ [mA/nT]'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    xlabel('Time [s]');

    if png
        figsave(sprintf('figures/combined/plot_model_summary_H-%s.pdf',filestr));
    end

end

function compareZplots(GE,GEo,GB,GBa,pn)
    
    fn=fn+1;figure(fn);clf;box on;          

    sf = 1e3;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.ao(2)),length(GE.fe(2:end)),1),'k');
    hold on;grid on;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.bo(2)),length(GE.fe(2:end)),1),'k--');        

    loglog(1./GE.fe(2:end),sf*GE.Zabs(2:end,3),'r','LineWidth',2);
    loglog(1./GE.fe(2:end),sf*GE.Zabs(2:end,4),'r--','LineWidth',2);
    loglog(1./GB.fe(2:end),sf*GB.Zabs(2:end,3),'b--','LineWidth',2);
    loglog(1./GB.fe(2:end),sf*GB.Zabs(2:end,4),'b','LineWidth',2);

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
            sprintf('$|A(\\omega)|$ [A/(V/km)]'),...
            sprintf('$|B(\\omega)|$ [A/(V/km)]'),...    
            sprintf('$|Z_x(\\omega)|$ [mA/nT]'),...
            sprintf('$|Z_y(\\omega)|$ [mA/nT]'),...
            'Location','NorthWest');
    set(lh,'interpreter','latex');
    xlabel('Period [s]');
    exponent_relabel(gca,'x');
    
    if png
        figsave(sprintf('figures/combined/plot_model_summary_Z-%s.pdf',filestr));
    end

end

function comparePhiplots(GE,GB,pn)
    
    if nargin == 3
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    
    sf = 180/pi;
    T = 1./GE.fe(2:end);
    
    semilogx(T,0*GE.Phi2(2:end,3),'k.','MarkerSize',5);
    hold on;box on;grid on;
    semilogx(T,0*GE.Phi2(2:end,4),'ko','MarkerSize',5);

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
            sprintf('$\\phi_{A}$'),...
            sprintf('$\\phi_{B}$'),...    
                sprintf('$\\phi_{Zx}$'),...
                sprintf('$\\phi_{Zy}$'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    xlabel('Period [s]');
    ylabel('[degrees]');
    
    if png
        figsave(sprintf('figures/combined/plot_model_summary_Phi-%s.pdf',filestr));
    end

end

function spectraAverages(GE,GB)

    sf = size(F.GE.Prediction,1)/2;
    fe = F.GE.fe;
    
    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(GE.Output_PSD_Mean(2:end,2,:)),2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(GE.Input_PSD_Mean(2:end,1,:)),2)/sf,'r','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GE.Input_PSD_Mean(2:end,2,:)),2)/sf,'g','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GB.Input_PSD_Mean(2:end,1,:)),2)/sf,'k','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GB.Input_PSD_Mean(2:end,2,:)),2)/sf,'m','LineWidth',2,'Marker','.','MarkerSize',15)
        vlines(1/fe(2))
        %[lh,lo] = legend('GIC [A]','E_x [mV/km]','E_y [mV/km]','B_x [nT]','B_y [nT]','Location','Best');
        [lh,lo] = legend('GIC','E_x','E_y','B_x','B_y','Location','Best');
        title('Out-of-Sample')
        ylabel('PSD')
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/All_spectra_%s-%d.png',dirfig,dateo,intervalno));end
end

function errorSpectraMean(GE,GEo,GB,GBa,EB)
    
    sf = size(F.GE.Prediction,1)/2;
    fe = F.GE.fe;

    % Relative contribution to variance
    [~,Ne] = evalfreq(size(GE.Prediction,1));

    
    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(GE.Output_PSD_Mean(2:end,2,:)),2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(GEo.Error_PSD_Mean(2:end,2,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GE.Error_PSD_Mean(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GBa.Error_PSD_Mean(2:end,2,:)),2)/sf,'k-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GB.Error_PSD_Mean(2:end,2,:)),2)/sf,'m-.','LineWidth',2,'Marker','.','MarkerSize',15)

        rc = Ne(2:end).*mean(squeeze(GEo.Error_PSD_Mean(2:end,2,:)),2)/sf;rc = rc/sum(rc);        
        loglog(1./fe(2:end),rc,'r-.','LineWidth',1,'Marker','.','MarkerSize',5)
        
        rc = Ne(2:end).*mean(squeeze(GE.Error_PSD_Mean(2:end,2,:)),2)/sf;rc = rc/sum(rc);        
        loglog(1./fe(2:end),rc,'r-.','LineWidth',1,'Marker','.','MarkerSize',5)
        
        rc = Ne(2:end).*mean(squeeze(GBa.Error_PSD_Mean(2:end,2,:)),2)/sf;rc = rc/sum(rc);        
        loglog(1./fe(2:end),rc,'k-.','LineWidth',1,'Marker','.','MarkerSize',5)
        
        rc = Ne(2:end).*mean(squeeze(GB.Error_PSD_Mean(2:end,2,:)),2)/sf;rc = rc/sum(rc);        
        loglog(1./fe(2:end),rc,'m-.','LineWidth',1,'Marker','.','MarkerSize',5)

        
        vlines(1/fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        title('Average of Error Spectra - Mean Model Predictions');
        ylabel('PSD');
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD_Mean(2:end,1,:)),2)/sf,'r-','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD_Mean(2:end,2,:)),2)/sf,'g-','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD_Mean(2:end,1,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD_Mean(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        vlines(1/fe(2))
        [lh,lo] = legend('$E_x$','$E_y$','$E_x$ error','$E_y$ error','Location','Best');
        title('Average of Error Spectra - Mean Model Predictions');
        ylabel('PSD')
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

end

function errorSpectraMedian(GE,GEo,GB,GBa,EB)

    sf = size(F.GE.Prediction,1)/2;
    fe = F.GE.fe;
    
    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(GE.Output_PSD_Median(2:end,2,:)),2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(GEo.Error_PSD_Median(2:end,2,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GE.Error_PSD_Median(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GBa.Error_PSD_Median(2:end,2,:)),2)/sf,'k-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GB.Error_PSD_Median(2:end,2,:)),2)/sf,'m-.','LineWidth',2,'Marker','.','MarkerSize',15)
        
        vlines(1/fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        title('Average of Error Spectra - Median Model Predictions');
        ylabel('PSD');
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD_Median(2:end,1,:)),2)/sf,'r-','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD_Median(2:end,2,:)),2)/sf,'g-','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD_Median(2:end,1,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD_Median(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        vlines(1/fe(2))
        [lh,lo] = legend('$E_x$','$E_y$','$E_x$ error','$E_y$ error','Location','Best');
        title('Average of Error Spectra - Median Model Predictions');
        ylabel('PSD')
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

end

function errorSpectraInSample(GE,GEo,GB,GBa,EB)

    sf = size(F.GE.Prediction,1)/2;
    fe = F.GE.fe;
    
    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(GE.Output_PSD(2:end,2,:)),2)/sf,'b','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(GEo.Error_PSD(2:end,2,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GE.Error_PSD(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GBa.Error_PSD(2:end,2,:)),2)/sf,'k-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(GB.Error_PSD(2:end,2,:)),2)/sf,'m-.','LineWidth',2,'Marker','.','MarkerSize',15)
        vlines(1/fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        title('Average of Error Spectra - In-Sample Model Predictions');
        ylabel('PSD');
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/GIC_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

    fn=fn+1;figure(fn);clf;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD(2:end,1,:)),2)/sf,'r-','LineWidth',2,'Marker','.','MarkerSize',15)
        hold on;box on;grid on;
        loglog(1./fe(2:end),mean(squeeze(EB.Output_PSD(2:end,2,:)),2)/sf,'g-','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD(2:end,1,:)),2)/sf,'r-.','LineWidth',2,'Marker','.','MarkerSize',15)
        loglog(1./fe(2:end),mean(squeeze(EB.Error_PSD(2:end,2,:)),2)/sf,'g-.','LineWidth',2,'Marker','.','MarkerSize',15)
        vlines(1/fe(2))
        [lh,lo] = legend('$E_x$','$E_y$','$E_x$ error','$E_y$ error','Location','Best');
        title('Average of Error Spectra - In-Sample Model Predictions');
        ylabel('PSD')
        xlabel('Period [s]')
        %figconfig;
        %if png,print('-dpng',sprintf('%s/E_spectra_errors_%s-%d.png',dirfig,dateo,intervalno));end

end

function coherenceMean(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,mean(squeeze(GEo.Coherence_Mean(:,1,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Coherence_Mean(:,1,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Coherence_Mean(:,2,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GB.Coherence_Mean(:,2,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2)
        grid on;
        title('Coherence - Out-of-Sample');
        vlines(1/F.GE.fe(2));
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');        
end

function coherenceInSample(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,mean(squeeze(GEo.Coherence(:,1,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Coherence(:,1,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Coherence(:,2,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GB.Coherence(:,2,:)),2),...
                'Marker','.','MarkerSize',20,'LineWidth',2)
        grid on;
        title('Coherence - In-Sample');
        vlines(1/F.GE.fe(2));
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');        
end

function signaltoNoiseInSample1(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,mean(squeeze(GEo.Output_PSD(:,2,:)),2)./mean(squeeze(GEo.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Output_PSD(:,2,:)),2)./mean(squeeze(GE.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Output_PSD(:,2,:)),2)./mean(squeeze(GBa.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2)
        loglog(1./GB.fe,mean(squeeze(GB.Output_PSD(:,2,:)),2)./mean(squeeze(GB.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        grid on;
        title('Signal to noise - In-Sample Predictions (method 1)');
        vlines(1/F.GE.fe(2));
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');
end

function signaltoNoiseInSample2(GE,GEo,GB,GBa)
    
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,mean(squeeze(GEo.Output_PSD(:,2,:))./squeeze(GEo.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
       hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Output_PSD(:,2,:))./squeeze(GE.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Output_PSD(:,2,:))./squeeze(GBa.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2)
        loglog(1./GB.fe,mean(squeeze(GB.Output_PSD(:,2,:))./squeeze(GB.Error_PSD(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        grid on;
        title('Signal to noise - In-Sample Predictions (method 2)');
        vlines(1/F.GE.fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');
end

function signaltoNoiseMean1(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
        loglog(1./GE.fe,mean(squeeze(GE.Out_PSD(:,2,:)),2)./mean(squeeze(GEo.Error_PSD(:,2,:)),2),...
               'k','Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Out_PSD(:,2,:)),2)./mean(squeeze(GE.Error_PSD(:,2,:)),2),...
               'r','Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Out_PSD(:,2,:)),2)./mean(squeeze(GBa.Error_PSD(:,2,:)),2),...
               'g','Marker','.','MarkerSize',20,'LineWidth',2)
        loglog(1./GB.fe,mean(squeeze(GB.Out_PSD(:,2,:)),2)./mean(squeeze(GB.Error_PSD(:,2,:)),2),...
               'b','Marker','.','MarkerSize',20,'LineWidth',2);
        grid on;
        title('Signal to noise - $<GIC(\omega)>/<Error(\omega)>$');
        vlines(1/GE.fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');
end

function signaltoNoiseMean2(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
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
        
        if allfigs == 1
            title('Signal to noise - Mean Model Predictions (method 2)');
        else
            ylabel('Signal to Noise');
        end
        vlines(1/GE.fe(2))
        if allfigs == 1
            title('Signal to noise - <GIC(\omega)>/<Error(\omega)>$');
            legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        else
            set(gca,'YLim',[0.099,40.1]);
            legend('Model 1','Model 2','Model 3','Model 4','Location','NorthWest');    
        end
        xlabel('Period [s]');
        exponent_relabel(gca);
        if png
            figsave(sprintf('figures/combined/plot_model_summary_SN-%s.pdf',filestr));
        end
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
 
end
