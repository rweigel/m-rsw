function zplanewavemodel_single(M,writeimgs)

addpath('../../plot');
addpath('../USGSModels');
addpath('../misc');

mu_0 = 4*pi*1e-7; % Vacuum permeability

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin == 0)
    writeimgs = 1;
    M = 'Q2';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rho,d,fs,ts,ls] = ModelInfo(M);
rho_h = [rho,d];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = logspace(-1,5,30);
f = 1./T;
h = rho_h(:,2)';
s = 1./rho_h(:,1)';

C    = zplanewave(s,h,f);
Z    = j*2*pi*f.*C;
Zmag = sqrt(Z.*conj(Z));

rho_a = C.*conj(C)*mu_0*2*pi.*f;
phi_C = (180/pi)*atan2(imag(C),real(C));
phi_Z = (180/pi)*atan2(imag(Z),real(Z));

legstr{1} =' $\|\widetilde{Z}\| = \|\widetilde{E_x}/\widetilde{B_y}\| = \omega\|\widetilde{C}\|\quad\mbox{[V/m/T]}$';
legstr{2} = ' $\rho_a = \omega\mu_0\|\widetilde{C}\|^2\quad\mbox{[}\Omega\cdot\mbox{m]}$';

figurex(1);clf;
    loglog(1./f,Zmag,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    loglog(1./f,rho_a,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    xlabel('Period [s]');
    title(ts);
    lh = legend(legstr{1},legstr{2},'Location','North');
    set(lh,'Interpreter','Latex');
    fname{1} = sprintf('./figures/zplanewave_%s_Z_vs_T',fs);
    drawnow
    
figurex(2);clf;
    loglog(f,Zmag,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    loglog(f,rho_a,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    xlabel('frequency [1/s]');
    title(ts);
    lh = legend(legstr{1},legstr{2},'Location','North');
    set(lh,'Interpreter','Latex');
    fname{2} = sprintf('./figures/zplanewave_%s_Z_vs_f',fs);
    drawnow
    
figurex(3);clf;
    semilogx(1./f,phi_Z,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    semilogx(1./f,phi_C,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    title(ts);
    set(gca,'YLim',[-90 90]);
    set(gca,'YTick',[-90:30:90]);
    xlabel('Period [s]');
    lh = legend(' $\phi_{\widetilde{Z}}\quad\mbox{[deg]}$',...
                ' $\phi_{\widetilde{C}}\quad\mbox{[deg]}$',...
                'Location','North');
    set(lh,'Interpreter','Latex');
    fname{3} = sprintf('./figures/zplanewave_%s_rho_a_vs_T',fs);
    drawnow
    
figurex(4);clf;
    semilogx(f,phi_Z,'k','LineWidth',3,'Marker','.','MarkerSize',20);
    hold on;
    semilogx(f,phi_C,'b','LineWidth',3,'Marker','.','MarkerSize',20);
    grid on;
    title(ts);
    set(gca,'YLim',[-100 100]);
    set(gca,'YTick',[-90:30:90]);
    xlabel('Frequency [1/s]');
    lh = legend(' $\phi_{\widetilde{Z}}\quad\mbox{[deg]}$',...
                ' $\phi_{\widetilde{C}}\quad\mbox{[deg]}$',...
                'Location','North');
    set(lh,'Interpreter','Latex');
    fname{4} = sprintf('./figures/zplanewave_%s_rho_a_vs_f',fs);
    drawnow
    
figurex(5);clf;
    if (length(h) == 1)
	d = [1 1e7];
    else
	d = cumsum(h(1:end-1));
	d = [10^(round(log10(d(1)))-1),d,10^(round(log10(d(end)))+1)];
    end
    s(end+1) = s(end);
    for i = 1:length(s)-1
        loglog([1/s(i),1/s(i)],[d(i),d(i+1)]/1e3,'k-','LineWidth',3);
        hold on;
        loglog([1/s(i),1/s(i+1)],[d(i+1),d(i+1)]/1e3,'k-','LineWidth',1);
    end
    grid on;box on
    set(gca,'YDir','reverse');
    %set(gca,'XAxisLocation','Top');
    xlabel('Resistivity [\Omega\cdotm]');
    ylabel('Depth [km]');
    title(ts);

    fname{5} = sprintf('./figures/zplanewave_%s_geometry',fs);

    xl = get(gca,'XLim') ;
    yl = get(gca,'YLim') ;
    xl(2) = 2.0*xl(2);
    set(gca,'XLim',xl);   
    set(gca,'YLim',yl);   
    ss = abs(log(1./s)/max(log(1./s)));
    ss = abs(ss-1);
    ss = ss + 1-max(ss);
    c  = repmat(ss(1),1,3);
    for i = 1:length(d)-1
	c  = repmat(ss(i),1,3);
	rh = patch([xl(1),xl(2),xl(2),xl(1)],[d(i)/1e3,d(i)/1e3,d(i+1)/1e3,d(i+1)/1e3],c); 

	set(rh,'EdgeColor',get(rh,'FaceColor'),'FaceAlpha',0.6);
    end

    for i = 1:length(s)-1
	if (1/s(i) >= 1e3)
	    expstr = sprintf('%.1g',1/s(i));
	    expstr = regexprep(expstr,'(.*)e\+0([0-9])$','$1\\cdot 10^{$2}');
	    expstr = regexprep(expstr,'(.*)e\-0([0-9])$','$1\\cdot 10^{-$2}');
	    expstr = regexprep(expstr,'1\\cdot ','');
	elseif (1/s(i) > 10)
	    expstr = sprintf('%.0f',1/s(i));
	else
	    expstr = sprintf('%.1f',1/s(i));
	    expstr = regexprep(expstr,'\.0$','');
	end

	loglog([1/s(i),1/s(i)],[d(i),d(i+1)]/1e3,'b-','LineWidth',3);
	hold on;
	loglog([1/s(i),1/s(i+1)],[d(i+1),d(i+1)]/1e3,'b-','LineWidth',1);
	if (length(s) < 100)
	    th = text(1/s(i),(d(i+1)+d(i))/(2*1e3),...
		      [sprintf('$\\mbox{ }%s ',expstr),...
		       '\mbox{ }\Omega\cdot \mbox{m}\mbox{ }$'],...
		      'Color','Black','Interpreter','Latex');
	    if (ss(i) < 0.3)
		set(th,'Color','White');
	    end
	    if (i == 1)
		set(th,'HorizontalAlignment','Right');
	    end
	end
    end
    drawnow
    
if (writeimgs)
    for i = 1:length(fname)
	figurex(i)
	if (i == 5)
	    orient tall
	    print('-dpng','-r600',[fname{i},'.png']);
	    print('-dsvg',[fname{i},'.svg']);
	    fprintf('Wrote %s.{png,svg}\n',fname{i});
	else
	    orient portrait
	    print('-dpng','-r600',[fname{i},'.png']);
	    print('-dpdf',[fname{i},'.pdf']);
	    fprintf('Wrote %s.{png,pdf}\n',fname{i});
	end

    end
end
