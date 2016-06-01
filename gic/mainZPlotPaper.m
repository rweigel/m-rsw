shift = 20;
shiftBx = 40;
if strcmp(short,'grassridge')
    %mainZPlotGrassridge;
end

writeimgs = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    plot(1,NaN,'r','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    plot(1,NaN,'b','LineWidth',3)  
    hold on;grid on;
    plot(t,EpU{M}(:,2)-E(:,2)+shift,'r'); 
    plot(t,EpR(:,2)-E(:,2)+0,'b');
    plot(t,EpA(:,2)-E(:,2)-shift,'g');
    xlabel(xlab)
    ylabel('[mV/km]')
    %title(titlestr);
    box on;
    axis tight;
    set(gca,'YLim',[-50 50])
    legend(...
	sprintf('Method 1; cc = %.2f',ccvU{M}(2)),...
	sprintf('Method 2; cc = %.2f',ccvR(2)),...
	sprintf('Method 3; cc = %.2f',ccvA(2)),...
	'Location','SouthWest')
    fignames{fn} = sprintf('%s_Ey_error_%s-%s',short,comp,ts1,ts2);
    drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    plot(1,NaN,'r','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    plot(1,NaN,'b','LineWidth',3)  
    hold on;grid on;
    plot(t,EpU{M}(:,1)-E(:,1)+shift,'r'); 
    plot(t,EpR(:,1)-E(:,1)+0,'b');
    plot(t,EpA(:,1)-E(:,1)-shift,'g');
    xlabel(xlab)
    ylabel('[mV/km]')
    %title(titlestr);
    box on;
    axis tight;
    set(gca,'YLim',[-50 50])
    legend(...
	sprintf('Method 1; cc = %.2f',ccvU{M}(1)),...
	sprintf('Method 2; cc = %.2f',ccvR(1)),...
	sprintf('Method 3; cc = %.2f',ccvA(1)),...
	'Location','SouthWest')
    fignames{fn} = sprintf('%s_Ex_error_%s-%s',short,comp,ts1,ts2);
    drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,B(:,1)+50,'k');
    plot(t,B(:,2),'g');
    xlabel(xlab);
    ylabel('[nT]');
    %title(titlestr);
    box on;
    legend(sprintf('B_x + %d',shiftBx),'B_y','Location','NorthWest')
    fignames{fn} = sprintf('%s_Bx_By_%s-%s',short,ts1,ts2);
    axis tight;
    set(gca,'YLim',[-60 140])
    drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex and Ey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    comp = 'x';if (i == 2),comp = 'y';end        
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,E(:,1)+Ef(:,1)+shift,'k');
    plot(t,E(:,2)+Ef(:,2),'g') 
    xlabel(xlab)
    ylabel('[mV/km]')
    %title(titlestr);
    box on;
    axis tight;
    set(gca,'YLim',[-20 40])
    legend(sprintf('E_x + %d',shift),'E_y','Location','NorthWest')
    fignames{fn} = sprintf('%s_Ex_Ey_measured_%s-%s',short,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (writeimgs)
  for i = [1:fn]
    figurex(i);
    fig = gcf;
    set(fig,'PaperUnits','inches');
    set(fig,'PaperPosition',[0 0 8.5 3]);
    fname = sprintf('%s/%s/%s/figures/mainPlot_%s',...
		    datadir,lower(agent),short,fignames{i});
    fprintf('mainPlot: Writing %s.{pdf,png}\n',fname);
    print([fname,'.png'],'-dpng');
    print([fname,'.pdf'],'-dpdf');
    print([fname,'.eps'],'-depsc');    
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Ex and Ey
fn = fn+1;
figurex(fn);clf;
    hold on;grid on;
    plot(1,NaN,'r','LineWidth',3)  
    plot(1,NaN,'g','LineWidth',3)  
    hold on;grid on;
    plot(t,E(:,1)+shift,'r');
    plot(t,E(:,2),'g');
    xlabel(xlab)
    ylabel('[mV/km]')
    title(titlestr);
    box on;
    legend(sprintf('E_x filtered + %d',shift),'E_y filtered')
    fignames{fn} = sprintf('%s_Ex_Ey_filtered_%s-%s',short,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot prediction vs model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figurex(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,EpR(:,i)+shift,'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,EpR(:,i)-E(:,i)-shift,'b'); % Error
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
	legend(sprintf('E_%s %s + %d',comp,fstr,shift),...
	       sprintf('E_%s predicted; PE = %.2f',comp,pev(i)),...
	       sprintf('Error + %d',shift),...
	       'Location','NorthEast')
    fignames{fn} = sprintf('%s_E%s_%s_predicted_%s-%s',...
			   short,comp,label,ts1,ts2);
    drawnow
end

if strcmp(agent,'IRIS')
    % Plot prediction vs OSU
    for i = 1:2
	fn = fn+1;
	c = 'r';
	if (i == 2), c = 'g';, end;
	figurex(fn);clf;
        hold on;grid on;
        if (strmatch(label,'hp','exact'))
            plot(1,NaN,'k','LineWidth',3)  
        end
        plot(1,NaN,c,'LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,EpA(:,i)+shift,'k');  % Predicted
        plot(t,E(:,i),c); % Measured or filtered
	plot(t,EpA(:,i)-E(:,i)-shift,'b'); % Error
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
	       sprintf('E_%s OSU predicted; PE = %.2f',...
		       comp,pevA(i)),...
	       sprintf('Error + %d',shift),...
	       'Location','NorthEast')
	fignames{fn} = sprintf('%s_%s_E%s_predicted_OSU_%s-%s',...
			       short,label,comp,ts1,ts2);
	drawnow
    end
end % if strcmp(agent,'IRIS')    

% Plot prediction vs USGS or Quebec model
for i = 1:2
    fn = fn+1;
    c = 'r';
    if (i == 2), c = 'g';, end;
    figurex(fn);clf;
    hold on;grid on;
    if (strmatch(label,'hp','exact'))
	plot(1,NaN,'k','LineWidth',3)  
    end
    plot(1,NaN,c,'LineWidth',3)  
    plot(1,NaN,'k','LineWidth',3)  
    plot(1,NaN,'b','LineWidth',2)  
    hold on;grid on;
    plot(t,EpU{M}(:,i)+shift,'k');  % Predicted
    plot(t,E(:,i),c); % Measured or filtered
    plot(t,EpU{M}(:,i)-E(:,i)-shift,'b'); % Error
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
	   sprintf('E_%s %s predicted; PE = %.2f',...
		   comp,modelstr,pevU{M}(i)),...
	   sprintf('Error + %d',shift),...
	   'Location','NorthEast')
    fignames{fn} = sprintf('%s_%s_E%s_predicted_USGS_%s-%s',...
			   short,label,comp,ts1,ts2);
    drawnow
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% H
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (dim == 1)
    fn = fn+1;
    figurex(fn);clf;hold on;grid on;
    if (modelsf > 1)
	modells = sprintf('H_0/%d %s',modelsf,modelstr);
    else
	modells = sprintf('H_0 %s',modelstr);
    end
    plot(tU,HU{M}(:,1),'c','LineWidth',2);hold on;
    if strcmp(agent,'IRIS')
	plot(tA,HA(:,2),'b.','MarkerSize',10);hold on;
	plot(tA,HA(:,3),'k.','MarkerSize',10);hold on;	
	plot(tR,HR(:,2),'b','LineWidth',2)
	plot(tR,HR(:,3),'k','LineWidth',2);
	    legend(...
		modells,...
	        'H_{xy} OSU',...
	        'H_{yx} OSU',...
	        'H_{xy}',...
	        'H_{yx}'...
	    )
    else
    	plot(tR,HR(:,2),'b','LineWidth',2)
	plot(tR,HR(:,3),'k','LineWidth',2);
	legend(...
	    modells,...
	    'H_{xy}',...
	    'H_{yx}'...
	    )
    end		
end

if (dim == 2)
    fn = fn+1;
    figurex(fn);clf;hold on;grid on;
    if strcmp(agent,'IRIS')
	plot(tU,HU{M}(:,1),'c','LineWidth',2);hold on;
	plot(tA,HA(:,1),'m.','MarkerSize',10)
	plot(tA,HA(:,2),'b.','MarkerSize',10)
	plot(tA,HA(:,3),'k.','MarkerSize',10)
	plot(tA,HA(:,4),'r.','MarkerSize',10)
	plot(tR,HR(:,1),'m','LineWidth',2);hold on;
	plot(tR,HR(:,2),'b','LineWidth',2)
	plot(tR,HR(:,3),'k','LineWidth',2);hold on;
	plot(tR,HR(:,4),'r','LineWidth',2)
	legend(...
	    sprintf('H_0 %s',modelstr),...
	    'H_{xx} OSU','H_{xy} OSU','H_{yx} OSU','H_{yy} OSU',...
	    'H_{xx}','H_{xy}','H_{yx}','H_{yy}');
    else
	plot(tU,HU{M}(:,1),'c','LineWidth',2);hold on;
	plot(tR,HR(:,1),'m','LineWidth',2);hold on;
	plot(tR,HR(:,2),'b','LineWidth',2)
	plot(tR,HR(:,3),'k','LineWidth',2);hold on;
	plot(tR,HR(:,4),'r','LineWidth',2)
	legend(...
	    sprintf('H_0 %s',modelstr),...
	    'H_{xx}','H_{xy}','H_{yx}','H_{yy}');
    end
end
ylabel('[mV/km/nT]')
title(titlestr);    
set(gca,'XLim',[-5 10]*60)
set(gca,'XTick',[-6:2:10]*60)
if (ppd == 1440)
    xlabel('t [min]')
end
if (ppd == 1440*60)
    xlabel('t [s]')
end
fignames{fn} = sprintf('%s_%s_H_All_%s-%s',short,label,ts1,ts2);    
drawnow

h1 = figure(fn);
fn = fn+1;
h2 = figure(fn);clf
    objects=allchild(h1);
    copyobj(get(h1,'children'),h2);
    set(gca,'XLim',[-15 30])
    set(gca,'XTick',[-15:5:30])
fignames{fn} = sprintf('%s_%s_H_All_Zoom%s-%s',short,label,ts1,ts2);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figurex(fn);clf
    % Compare computed with USGS
    if (modelsf > 1)
	modells = sprintf('Z_0/%d %s',modelsf,modelstr);
    else
	modells = sprintf('Z_0 %s',modelstr);
    end
    loglog(1./f(1:10:end),abs(ZU{M}(1:10:end)),...
	   'c-','LineWidth',2,'MarkerSize',10);
    hold on;grid on;
    % Compare computed with IRIS
    if strcmp(agent,'IRIS')
	loglog(1./feA(2:end),abs(ZA(2:end,1)),'m.','MarkerSize',20);
	loglog(1./feA(2:end),abs(ZA(2:end,2)),'b.','MarkerSize',20);
	loglog(1./feA(2:end),abs(ZA(2:end,3)),'k.','MarkerSize',20);
	loglog(1./feA(2:end),abs(ZA(2:end,4)),'r.','MarkerSize',20);
    end
    if (dim == 1)
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,2)),...
	       'b','LineWidth',2);
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,3)),...
	       'k','LineWidth',2);
	if strcmp(agent,'IRIS')
	    legend(sprintf('Z_0 %s',modelstr),...
		   'Z_{xx} OSU','Z_{xy} OSU','Z_{yx} OSU','Z_{yy} OSU',...
		   'Z_{xy}','Z_{yx}')
	else
	    legend(...
		sprintf('Z_0 %s',modelstr),...
		'Z_{xy}','Z_{yx}')
	end
    end
    if (dim == 2)
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,1)),...
	       'm','LineWidth',2);
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,2)),...
	       'b','LineWidth',2);
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,3)),...
	       'k','LineWidth',2);
	loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,4)),...
	       'r','LineWidth',2);
	if strcmp(agent,'IRIS')	
	    legend(sprintf('Z_0 %s',modelstr),...
		   'Z_{xx} OSU','Z_{xy} OSU','Z_{yx} OSU','Z_{yy} OSU',...
		   'Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}')
	else
	    legend(sprintf('Z_0 %s',modelstr),...
		   'Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}')
	end
    end
    xlabel('T [s]')
    ylabel('[mV/km/nT]')
    title(titlestr);    
    fignames{fn} = sprintf('%s_%s_Z_vs_T_All_%s-%s',short,label,ts1,ts2);
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

break
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


break

    for i = 1:2
	fn = fn+1;
	figurex(fn);clf;orient landscape
	comp = 'x';if i == 2,comp = 'y';end
	bins = [-100:1:100];
	[nR,xR]  = hist(E(:,i)-EpR(:,i),bins);
	if strcmp(agent,'IRIS')	
	    [nA,xA]  = hist(E(:,i)-EpA(:,i),bins);
	end
	[nU,xU]  = hist(E(:,i)-EpU{M}(:,i),bins);
	
	%semilogy(xR,nR,'b.','MarkerSize',15);   
	negloglog(xR,nR,'',[1.2,0.25],'r');
	if strcmp(agent,'IRIS')	
	    %semilogy(xA,nA,'r.','MarkerSize',15);   
	    negloglog(xA,nA,'',[1.2,0.25],'g');
	end
	%semilogy(xU,nU,'r.','MarkerSize',15);   
	negloglog(xU,nU,sprintf('E_%s [mV/km/nT]',comp),[1.2,0.25],'b');

	if strcmp(agent,'IRIS')	
	    legend(sprintf('E_%s Error',comp),...
		   sprintf('OSU E_%s Error',comp),...
		   sprintf('%s E_%s Error',modelstr,comp));
	else
	    legend(sprintf('E_%s Error',comp),...
		   sprintf('%s E_%s Error',modelstr,comp));
	end	    

	fignames{fn} = sprintf('%s_Histogram_All_E%s_%s_%s-%s',...
			      short,comp,label,ts1,ts2);
	drawnow
    end    

