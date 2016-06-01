break

if (0)
fn = fn+1;
figurex(fn);clf
    % Compare only USGS
    for m = 1:3%length(models)
	loglog(1./f(1:10:end),abs(ZU{i}(1:10:end)),'-','LineWidth',2);
	if (m == 1),hold on;grid on;end
    end
    loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,2)),'b','LineWidth',2);
    loglog(1./feR(2:end),2*pi*feR(2:end).*abs(ZR(2:end,4)),'r','LineWidth',2);

    xlabel('T [s]')
    ylabel('[mV/km/nT]')
    legend(models)
    %fname = sprintf('%s_%s_Z_vs_T_All_%s-%s',short,label,ts1,ts2);
    %plotcmds(fname,writeimgs)


end

if (0)
    fn = fn+1;
    figurex(fn);clf;
        hold on;grid on;
        plot(tR/60,HR(:,1),'m','LineWidth',2)
        plot(tR/60,HR(:,2),'b','LineWidth',2)
        plot(tR/60,HR(:,3),'k','LineWidth',2)
        plot(tR/60,HR(:,4),'r','LineWidth',2)
        title(tit)
        legend('H_{xx}','H_{xy}','H_{yx}','H_{yy}')
        set(gca,'XLim',[-10 20])
        set(gca,'XTick',[-10:5:20])
        xlabel('t [min]')
        fname = sprintf('%s_H_%s-%s',short,ts1,ts2);
        plotcmds(fname,writeimgs)

    fn = fn+1;
    figurex(fn);clf;
        loglog(NaN,0,'m','LineWidth',3);
        hold on;grid on;
        loglog(NaN,0,'b','LineWidth',3);
        loglog(NaN,0,'k','LineWidth',3)
        loglog(NaN,0,'r','LineWidth',3)
        loglog(feR(2:end),abs(ZR(2:end,1)),'m','LineWidth',2);
        loglog(feR(2:end),abs(ZR(2:end,2)),'b','LineWidth',2);
        loglog(feR(2:end),abs(ZR(2:end,3)),'k','LineWidth',2);
        loglog(feR(2:end),abs(ZR(2:end,4)),'r','LineWidth',2);
        %loglog(f(2:end),abs(ZRi(2:end,1)),'k.');
        title(tit)
        legend('Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}')
        xlabel('f [Hz]')
        fname = sprintf('%s_Z_vs_f_%s-%s',short,ts1,ts2);
        plotcmds(fname,writeimgs)

    fn = fn+1;
    figurex(fn);clf;
        loglog(NaN,0,'m','LineWidth',3);
        hold on;grid on;
        loglog(NaN,0,'b','LineWidth',3);
        loglog(NaN,0,'k','LineWidth',3)
        loglog(NaN,0,'r','LineWidth',3)
        loglog(1./feR(2:end),abs(ZR(2:end,1)),'m','LineWidth',2);
        loglog(1./feR(2:end),abs(ZR(2:end,2)),'b','LineWidth',2);
        loglog(1./feR(2:end),abs(ZR(2:end,3)),'k','LineWidth',2);
        loglog(1./feR(2:end),abs(ZR(2:end,4)),'r','LineWidth',2);
        %loglog(1./f(2:end),abs(ZRi(2:end,1)),'k.');
        title(tit)
        legend('Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}','Location','SouthEast')
        xlabel('T [s]')
        fname = sprintf('%s_Z_vs_T_%s-%s',short,ts1,ts2);
        plotcmds(fname,writeimgs)

    b = logspace(-7,-4);
    [NA,xA]   = hist(EpA(:,1)*1e3,b);
    [NU1,xU1] = hist(EpU1(:,1),b);
    [NU2,xU2] = hist(EpU2(:,1),b);
    [NM,xM]   = hist(E(:,1)+Ef(:,1),b)
     
    fn = fn+1;
    figurex(fn);
        clf;
        loglog(xM,NM,'k.','MarkerSize',20);hold on;grid on;
        loglog(xA,NA,'rx','MarkerSize',10);
        loglog(xU1,NU1,'g.','MarkerSize',20)
        loglog(xU2,NU2,'b.','MarkerSize',20)
        legend('Measured','OSU','USGS CP-1','USGS PT-1')
        xlabel('E_x [V/m]')
        ylabel('# in bin')

end

fn = fn+1;
figurex(fn);clf
    plot(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    plot(NaN,0,'k','LineWidth',3)
    plot(feR(2:end),PR(2:end,1),'m','LineWidth',2);
    plot(feR(2:end),PR(2:end,2),'b','LineWidth',2);
    plot(feR(2:end),PR(2:end,3),'k','LineWidth',2);
    plot(feR(2:end),PR(2:end,4),'r','LineWidth',2);
    title(tit)
    legend('\phi_{xx}','\phi_{xy}','\phi_{yx}','\phi_{yy}')
    xlabel('f [Hz]')
    fname{fn} = sprintf('%s_Phase_vs_f_%s_%s_%s_%s-%s',...
			short,dim,meth,instr,ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figurex(fn);clf
    semilogx(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    semilogx(NaN,0,'k','LineWidth',3)
    semilogx(1./feR(2:end),PR(2:end,1),'m','LineWidth',2);
    semilogx(1./feR(2:end),PR(2:end,2),'b','LineWidth',2);
    semilogx(1./feR(2:end),PR(2:end,3),'k','LineWidth',2);
    semilogx(1./feR(2:end),PR(2:end,4),'r','LineWidth',2);
    title(tit)
    legend('\phi_{xx}','\phi_{xy}','\phi_{yx}','\phi_{yy}')
    xlabel('T [s]')
    fname{fn} = sprintf('%s_Phase_vs_T_%s_%s_%s_%s-%s',short,dim,meth,instr,ts1,ts2);
    plotcmds(fname,writeimgs)

t = [0:size(E,1)-1]'/86400;

ts1 = datestr(dn(1),30);
ts2 = datestr(dn(end),30);

% Plot input and output on same scale
for i = 1:2
    fn = fn+1;
    figurex(fn);clf;
        plot(NaN,0,'g','LineWidth',3);
        hold on;grid on;
        plot(NaN,0,'m','LineWidth',3)
        if (i == 1)
            plot(t,IN(:,2),'g');
            plot(t,E(:,1),'m');
            legend(INs{2},'E_x')
	    fname{fn} = sprintf('%s_E_x_%s_%s_%s_%s-%s',...
				short,dim,meth,instr,ts1,ts2);
        else
            plot(t,IN(:,1),'g');
            plot(t,E(:,2),'m');
            legend(INs{1},'E_y')
	    fname{fn} = sprintf('%s_E_x_%s_%s_%s_%s-%s',...
				short,dim,meth,instr,ts1,ts2);
        end

        xlabel(xlab)
        title(tit)
        plotcmds(fname,writeimgs)
end

% Plot prediction vs model
for i = 1:2
    fn = fn+1;
    figurex(fn);clf;
        hold on;grid on;
        plot(1,NaN,'m','LineWidth',3)  
        plot(1,NaN,'k','LineWidth',3)  
        plot(1,NaN,'r','LineWidth',3)  
        plot(1,NaN,'g','LineWidth',3)  
        plot(t,(E(:,i)+Ef(:,i)),'m')  
        plot(t,E(:,i),'k')
        plot(t,real(EpR(:,i)),'r')
        plot(t,real(EpA(:,2))*1e3,'g')
        xlabel(xlab)
        ylabel('V/m')
        title(tit)
        comp = 'x';if (i == 2),comp = 'y';end
        legend(...
                ['E_',comp,' measured'],...
                ['E_',comp,' filtered'],...
                sprintf('E_%s predicted; PE = %.2f',comp,pev(i)),...
                sprintf('E_%s predicted OSU; PE = %.2f',comp,pevA(i)),...
                sprintf('E_%s predicted CP1; PE = %.2f',comp,pevU1(i))...
            )
    fname{fn} = sprintf('%s_E%s_predicted_%s_%s_%s_%s-%s',...
			short,dim,meth,instr,ts1,ts2);
    
    plotcmds(fname,writeimgs)
end

if (writeimgs)
    for i = 1:length(fname)
	figurex(i)
	print('-dpng','-r300',[fname{i},'.png']);
	print('-dpdf',[fname{i},'.pdf']);
	fprintf('Wrote %s.{png,pdf}\n',fname{i});
    end
end

break

% 1 day of predictions per plot
ta = [0:size(E,1)-1]'/3600;
Nd = floor(size(E,1)/86400);

for j = [1:Nd]
    I = [86400*(j-1)+1:86400*j];
    t = ta(I)-ta(I(1));
    for i = 1:2
        pev(i) = pe(E(I,i)-Ef(I,i),EpR(I,i));
        comp = 'x';
        if (i == 2)
            comp = 'y';
        end
        fprintf('dir = %s\tNf = %04d\tpe = %0.2f\n',comp,Nf,pev(i))
        
        fn = fn+1;
        figurex(fn);clf;
            
            plot(NaN,0,'b','LineWidth',3);hold on 
            plot(NaN,0,'k','LineWidth',3)  
            plot(NaN,0,'r','LineWidth',3)  

            plot(t,E(I,i),'b')  
            hold on;grid on;
            plot(t,E(I,i)-Ef(I,i),'k')
            plot(t,real(EpR(I,i)),'r')
            title(tit)
            xlab = ['Hours since ',datestr(dn(I(1)))];
            xlabel(xlab)
            set(gca,'XTick',[0:4:24])
            set(gca,'XLim',[0 24])
            legend(...
                    ['E_',comp,' measured'],...
                    ['E_',comp,' filtered'],...
                    sprintf('E_%s predicted; PE = %.2f',comp,pev(i))...
                )
            title(tit)
            ts = datestr(dn(I(1)),30);
            fname = sprintf('%s_E%s_predicted_%s',short,comp,ts);
            plotcmds(fname,writeimgs)
    end
end

fprintf('%s\n',repmat('-',80,1))
