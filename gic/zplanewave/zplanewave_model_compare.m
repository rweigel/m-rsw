clear;
addpath('../../plot');
addpath('../misc');

writeimgs = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Models to compare
models     = {'Q1','CO1','BR1'};
fnamebase  = models{1};
for i = 2:length(models)
    fnamebase = [fnamebase,'_',models{i}];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = logspace(-1,5,30);
f = 1./T;
mu_0 = 4*pi*1e-7; % Vacuum permeability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmp1 = ' $\|\widetilde{Z}\| = \|\widetilde{E_x}/\widetilde{B_y}\|';
tmp2 = '= \omega\cdot\|\widetilde{C}\|\quad\mbox{[V/m/T]}$';
legstr{1} = [tmp1,tmp2];

figurex(1);clf;
figurex(2);clf;
figurex(3);clf;
figurex(4);clf;
figurex(5);clf;
for i = 1:length(models)
    [rho,d,shortstr,longstr,legendstr] = ModelInfo(models{i});
    legendstrings{i} = legendstr;
    rho_h = [rho,d];
    
    C{i}    = zplanewave(1./rho_h(:,1)',rho_h(:,2)',f);
    Z{i}    = j*2*pi*f.*C{i};
    Zmag{i} = sqrt(Z{i}.*conj(Z{i}));

    rho_a{i} = C{i}.*conj(C{i})*mu_0*2*pi.*f;
    phi_C{i} = (180/pi)*atan2(imag(C{i}),real(C{i}));
    phi_Z{i} = (180/pi)*atan2(imag(Z{i}),real(Z{i}));
    
    figurex(1);
	loglog(1./f,Zmag{i},'-','LineWidth',2);
	hold on;grid on;
	xlabel('Period [s]');
	if 0
	    yl = get(gca,'YLim');
	    xl = get(gca,'XLim');
	    text(xl(1),yl(2),...
		 ' $\|\widetilde{Z}\|$ [V/m/T]','Interpreter','Latex',...
		 'VerticalAlignment','bottom');
	end
	%ylabel(' $\|\widetilde{Z}\|$ [V/m/T]','Interpreter','Latex');
	set(gca,'XLim',[min(1./f),max(1./f)])

    figurex(2);
	loglog(f,Zmag{i},'LineWidth',2);
	hold on;grid on;
	set(gca,'XLim',[min(f),max(f)])
	xlabel('Frequency [1/s]');
	ylabel(' $\|\widetilde{Z}\|$ [V/m/T]','Interpreter','Latex');

    figurex(3);
        semilogx(1./f,phi_Z{i},'LineWidth',2);
	hold on;grid on;
	ylabel(' $\phi_{\|\widetilde{Z}\|}$ [deg]','Interpreter','Latex');
	set(gca,'YLim',[-90 180]);
	xlabel('Period [s]');
	set(gca,'XLim',[min(1./f),max(1./f)])	
	
    figurex(4);
        semilogx(f,phi_Z{i},'LineWidth',2);
	hold on;grid on;
	ylabel(' $\phi_{\|\widetilde{Z}\|}$ [deg]','Interpreter','Latex');
	set(gca,'YLim',[-90 180]);
	xlabel('Frequency [1/s]');
	set(gca,'XLim',[min(f),max(f)])
	
    c = get(gca,'ColorOrder');
    figurex(5);
        h = rho_h(:,2)';
	s = 1./rho_h(:,1)';
	%axis([.7 1.1*10^4 1 1.1*10^4]);

	if (i == 1)
	    for z = 1:3
		loglog([1,1],[NaN,NaN],'Color',c(z,:),'LineWidth',2);
		hold on;grid on;
	    end
	    ax = gca;ax.ColorOrderIndex = 1;
	end
	
	if (length(s) > 1)
	    d = cumsum(h(1:end-1));
	    d = [10^(round(log10(d(1)))-1),d,10^(round(log10(d(end)))+1)];
	    s(end+1) = s(end);
	    for j = 1:length(s)-1
		loglog([1/s(j),1/s(j)],[d(j),d(j+1)]/1e3,...
		       'Color',c(i,:),'LineWidth',2);
		if (i==1),hold on;grid on;end		
		loglog([1/s(j),1/s(j+1)],[d(j+1),d(j+1)]/1e3,...
		       'Color',c(i,:),'LineWidth',1);
	    end
	    set(gca,'YDir','reverse');
	    xlabel('Resistivity [\Omega\cdotm]');
	    ylabel('Depth [km]');
	else
	    loglog([1/s(1),1/s(1)],[1,10^4],'Color',c(i,:),'LineWidth',2);
	end
end

fname{1} = sprintf('z_planewave_model_compare_Z_vs_T_%s',fnamebase);
fname{2} = sprintf('z_planewave_model_compare_Z_vs_f_%s',fnamebase);
fname{3} = sprintf('z_planewave_model_compare_phi_vs_T_%s',fnamebase);
fname{4} = sprintf('z_planewave_model_compare_phi_vs_f_%s',fnamebase);
fname{5} = sprintf('z_planewave_model_compare_depth_vs_rho_%s',fnamebase);

figurex(1);
    legend(legendstrings,'Location','North');
figurex(2);
    legend(legendstrings,'Location','North');
figurex(3);
    legend(legendstrings,'Location','North');
figurex(4);
    legend(legendstrings,'Location','North');
figurex(5);
    legend(legendstrings,'Location','SouthEast');

if (writeimgs)
    for i = 1:length(fname)
	figurex(i)
	print('-dpng','-r300',[fname{i},'.png']);
	print('-dpdf',[fname{i},'.pdf']);
	fprintf('Wrote %s.{png,pdf}\n',fname{i});
    end
end
