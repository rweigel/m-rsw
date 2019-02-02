%function plot_TF_aves(filestr,png,allfigs)

% filestr = 'options-1';
% png = 0;
% allfigs = 0;

dirfig = sprintf('figures/combined');
if ~exist(dirfig,'dir')
    mkdir(dirfig);
end

fn = 0;
figprep(png,1000,500);

file = sprintf('mat/compute_TF_aves-%s.mat',filestr);
fprintf('plot_TF_aves: Loading from %s\n',file);
F = load(file);

F.EB.title = '$\mathbf{E} = \mathcal{Z}\mathbf{B}$; E in mV/m, B in nT';
F.GE.title = '$G_B(\omega) = A(\omega)E_{x}(\omega) + B(\omega)E_{y}$';
F.GB.title = '$G_E(\omega) = Z_x(\omega)B_{x}(\omega) + Z_y(\omega)B_{y}$';

parameterhistograms(F.GEo);

compareHplots(F.GE,F.GEo,F.GB);
compareZplots(F.GE,F.GEo,F.GB);
comparePhiplots(F.GE,F.GB);

if allfigs
    spectraAverages(F.GE,F.GB);

    errorSpectraInSample(F.GE,F.GEo,F.GB,F.GBa,F.EB);
    errorSpectraMean(F.GE,F.GEo,F.GB,F.GBa,F.EB);
    errorSpectraMedian(F.GE,F.GEo,F.GB,F.GBa,F.EB);

    %signaltoNoiseInSample1(F.GE,F.GEo,F.GB,F.GBa);
    signaltoNoiseInSample2(F.GE,F.GEo,F.GB,F.GBa);
end

%signaltoNoiseMean1(F.GE,F.GEo,F.GB,F.GBa);
signaltoNoiseMean2(F.GE,F.GEo,F.GB,F.GBa);

if allfigs
    coherenceInSample(F.GE,F.GEo,F.GB,F.GBa);
    coherenceMean(F.GE,F.GEo,F.GB,F.GBa);
end
%genZplots(F.EB);
%genRhoplots(F.EB);
%genPhiplots(F.EB);

return

mtZplots(F.EB);
mtrhoplots(F.EB);
mtphiplots(F.EB);

%errorhistograms(F.GE);

function parameterhistograms(GEo)

    fn=fn+1;figure(fn);clf;box on;grid on;hold on;

        edgesao = [0:20:180];
        %edgesao = [-300:50:300];
        edgesbo = [-300:50:300];

        [nao,xao] = histc(1e3*GEo.ao(2,:),edgesao);
        [nbo,xbo] = histc(1e3*GEo.bo(2,:),edgesbo);

        edgesao = [edgesao(1),edgesao];
        nao = [0,nao];
        edgesbo = [edgesbo(1),edgesbo];
        nbo = [0,nbo];

        stairs(edgesao,nao,'k','LineWidth',2)
        stairs(edgesbo,nbo,'k--','LineWidth',2)

        plot(1e3*GEo.ao_Mean(2),0,'k.','MarkerSize',30);
        plot(1e3*GEo.bo_Mean(2),0,'ko','MarkerSize',7);

        ylabel('Count');
        xlabel('A/(V/km)');
        [lh,lo] = legend({'$a_o$','$b_o$','$\overline{a}_o$','$\overline{b}_o$'},'Interpreter','latex');
        savefig('aobo_histograms');

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
        loglog(1./GE.fe,mean(squeeze(GE.Output_PSD(:,2,:)),2)./mean(squeeze(GEo.Error_PSD_Mean(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        hold on;
        loglog(1./GE.fe,mean(squeeze(GE.Output_PSD(:,2,:)),2)./mean(squeeze(GE.Error_PSD_Mean(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        loglog(1./GB.fe,mean(squeeze(GBa.Output_PSD(:,2,:)),2)./mean(squeeze(GBa.Error_PSD_Mean(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2)
        loglog(1./GB.fe,mean(squeeze(GB.Output_PSD(:,2,:)),2)./mean(squeeze(GB.Error_PSD_Mean(:,2,:)),2),...
               'Marker','.','MarkerSize',20,'LineWidth',2);
        grid on;
        title('Signal to noise - Mean Model Predictions (method 1)');
        vlines(1/F.GE.fe(2))
        legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        xlabel('Period [s]');
        exponent_relabel(gca,'y');
end

function signaltoNoiseMean2(GE,GEo,GB,GBa)
    fn=fn+1;figure(fn);clf;
        T = 1./GB.fe;
    
        GEo_SN = squeeze(GE.Output_PSD(:,2,:)./GEo.Error_PSD_Mean(:,2,:));
        GEo_SNm = mean(GEo_SN,2);
        GE_SN  = squeeze(GE.Output_PSD(:,2,:)./GE.Error_PSD_Mean(:,2,:));
        GE_SNm = mean(GE_SN,2);
        GBa_SN = squeeze(GBa.Output_PSD(:,2,:)./GBa.Error_PSD_Mean(:,2,:));
        GBa_SNm = mean(GBa_SN,2);
        GB_SN  = squeeze(GB.Output_PSD(:,2,:)./GB.Error_PSD_Mean(:,2,:));
        GB_SNm = mean(GB_SN,2);
        
        loglog(T,GEo_SNm,'k','Marker','.','MarkerSize',2,'LineWidth',2);
        hold on;grid on;
        loglog(T,GE_SNm,'r','Marker','.','MarkerSize',2,'LineWidth',2);
        loglog(T,GBa_SNm,'g','Marker','.','MarkerSize',2,'LineWidth',2)
        loglog(T,GB_SNm,'b','Marker','.','MarkerSize',2,'LineWidth',2);

        ye = boot(GEo_SN',@mean,1000,159);
        errorbars(T,GEo_SNm,GEo_SNm-ye(:,1),ye(:,2)-GEo_SNm,'y','k');
        
        %ye = std(GEo_SN,0,2)/sqrt(size(GEo_SN,2));
        %errorbars(T,GEo_SNm,ye,ye,'y','k');

        ye = boot(GE_SN',@mean,1000,159);
        errorbars(T,GE_SNm,GE_SNm-ye(:,1),ye(:,2)-GE_SNm,'y','r');

        ye = boot(GBa_SN',@mean,1000,159);
        errorbars(T,GBa_SNm,GBa_SNm-ye(:,1),ye(:,2)-GBa_SNm,'y','g');

        ye = boot(GB_SN',@mean,1000,159);
        errorbars(T,GB_SNm,GB_SNm-ye(:,1),ye(:,2)-GB_SNm,'y','b');        
        
        if allfigs == 1
            title('Signal to noise - Mean Model Predictions (method 2)');
        else
            ylabel('Signal to Noise');
        end
        vlines(1/F.GE.fe(2))
        if allfigs == 1
            legend('GIC','Model 1 ($G_o$) Error','Model 2 ($G_E$) Error','Model 3 ($G_{E''}$) Error','Model 4 ($G_B$) Error','Location','Best');
        else
            set(gca,'YLim',[0.1,40]);
            legend('Model 1','Model 2','Model 3','Model 4','Location','NorthWest');    
        end
        xlabel('Period [s]');
        exponent_relabel(gca);
        savefig('SN');
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
 
function comparePhiplots(GE,GB,pn)
    
    if nargin == 3
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    
    sf = 180/pi;
    T = 1./GE.fe(2:end);
    
    semilogx(T,0*GE.Phi_Mean2(2:end,3),'k.','MarkerSize',5);
    hold on;box on;grid on;
    semilogx(T,0*GE.Phi_Mean2(2:end,4),'ko','MarkerSize',5);

    semilogx(T,sf*GE.Phi_Mean2(2:end,3),'r.','MarkerSize',20);
    semilogx(T,sf*GE.Phi_Mean2(2:end,4),'ro');
    semilogx(T,sf*GB.Phi_Mean2(2:end,3),'b.','MarkerSize',20);
    semilogx(T,sf*GB.Phi_Mean2(2:end,4),'bo');

    errorbars(T,sf*GE.Phi_Mean2(2:end,3),sf*GE.Phi_StdErr(2:end,3),sf*GE.Phi_StdErr(2:end,3),'y','r');
    errorbars(T,sf*GE.Phi_Mean2(2:end,4),sf*GE.Phi_StdErr(2:end,4),sf*GE.Phi_StdErr(2:end,4),'y','r');
    errorbars(T,sf*GB.Phi_Mean2(2:end,3),sf*GB.Phi_StdErr(2:end,3),sf*GB.Phi_StdErr(2:end,3),'y','b');
    errorbars(T,sf*GB.Phi_Mean2(2:end,4),sf*GB.Phi_StdErr(2:end,4),sf*GB.Phi_StdErr(2:end,4),'y','b');

    set(gca,'ytick',[-180:30:180])
    ylim([-210,210])
    vlines(1./GE.fe(2));
    exponent_relabel(gca,'x');

    lh = legend(...
            sprintf('$\\phi_{ao}$'),...
            sprintf('$\\phi_{bo}$'),...    
            sprintf('$\\phi_{a}$'),...
            sprintf('$\\phi_{b}$'),...    
                sprintf('$\\phi_{Zx}$'),...
                sprintf('$\\phi_{Zy}$'),...    
            'Location','Best');
    set(lh,'interpreter','latex')
    xlabel('Period [s]');
    ylabel('[degrees]');
    savefig('Phi');

end

function compareHplots(GE,GEo,GB,pn)

    if nargin == 4
        subplot(3,1,pn)
    else
        fn=fn+1;figure(fn);clf;    
    end
    
    box on;grid on;hold on;
    n = (size(GE.H_Mean,1)-1)/2;
    t = [-n:n]';
    sf = 1e3;

    tlims = [-40 60];
    I = find(t >= tlims(1) & t <= tlims(2));

    plot(0,sf*GEo.ao_Mean(2)/10,'k.','MarkerSize',25);
    plot(0,sf*GEo.bo_Mean(2)/10,'ko','MarkerSize',8);

    plot(t(I),sf*GE.H_Mean(I,3),'r','LineWidth',2);
    plot(t(I),sf*GE.H_Mean(I,4),'r--','LineWidth',2);

    plot(t(I),sf*GB.H_Mean(I,3),'b','LineWidth',2);
    plot(t(I),sf*GB.H_Mean(I,4),'b--','LineWidth',2);

    errorbars(t(I),sf*GE.H_Mean(I,3),sf*GE.H_StdErr(I,3),sf*GE.H_StdErr(I,3),'y','r');
    errorbars(t(I),sf*GE.H_Mean(I,4),sf*GE.H_StdErr(I,4),sf*GE.H_StdErr(I,4),'y','r');
    errorbars(t(I),sf*GB.H_Mean(I,3),sf*GB.H_StdErr(I,3),sf*GB.H_StdErr(I,3),'y','b');
    errorbars(t(I),sf*GB.H_Mean(I,4),sf*GB.H_StdErr(I,4),sf*GB.H_StdErr(I,4),'y','b');

    % Plot again so on top
    plot(0,sf*GEo.ao_Mean(2)/10,'k.','MarkerSize',25);
    plot(0,sf*GEo.bo_Mean(2)/10,'ko','MarkerSize',8);

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
    savefig('H');

end

function compareZplots(GE,GEo,GB,GBa,pn)
    
    fn=fn+1;figure(fn);clf;box on;          

    sf = 1e3;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.ao_Mean(2)),length(GE.fe(2:end)),1),'k');
    hold on;grid on;
    loglog(1./GE.fe(2:end),sf*repmat(abs(GEo.bo_Mean(2)),length(GE.fe(2:end)),1),'k--');        

    loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),'r','LineWidth',2);
    loglog(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),'r--','LineWidth',2);
    loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,3),'b--','LineWidth',2);
    loglog(1./GB.fe(2:end),sf*GB.Zabs_Mean(2:end,4),'b','LineWidth',2);
    
    errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,3),sf*GE.Zabs_StdErr(2:end,3),sf*GE.Zabs_StdErr(2:end,3),'y','r');
    errorbars(1./GE.fe(2:end),sf*GE.Zabs_Mean(2:end,4),sf*GE.Zabs_StdErr(2:end,4),sf*GE.Zabs_StdErr(2:end,4),'y','r');    
    errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,3),sf*GB.Zabs_StdErr(2:end,3),sf*GB.Zabs_StdErr(2:end,3),'y','b');
    errorbars(1./GE.fe(2:end),sf*GB.Zabs_Mean(2:end,4),sf*GB.Zabs_StdErr(2:end,4),sf*GB.Zabs_StdErr(2:end,4),'y','b');
    yl = get(gca,'YLim');
    yl(1) = 1;
    yl(2) = 300;
    set(gca,'YLim',yl);
    vlines(1./GE.fe(2));
    lh = legend(...
            sprintf('$\\overline{a}_o$ [A/(V/km)]'),...
            sprintf('$\\overline{b}_o$ [A/(V/km)]'),...    
            sprintf('$|A(\\omega)|$ [A/(V/km)]'),...
            sprintf('$|B(\\omega)|$ [A/(V/km)]'),...    
            sprintf('$|Z_x(\\omega)|$ [mA/nT]'),...
            sprintf('$|Z_y(\\omega)|$ [mA/nT]'),...
            'Location','NorthWest');
    set(lh,'interpreter','latex');
    xlabel('Period [s]');
    exponent_relabel(gca,'x');    
    savefig('Z');

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
        %errorbars(1./S.fe(2:end),sf*S.Zabs_Mean(2:end,i),sf*S.Zabs_Standard_Error(2:end,i),'loglog');
        hold on;
    end

    grid on;
    xlabel('Period [s]');
    ylabel('A/(V/km)');
    lh = legend(components,'Location','best');
    set(lh,'interpreter','latex')
    %title(titlestr,'interpreter','latex')

    if png
        figsave(sprintf('%s/plot_TF_aves_EB_Z-%s.pdf',dirfig,filestr));
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
        figsave(sprintf('%s/plot_TF_aves_EB_rho-%s.pdf',dirfig,filestr))
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
        figsave(sprintf('%s/plot_TF_aves_EB_phi-%s.pdf',dirfig,filestr))
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
        figsave(sprintf('%s/plot_TF_aves_EB_Z-%s.pdf',dirfig,filestr))
    end        
        
end

function genRhoPlots(S)
    
    components = {'xx','xy','yx','yy'};
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

end
