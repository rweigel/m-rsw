
N   = size(B,1);
f   = [0:N/2]'/N;

IN   = dB;
INs  = labels(4:5);
INs2 = labels2(4:5);

meth = 'rectangular';
df   = 100;
tit  = sprintf('%s; Input = dB/dt; Method = Rectangular; df = %d',short,df);

ts1 = datestr(dn(1),30);
ts2 = datestr(dn(end),30);

[ZR,feR] = transferfnFD(IN,E,1,meth,df);
HR       = Z2H(feR,ZR,f);
HR       = fftshift(HR,1);
NR       = (size(HR,1)-1)/2;
tR       = [-NR:NR]';

% Interpolate transfer function onto original frequency grid
ZRi = Zinterp(feR,ZR,f);

% Predict using interpolated transfer function
EpR = Zpredict(feR,ZR,IN);

% Transfer Function Phase
PR  = (180/pi)*atan2(imag(ZR),real(ZR));

fn = 0;

fn = fn+1;
figure(fn);clf;
    loglog(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    loglog(NaN,0,'k','LineWidth',3)
    loglog(feR(2:end),abs(ZR(2:end,2)),'b');%.','LineWidth',1,'MarkerSize',5);
    loglog(feR(2:end),abs(ZR(2:end,3)),'k');%,'LineWidth',1,'MarkerSize',5);
    title(tit)
    legend('Z_{xy}','Z_{yx}')
    xlabel('f [Hz]')
    fname = sprintf('%s_Z_vs_f_%s-%s',short,ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figure(fn);clf;
    loglog(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    loglog(NaN,0,'k','LineWidth',3)
    loglog(1./feR(2:end),abs(ZR(2:end,2)),'b');
    loglog(1./feR(2:end),abs(ZR(2:end,3)),'k');
    title(tit)
    legend('Z_{xy}','Z_{yx}')
    xlabel('T [s]')
    fname = sprintf('%s_Z_vs_T_%s-%s',short,ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figure(fn);clf
    plot(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    plot(NaN,0,'k','LineWidth',3)
    plot(feR(2:end),PR(2:end,2),'b');
    plot(feR(2:end),PR(2:end,3),'k');
    title(tit)
    legend('\phi_{xy}','\phi_{yx}')
    xlabel('f [Hz]')
    fname = sprintf('%s_Phase_vs_f_%s-%s',short,ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figure(fn);clf
    semilogx(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    semilogx(NaN,0,'k','LineWidth',3)
    semilogx(1./feR(2:end),PR(2:end,2),'b');
    semilogx(1./feR(2:end),PR(2:end,3),'k');
    title(tit)
    legend('\phi_{xy}','\phi_{yx}')
    xlabel('T [s]')
    fname = sprintf('%s_Phase_vs_T_%s-%s',short,ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figure(fn);clf;
    plot(NaN,0,'b','LineWidth',3);
    hold on;grid on;
    plot(NaN,0,'k','LineWidth',3)
    plot(tR/60,HR(:,2),'b','LineWidth',2)
    plot(tR/60,HR(:,3),'k','LineWidth',2)
    title(tit)
    legend('H_{xy}','H_{yx}')
    set(gca,'XLim',[-10 20])
    set(gca,'XTick',[-10:5:20])
    xlabel('t [min]')
    fname = sprintf('%s_H_%s-%s',short,ts1,ts2);
    plotcmds(fname,writeimgs)

if (0) % Brute force method to determine optimal Nf
    Nfo = 3600;
    for Nf = [Nfo/100:100:Nfo*10]
        f = exp(-[0:Nf]/Nf);
        Ef(:,2) = filter([0,f/sum(f)],1,E(:,2));
        pev = pe(E(:,2)-Ef(:,2),EpR(:,2));
        fprintf('Nf = %04d\tpe = %0.2f\n',Nf,pev)
    end
end

Nf      = 2600;
f       = exp(-[0:Nf]/Nf);
Ef(:,1) = filter([0,f/sum(f)],1,E(:,1));
Ef(:,2) = filter([0,f/sum(f)],1,E(:,2));

pev(1) = pe(E(:,1)-Ef(:,1),EpR(:,1));
fprintf('x: Nf = %04d\tpe = %0.2f\n',Nf,pev(1))
pev(2) = pe(E(:,2)-Ef(:,2),EpR(:,2));
fprintf('y: Nf = %04d\tpe = %0.2f\n',Nf,pev(2))

t = [0:size(E,1)-1]'/86400;

fn = fn+1;
figure(fn);clf;
    plot(NaN,0,'g','LineWidth',3);
    hold on;grid on;
    plot(NaN,0,'m','LineWidth',3)
    plot(t,IN(:,2),'g');
    plot(t,E(:,1),'m');
    legend(INs{2},'E_x')
    xlabel(xlab)
    fname = sprintf('%s_%s_E_x_%s-%s',short,INs2{2},ts1,ts2);
    plotcmds(fname,writeimgs)

fn = fn+1;
figure(fn);clf;
    plot(NaN,0,'g','LineWidth',3)
    hold on;grid on;
    plot(NaN,0,'m','LineWidth',3)
    plot(t,IN(:,1),'g');
    plot(t,E(:,2),'m');
    legend(INs{1},'E_y')
    xlabel(xlab)
    ts1 = datestr(dn(1),30);
    ts2 = datestr(dn(end),30);
    fname = sprintf('%s_%s_E_y_%s-%s',short,INs2{1},ts1,ts2);
    plotcmds(fname,writeimgs)

for i = 1:2
    fn = fn+1;
    figure(fn);clf;
        plot(t,E(:,i),'m')  
        hold on;grid on;
        plot(t,E(:,i)-Ef(:,i),'k')
        plot(t,real(EpR(:,i)),'r')
        xlabel(xlab)
        comp = 'x';if (i == 2),comp = 'y';end
        legend(...
                ['E_',comp,' measured'],...
                ['E_',comp,' filtered'],...
                sprintf('E_%s predicted; PE = %.2f',comp,pev(i))...
            )
    ts1 = datestr(dn(1),30);
    ts2 = datestr(dn(end),30);
    fname = sprintf('%s_E%s_predicted_%s-%s',short,comp,ts1,ts2);
    plotcmds(fname,writeimgs)
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

        figure(fn+i);clf;
            plot(NaN,0,'b','LineWidth',3);hold on 
            plot(NaN,0,'k','LineWidth',3)  
            plot(NaN,0,'r','LineWidth',3)  

            plot(t,E(I,i),'m')  
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

