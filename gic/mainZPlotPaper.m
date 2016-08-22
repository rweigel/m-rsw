fn = 0;

% Note that x->y and y->x here because mainZ assumes x = east and y = north.
writeimgs = 1;

set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultAxesFontName', 'TimesNewRoman')
set(0,'defaultTextFontName', 'TimesNewRoman')

set(0,'defaultTextFontSize', 12)
set(0,'defaultAxesFontSize', 12)

shift = 200;

if (0)
L = size(E,1);
T = L/8;
t = [0:L-1]';
a = sin(2*pi*t/T);
b = a/10;
e = b-a;

fta = fft(a);
pa  = abs(fta);
pa = pa(1:N/2);

ftb = fft(b);
pb  = abs(ftb);
pb = pb(1:N/2);

fte = fft(e);
pe  = abs(fte);
pe = pe(1:N/2);

f = [0:N/2-1]/N;
clf;
loglog(f,pa/length(pa),'r-','MarkerSize',30);hold on;
loglog(f,pb/length(pb),'g-','MarkerSize',30);
loglog(f,pe/length(pe),'b-','MarkerSize',30);

break
end

if (0)
L = size(E,1);
T = L/2;
t = [0:L-1]';
B(:,1) = sin(2*pi*t/T);
B(:,2) = sin(2*pi*t/T);
B(:,3) = sin(2*pi*t/T);
ftX = fft(B(:,1));
pX  = abs(ftX);
f = [0:N/2-1]/N;
pX = pX(1:N/2);
clf;
loglog(1./f,pX(:,1),'b.','MarkerSize',30)
[fX,pX,fA,pA,p] = mainCompute(B,dB,E,Info.ppd);
hold on;grid on;
loglog(1./fX,pX(:,1),'g.','MarkerSize',10)
break
end

%fX = [0;fX];
%pX = [zeros(size(pX,2));pX];
%[pAs,fAs] = logsmooth(fX,pX(:,6+i));
yl = [-300,400];
shift = 200;
if strmatch(Sites{idx},'UTP17'),yl = [-30,30];,shift=15;,end
if strmatch(Sites{idx},'ORF03'),yl = [-30,30];,shift=15;,end
if strmatch(Sites{idx},'CON21'),yl = [-30,30];,shift=15;,end
if strmatch(Sites{idx},'RET54'),yl = [-300,400];,shift=200;,end
if strmatch(Sites{idx},'GAA54'),yl = [-30,40];,shift=20;,end


[fX,pX,fA,pA,p] = mainCompute(B(Iteo,:),dB(Iteo,:),E(Iteo,:),Info.ppd);

%[fX,pX,fA,pA,p] = mainCompute(B,dB,E,Info.ppd);
fn = fn+1;
figure(fn);clf;orient tall
%pbaspect([1,230/190,1])
subplot('position',subplotstack(3,1))
for i = 2:2
%    fn = fn+1;
%    figure(fn);clf;
    hold on;grid on;
    plot(1,NaN,'k','LineWidth',2) 
    plot(1,NaN,'g','LineWidth',2)  
    plot(1,NaN,'b','LineWidth',2)  
    plot(t,E(:,i),'k'); % Measured or filtered
    plot(t,Ep_U(:,i),'g');  % Predicted
    plot(t,E_U(:,i)-shift,'b'); % Error
    ylabel('[mV/km]')
    %title(titlestr);
    xl = get(gca,'XLim');
    axis([xl,yl])
    %text(3.75,350,'(a)')
    set(gca,'XTickLabel','');
    box on;
    comp = 'y';if (i == 2),comp = 'x';end
    legend(sprintf('E_%s',comp),...
	   sprintf('Method 1; PE = %.2f/%.2f',...
		   petr_U(i),pete_U(i)),...
	   sprintf('Error - %d',shift),...
	   'Location','NorthWest')
%	set(gca,'OuterPosition',[0 0.69 1 0.30])
    legend boxoff
    drawnow
end

subplot('position',subplotstack(3,2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot prediction vs model FDP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 2:2
    c = 'r';
    if (i == 2), c = 'g';, end;
        hold on;grid on;
        plot(1,NaN,'k','LineWidth',2)  
        plot(1,NaN,'g','LineWidth',2)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,E(:,i),'k'); % Measured or filtered
        plot(t,Ep_FDP(:,i),'g');  % Predicted
	plot(t,E_FDP(:,i)-shift,'b'); % Error
        %xlabel(xlab)
	ylabel('[mV/km]')
%	text(3.75,350,'(b)')
%	pbaspect([230,85,1])
	%title(titlestr);
	xl = get(gca,'XLim');
	axis([xl,yl])
	set(gca,'XTickLabel','');
	box on;
        comp = 'y';if (i == 2),comp = 'x';end
	legend(...
	    sprintf('E_%s',comp),...
	    sprintf('Method 2; PE = %.2f/%.2f',...
		    petr_FDP(i),pete_FDP(i)),...
	    sprintf('Error - %d',shift),...
	    'Location','NorthWest')
%	fignames{fn} = sprintf('%s_E%s_%s_predicted_Paper_%s-%s',...
%			       Info.short,comp,label,ts1,ts2);

	legend boxoff
    drawnow
end

subplot('position',subplotstack(3,3))
if strcmp(Info.agent,'IRIS')
    % Plot prediction vs OSU
    for i = 2:2
%	fn = fn+1;
%	figure(fn);clf;
        hold on;grid on;
        plot(1,NaN,'k','LineWidth',2)  
        plot(1,NaN,'g','LineWidth',2)  
	plot(1,NaN,'b','LineWidth',2)  
        hold on;grid on;
        plot(t,E(:,i),'k'); % Measured or filtered
        plot(t,Ep_O(:,i),'g');  % Predicted
	plot(t,E_O(:,i)-shift,'b'); % Error
        %xlabel(xlab)
	ylabel('[mV/km]')
	%title(titlestr);
	xl = get(gca,'XLim');
	axis([xl,yl])
	box on;
	xlabel(xlab)
%	text(3.75,350,'(c)')
        comp = 'y';if (i == 2),comp = 'x';end
	legend(...
	    sprintf('E_%s',comp),...
	    sprintf('Method 3; PE = %.2f/%.2f',...
		    petr_O(i),pete_O(i)),...
	    sprintf('Error - %d',shift),...
	    'Location','NorthWest')
	legend boxoff
%	fignames{fn} = sprintf('%s_%s_E%s_predicted_OSU_Paper_%s-%s',...
%			       Info.short,label,comp,ts1,ts2);
	drawnow
    end
end % if strcmp(Info.agent,'IRIS')    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fignames{fn} = sprintf('%s_%s_E%s_predicted_Combined_Paper_%s-%s',...
		       Info.short,label,comp,ts1,ts2);

set(0,'defaultTextFontSize', 16)
set(0,'defaultAxesFontSize', 16)

if (1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error spectra vs T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:2
    fn = fn+1;
    figure(fn);clf;orient landscape
    comp = 'x';if i == 2,comp = 'y';end
    %loglog(1./fA,pA(:,6+i),'k','MarkerSize',30,'LineWidth',2);
    %hold on;grid on;
    [pXs,fXs] = logsmooth(fX,pX(:,6+i));
    loglog(1./fXs,pXs,'k.','MarkerSize',30,'LineWidth',2);
    hold on;grid on;
    loglog(1./fte_U,EPte_U(:,i),'r.','MarkerSize',25,'LineWidth',2);
    loglog(1./fte_FDP,EPte_FDP(:,i),'b.','MarkerSize',25,'LineWidth',2);
    loglog(1./fte_O,EPte_O(:,i),'g.','MarkerSize',25,'LineWidth',2);
    axis tight;
    set(gca,'XTick',[1e1,1e2,1e3,1e4]);
    set(gca,'XLim',[9,2e4]);
    xlabel('Period [s]');
    ylabel('[mV/km]')
    %title(sprintf('E_%s',comp));
    pbaspect([1,230/190,1])
    legend(sprintf('E_%s Measured',comp),'Method 1 Error','Method 2 Error', ...
	   'Method 3 Error','Location','NorthWest');
    fignames{fn} = sprintf('%s_Error_Spectrum_All_Paper_E%s_%s_%s-%s',...
			   Info.short,comp,label,ts1,ts2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Histograms
for i = 1:2
	fn = fn+1;
	figure(fn);clf;
	comp = 'x';if i == 2,comp = 'y';end
	bins = logspace(-2,3,200);
	[nM,xM] = hist(abs(E(Ite,i)),bins);
	Ik = find(xM>1e-2);xM = xM(Ik);nM = nM(Ik);
	[nU,xU] = hist(E(Ite,i)-Ep_U(Ite,i),bins);
	Ik = find(xU>1e-2);xU = xU(Ik);nU = nU(Ik);
	if strcmp(Info.agent,'IRIS')	
	    [nO,xO] = hist(E(Ite,i)-Ep_O(Ite,i),bins);
	    Ik = find(xO>1e-2);xO = xO(Ik);nO = nO(Ik);
	end
	[nP,xP] = hist(abs(E(Ite,i)-Ep_FDP(Ite,i)),bins);
	Ik = find(xP>1e-2);xP = xP(Ik);nP = nP(Ik);
	loglog(xM,nM,'k.','MarkerSize',20);
	hold on;
	loglog(xU,nU,'r.','MarkerSize',20);
	loglog(xP,nP,'b.','MarkerSize',20);
	loglog(xO,nO,'g.','MarkerSize',20);
	%set(gca,'XLim',[1e-1,1e3])
	grid on;
	axis tight;
	pbaspect([1,230/190,1])
	set(gca,'XTick',[1e-1,1,1e1,1e2]);
	xlabel('[mV/m]');
	ylabel('# in bin');
	axis tight
	legend(sprintf('|E_%s| measured',comp),...
	       'Method 1 Error','Method 2 Error','Method 3 Error',...
	       'Location','SouthWest');
	fignames{fn} = sprintf('%s_Histogram_All_Paper_E%s_%s_%s-%s',...
			      Info.short,comp,label,ts1,ts2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (writeimgs)
  for i = [1:fn]
    figure(i);
    fig = gcf;
    %set(fig,'PaperUnits','inches');
    %set(fig,'PaperPosition',[0 0 6.5 2]);
    fname = sprintf('%s/%s/%s/figures/mainPlot_%s',...
		    Info.datadir,lower(Info.agent),Info.short,fignames{i});
    fprintf('mainPlot: Writing %s.{eps,png}\n',fname);
    print([fname,'.png'],'-dpng');
    print([fname,'.eps'],'-depsc');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

