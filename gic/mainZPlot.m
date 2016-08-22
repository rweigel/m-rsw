shift = 20;
shiftBx = 40;
if strcmp(Info.short,'grassridge')
%    mainZPlotGrassridge;
end

set(0,'DefaultFigureWindowStyle','docked')

writeimgs = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;
    hold on;grid on;
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,B(:,1),'k');
    plot(t,B(:,2),'g');
    xlabel(xlab)
    ylabel('[nT]');
    title(titlestr);
    box on;
    legend(sprintf('B_x'),'B_y')
    fignames{fn} = sprintf('%s_Bx_By_%s-%s',Info.short,ts1,ts2);
    axis tight;
    drawnow
%    set(gca,'YLim',[-60 140])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Ex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;
    hold on;grid on;
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,E(:,1)+Ef(:,1)+shift,'k');
    plot(t,E(:,1),'g') 
    xlabel(xlab)
    ylabel('[mV/km]')
    title(titlestr);
    box on;
    axis tight;
%    set(gca,'YLim',[-20 40])
    legend('E_x measured','E_x filtered')
    fignames{fn} = sprintf('%s_Ex_measured_and_filtered_%s-%s',Info.short,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Ey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;
    hold on;grid on;
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,E(:,2)+Ef(:,2)+shift,'k');
    plot(t,E(:,2),'g') 
    xlabel(xlab)
    ylabel('[mV/km]')
    title(titlestr);
    box on;
    axis tight;
%    set(gca,'YLim',[-20 40])
    legend('E_y measured','E_y filtered')
    fignames{fn} = sprintf('%s_Ey_measured_and_filtered_%s-%s',Info.short,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot prediction vs model FDP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figure(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,Ep_FDP(:,i),'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,E_FDP(:,i)-shift,'b'); % Error
        xlabel(xlab)
	ylabel('[mV/km]')
	title(titlestr);
	yl = get(gca,'YLim');
	xl = get(gca,'XLim');
	yo = max(abs(yl));
	axis([xl,-yo,yo]) 
	box on;
	fstr = 'measured';
	if hpNf > 0
	    fstr  = 'filtered';
	end
        comp = 'x';if (i == 2),comp = 'y';end
	legend(sprintf('E_%s %s',comp,fstr),...
	       sprintf('E_%s FDP predicted; PE = %.2f/%.2f',...
		       comp,petr_FDP(i),pete_FDP(i)),...
	       sprintf('Error - %d',shift),...
	       'Location','NorthEast')
    fignames{fn} = sprintf('%s_E%s_%s_predicted_%s-%s',...
			   Info.short,comp,label,ts1,ts2);
    drawnow
end


if (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot prediction vs model FDR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figure(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,Ep_FDR(:,i),'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,E_FDR(:,i)-shift,'b'); % Error
        xlabel(xlab)
	ylabel('[mV/km]')
	title(titlestr);
	yl = get(gca,'YLim');
	xl = get(gca,'XLim');
	yo = max(abs(yl));
	axis([xl,-yo,yo]) 
	box on;
	fstr = 'measured';
	if hpNf > 0
	    fstr  = 'filtered';
	end
        comp = 'x';if (i == 2),comp = 'y';end
	legend(sprintf('E_%s %s',comp,fstr),...
	       sprintf('E_%s FDR predicted; PE = %.2f/%.2f',...
		       comp,petr_FDR(i),pete_FDR(i)),...
	       sprintf('Error - %d',shift),...
	       'Location','NorthEast')
    fignames{fn} = sprintf('%s_E%s_%s_predicted_%s-%s',...
			   Info.short,comp,label,ts1,ts2);
    drawnow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot prediction vs model FDRe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figure(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,Ep_FDRe(:,i),'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,E_FDRe(:,i)-shift,'b'); % Error
        xlabel(xlab)
	ylabel('[mV/km]')
	title(titlestr);
	yl = get(gca,'YLim');
	xl = get(gca,'XLim');
	yo = max(abs(yl));
	axis([xl,-yo,yo]) 
	box on;
	fstr = 'measured';
	if hpNf > 0
	    fstr  = 'filtered';
	end
        comp = 'x';if (i == 2),comp = 'y';end
	legend(sprintf('E_%s %s',comp,fstr),...
	       sprintf('E_%s FDRe predicted; PE = %.2f/%.2f',...
		       comp,petr_FDRe(i),pete_FDRe(i)),...
	       sprintf('Error - %d',shift),...
	       'Location','NorthEast')
    fignames{fn} = sprintf('%s_E%s_%s_predicted_%s-%s',...
			   Info.short,comp,label,ts1,ts2);
    drawnow
end
end

if strcmp(Info.agent,'IRIS')
    % Plot prediction vs OSU
    for i = 1:2
	fn = fn+1;
	c = 'r';
	if (i == 2), c = 'g';, end;
	figure(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,Ep_O(:,i),'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,E_O(:,i)-shift,'b'); % Error
        xlabel(xlab)
	ylabel('[mV/km]')
	title(titlestr);
	yl = get(gca,'YLim');
	xl = get(gca,'XLim');
	yo = max(abs(yl));
	axis([xl,-yo,yo]) 
	box on;
        comp = 'x';if (i == 2),comp = 'y';end
	legend(sprintf('E_%s %s',comp,fstr),...
	       sprintf('E_%s OSU predicted; PE = %.2f/%.2f',...
		       comp,petr_O(i),pete_O(i)),...
	       sprintf('Error + %d',shift),...
	       'Location','NorthEast')
	fignames{fn} = sprintf('%s_%s_E%s_predicted_OSU_%s-%s',...
			       Info.short,label,comp,ts1,ts2);
	drawnow
    end
end % if strcmp(Info.agent,'IRIS')    

% Plot prediction vs USGS or Quebec model
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figure(fn);clf;
    hold on;grid on;
    if (strmatch(label,'hp','exact'))
	plot(1,NaN,'k','LineWidth',3)  
    end
    plot(1,NaN,c,'LineWidth',3)  
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'b','LineWidth',2)  
    hold on;grid on;
    plot(t,Ep_U(:,i),'k');  % Predicted
    plot(t,E(:,i),c); % Measured or filtered
    plot(t,E_U(:,i)-shift,'b'); % Error
    xlabel(xlab)
    ylabel('[mV/km]')
    title(titlestr);
    yl = get(gca,'YLim');
    xl = get(gca,'XLim');
    yo = max(abs(yl));
    axis([xl,-yo,yo]) 
    box on;
    comp = 'x';if (i == 2),comp = 'y';end
    legend(sprintf('E_%s %s + %d',comp,fstr,shift),...
	   sprintf('E_%s %s predicted; PE = %.2f/%.2f',...
		   comp,Info.modelstr,petr_U(i),pete_U(i)),...
	   sprintf('Error + %d',shift),...
	   'Location','NorthEast')
    fignames{fn} = sprintf('%s_%s_E%s_predicted_USGS_%s-%s',...
			   Info.short,label,comp,ts1,ts2);
    drawnow
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf
    % Compare computed with USGS
    if (modelsf > 1)
	modells = sprintf('Z_0/%d %s',modelsf,Info.modelstr);
    else
	modells = sprintf('Z_0 %s',Info.modelstr);
    end
    loglog(1./f(1:10:end),abs(Z_U(1:10:end)),...
	   'c-','LineWidth',2,'MarkerSize',10);
    hold on;grid on;
    % Compare computed with IRIS
    if strcmp(Info.agent,'IRIS')
	loglog(1./fe_O(2:end),abs(Z_O(2:end,1)),'m.','MarkerSize',20);
	loglog(1./fe_O(2:end),abs(Z_O(2:end,2)),'b.','MarkerSize',20);
	loglog(1./fe_O(2:end),abs(Z_O(2:end,3)),'k.','MarkerSize',20);
	loglog(1./fe_O(2:end),abs(Z_O(2:end,4)),'r.','MarkerSize',20);
    end
    loglog(1./fe_FDRe(2:end),2*pi*fe_FDRe(2:end).*abs(Z_FDRe(2:end,1)),...
	   'm','LineWidth',2);
    loglog(1./fe_FDRe(2:end),2*pi*fe_FDRe(2:end).*abs(Z_FDRe(2:end,2)),...
	   'b','LineWidth',2);
    loglog(1./fe_FDRe(2:end),2*pi*fe_FDRe(2:end).*abs(Z_FDRe(2:end,3)),...
	   'k','LineWidth',2);
    loglog(1./fe_FDRe(2:end),2*pi*fe_FDRe(2:end).*abs(Z_FDRe(2:end,4)),...
	   'r','LineWidth',2);
    if strcmp(Info.agent,'IRIS')	
	legend(sprintf('Z_0 %s',Info.modelstr),...
	       'Z_{xx} OSU','Z_{xy} OSU','Z_{yx} OSU','Z_{yy} OSU',...
	       'Z_{xx} FDRe','Z_{xy} FDRe','Z_{yx} FDRe','Z_{yy} FDRe')
    else
	legend(sprintf('Z_0 %s',Info.modelstr),...
	       'Z_{xx} FDRe','Z_{xy} FDRe','Z_{yx} FDRe','Z_{yy} FDRe')
    end

    xlabel('T [s]')
    ylabel('[mV/km/nT]')
    title(titlestr);    
    fignames{fn} = sprintf('%s_%s_Z_vs_T_All_%s-%s',Info.short,label,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hxy and Hyx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;hold on;grid on;
if strcmp(Info.agent,'IRIS')
    plot(t_U,H_U(:,1),'c','LineWidth',2);hold on;
    plot(t_O,H_O(:,2),'r','LineWidth',2)
    plot(t_FDRe,H_FDRe(:,2),'g','LineWidth',2)
    plot(t_FDRe,H_FDR(:,2),'k','LineWidth',2)
    plot(t_TD,H_TD(:,2),'b','LineWidth',2)
    legend(...
	sprintf('H_0 %s',Info.modelstr),...
	'H_{xy} OSU','H_{xy} FDRe','H_{xy} FDR','H_{xy} TD')
    ylabel('[mV/km/nT]')
    title(titlestr);    
end
fignames{fn} = sprintf('%s_%s_Hxy_All_%s-%s',Info.short,label,ts1,ts2);    

fn = fn+1;
figure(fn);clf;hold on;grid on;
if strcmp(Info.agent,'IRIS')
    plot(t_U,H_U(:,1),'c','LineWidth',2);hold on;
    plot(t_O,H_O(:,3),'r','LineWidth',2)
    plot(t_FDRe,H_FDRe(:,3),'g','LineWidth',2)
    plot(t_TD,H_TD(:,3),'b','LineWidth',2)
    legend(...
	sprintf('H_0 %s',Info.modelstr),...
	'H_{yx} OSU','H_{yx} FDRe','H_{yx} TD')
    ylabel('[mV/km/nT]')
    title(titlestr);    
end
fignames{fn} = sprintf('%s_%s_Hyx_All_%s-%s',Info.short,label,ts1,ts2);    

% Zoom-in
if (0)
set(gca,'XLim',[-5 10]*60)
set(gca,'XTick',[-6:2:10]*60)
if (ppd == 1440)
    xlabel('t [min]')
end
if (ppd == 1440*60)
    xlabel('t [s]')
end

h1 = figure(fn);
fn = fn+1;
h2 = figure(fn);clf
    objects=allchild(h1);
    copyobj(get(h1,'children'),h2);
    set(gca,'XLim',[-15 30])
    set(gca,'XTick',[-15:5:30])
fignames{fn} = sprintf('%s_%s_H_All_Zoom%s-%s',Info.short,label,ts1,ts2);    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Histograms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
	fn = fn+1;
	figure(fn);clf;orient landscape
	comp = 'x';if i == 2,comp = 'y';end
	%bins = [-100:1:100];
	bins = logspace(-1,2,200);
	bins = [-fliplr(bins),0,bins];
	[nM,xM]  = hist(E(:,i),bins);
	[nR,xR]  = hist(E(:,i)-Ep_FDRe(:,i),bins);
	[nU,xU]  = hist(E(:,i)-Ep_U(:,i),bins);
	if strcmp(Info.agent,'IRIS')	
	    [nO,xO]  = hist(E(:,i)-Ep_O(:,i),bins);
	end
	pbaspect([1,230/190,1])
	negloglog(xM,nM,'',[1.2,0.25],[0.5,0.5,0.5]);
	negloglog(xR,nR,'',[1.2,0.25],'r');
	if strcmp(Info.agent,'IRIS')	
	    negloglog(xO,nO,'',[1.2,0.25],'g');
	end
	negloglog(xU,nU,sprintf('E_%s [mV/km/nT]',comp),[1.2,0.25],'b');

	if strcmp(Info.agent,'IRIS')	
	    legend(sprintf('Measured',comp),...
	           sprintf('FDRe E_%s Error',comp),...
		   sprintf('OSU E_%s Error',comp),...
		   sprintf('%s E_%s Error',Info.modelstr,comp));
	else
	    legend(sprintf('FDRe E_%s Error',comp),...
		   sprintf('%s E_%s Error',Info.modelstr,comp));
	end	    

	fignames{fn} = sprintf('%s_Histogram_All_E%s_%s_%s-%s',...
			      Info.short,comp,label,ts1,ts2);
	drawnow
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error spectra vs f
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;
    loglog(fA,pA(:,8),'k');
    hold on;grid on;
    loglog(fte_FDP,EPte_FDP(:,2),'b');
    loglog(fte_FDR,EPte_FDR(:,2),'k');
    loglog(fte_FDRe,EPte_FDRe(:,2),'m');
    loglog(fte_O,EPte_O(:,2),'g');
    loglog(fte_U,EPte_U(:,2),'r');
    xlabel('frequency [Hz]');
    title('E_y');
    legend('Measured','FDP','FDR','FDRe','OSU',Info.modelstr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error spectra vs T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    figure(fn);clf;orient landscape
    comp = 'x';if i == 2,comp = 'y';end
    loglog(1./fA,pA(:,6+i),'k','LineWidth',2);
    hold on;grid on;
    loglog(1./fte_FDP,EPte_FDP(:,i),'b','LineWidth',2);
    loglog(1./fte_FDR,EPte_FDR(:,i),'k','LineWidth',2);
    loglog(1./fte_FDRe,EPte_FDRe(:,i),'c','LineWidth',2);
    loglog(1./fte_O,EPte_O(:,i),'g','LineWidth',2);
    loglog(1./fte_U,EPte_U(:,i),'r','LineWidth',2);
    xlabel('Period [s]');
    title(sprintf('E_%s',comp));
    legend('Measured','FDP','FDR','FDRe','OSU',Info.modelstr,'Location','NorthWest');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coherence vs T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);clf;
    semilogx(1./f_Cxy,Cxy_FDP(:,2),'b','LineWidth',2);
    hold on;grid on;
    semilogx(1./f_Cxy,Cxy_O(:,2),'g','LineWidth',2);
    semilogx(1./f_Cxy,Cxy_U(:,2),'r','LineWidth',2);
    ylabel('C_{xy}');
    xlabel('Period [s]');
    title('E_y');
    legend('FDRP','OSU',Info.modelstr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = 1;
fn = fn+1;
figure(fn);clf;
if (0)
[eR,fR] = periodogramraw(EpR(:,i)-E(:,i),'fast');
loglog(1./fR(2:end),eR(2:end));
[eA,fA] = periodogramraw(EpA(:,i)-E(:,i),'fast');
hold on;grid on;
loglog(1./fA(2:end),eA(2:end));
%xlabel('frequency [Hz]')
end
[TR,PR] = spectrogram(EpR(:,i)-E(:,i),ppd);
PR = mean(P,1);
[TA,PA] = spectrogram(EpA(:,i)-E(:,i),ppd);
PA = mean(PA,1);
loglog(TR,PR,'k');
hold on;grid on;
loglog(TA,PA,'b');
xlabel('Period [s]')
legend('Error','OSU Error')
corrcoef(EpR(:,i)-E(:,i),E(:,i))
corrcoef(EpA(:,i)-E(:,i),E(:,i))
subplot(1,2,1)
  plot(E(:,i),EpR(:,i)-E(:,i),'k.','MarkerSize',10);hold on;
  xlabel('Measured');
  ylabel('Error')
  axis square;
  grid on;
  title('Model')
subplot(1,2,2)
  plot(E(:,i),EpA(:,i)-E(:,i),'b.','MarkerSize',10)
  xlabel('Measured');
  ylabel('Error')
  title('OSU')
  axis square
  grid on;
end

