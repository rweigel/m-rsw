function [zp1,tp1,zn1,tn1] = stocks(symbol,symbolref,opts)
% Considers percentage price changes after high or low returns in
% stock, DJIA, and stock relative to DJIA.

% Related research
% http://www.sciencedirect.com/science/article/pii/016541019290023U
% http://www.sciencedirect.com/science/article/pii/016541019090008R

% List of companies in the DJIA:
% http://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average

% Current list of symbols for stocks in DJIA.
% http://finance.yahoo.com/q/cp?s=%5EDJI+Components

% Signal = 0 => abs( delta(symbol)/symbol ) > T
% Signal = 1 => abs( delta(symbol)/symbol - delta(symbolref)/symbolref ) > T

T = opts.T;
dt = opts.dt;
signal = opts.signal;

showsigs  = 1;
showall   = 0; % List all stock prices (if 0, only show when change occurs).
saveplots = 0; % Print eps and png of figure
showplots = 1;

S1   = stocks_prep(symbol);    % Get data for stock
S2   = stocks_prep(symbolref); % Get ref data

symbol = strrep(symbol,'^','');
symbolref = strrep(symbolref,'^','');

dno1 = datenum(S1(1,1));      
dno2 = datenum(S2(1,1));
dno  = max(dno1,dno2);          

dnf1 = datenum(S1(end,1));      
dnf2 = datenum(S2(end,1));
dnf  = min(dnf1,dnf2);          

tg  = [1:dnf-dno+1];            % Time grid

% Put data on uniform time grid. NaN values are inserted on days where
% no values are reported.  (DJI has data on more days than its
% components - sometimes DJI values are reported on non-trading days.).
I2o = find(S2(:,1) == dno);
I2f = find(S2(:,1) == dnf);

t2x = S2(I2o:I2f-dt-1,1);
t2x = t2x-t2x(1)+1;
if (strmatch(symbolref,'DJI'))
    S2x = S2(I2o:I2f-dt-1,5);         
else
    S2x = S2(I2o:I2f-dt-1,7); % 7th column for DJI is closing value
end
S2  = NaN*zeros(length(tg),1);  % Array of NaNs
S2(t2x) = S2x;                  % Fill S2 on days when data available

I1o = find(S1(:,1) == dno);
I1f = find(S1(:,1) == dnf);

t1x = S1(I1o:I1f-dt-1,1);
t1x = t1x-t1x(1)+1;
S1x = S1(I1o:I1f-dt-1,7);             % 7th column for stocks is adjusted close
S1  = NaN*zeros(length(tg),1);
S1(t1x) = S1x;

% Remove NaNs
I = find(~isnan(S1+S2));
S1 = S1(I);
S2 = S2(I);
tg = tg(I);

if (0) % Inspect each value to verify correct alignment of times.
    for i = 1:min(length(S1),length(S2))-1
        fprintf('%d %s %s %8.2f %8.2f\n',tg(i)-tg(i),...
                datestr(dno+tg(i)-1),datestr(dno+tg(i)-1),...
                S2(i),S1(i));
    end
end

fprintf('    date(i)      S1(i)  S1(i+1) dS1(i+1)    S2(i)  S2(i+1) dS2(i+1)  dS(i+1)\n');
for i = 1:length(S1)-dt
    
    dS1(i+1) = 100*(S1(i+1)-S1(i))/S1(i);
    dS2(i+1) = 100*(S2(i+1)-S2(i))/S2(i);
    dS(i+1)  = dS2(i+1)-dS1(i+1);

    if (dS1(i+1) > T)
        if (showsigs)
            fprintf('+ %s %8.2f %8.2f %+8.2f %8.1f %8.1f %+8.2f %+8.2f\n',...
                datestr(dno+tg(i)-1),S1(i),S1(i+1),dS1(i+1),S2(i),S2(i+1),dS2(i+1),dS(i+1));
        end
    else
        if (showall)
            fprintf('  %s %8.2f %8.2f %+8.2f %8.1f %8.1f %+8.2f %+8.2f\n',...
                datestr(dno+tg(i)-1),S1(i),S1(i+1),dS1(i+1),S2(i),S2(i+1),dS2(i+1),dS(i+1));
        end
    end    
    if (dS1(i+1) < -T)
        if (showsigs)
            fprintf('- %s %8.2f %8.2f %+8.2f %8.1f %8.1f %+8.2f %+8.2f\n',...
                datestr(dno+tg(i)-1),S1(i),S1(i+1),dS1(i+1),S2(i),S2(i+1),dS2(i+1),dS(i+1));
        end
    else
        if (showall)
            fprintf('  %s %8.2f %8.2f %+8.2f %8.1f %8.1f %+8.2f %+8.2f\n',...
                datestr(dno+tg(i)-1),S1(i),S1(i+1),dS1(i+1),S2(i),S2(i+1),dS2(i+1),dS(i+1));
        end
    end
    
end

fprintf('    date(i)      S1(i)  S1(i+1) dS1(i+1)    S2(i)  S2(i+1) dS2(i+1)  dS(i+1)\n');

% Find indices where threshold crossed.
Ip2 = find(dS2 >  T); % Index positive of second stock.
In2 = find(dS2 < -T);
Ip1 = find(dS1 >  T);
In1 = find(dS1 < -T);
Ip  = find(dS  >  T);
In  = find(dS  < -T);

if (signal == 0) % Comparison
    Irp = Ip;
    Irn = In;
    ref = '\DeltaS';
end
if (signal == 1)
    Irp = Ip1;
    Irn = In1;
    ref = ['\Delta',symbol,'/',symbol];
end
if (signal == 2)
    Irp = Ip2;
    Irn = In2;
    ref = ['\Delta',symbolref,'/',symbolref];
end

% Remove threshold crossings where evaluation time is after
% that of available data.
ik  = find(Irp + dt <= length(dS1));
Irp = Irp(ik);
ik  = find(Irn + dt <= length(dS1));
Irn = Irn(ik);

if ~isempty(Irp) & length(Irp) > 0
    zp2 = 0;
    zp1 = 0;
    zp  = 0;
    for k = 0:dt-1
        zp2 = zp2 + dS2(Irp+dt-k);
        zp1 = zp1 + dS1(Irp+dt-k);
        zp  = zp  + dS(Irp+dt-k);
    end
    tp2 = dno+tg(Irp+dt)-1;
    tp1 = dno+tg(Irp+dt)-1;
    tp  = dno+tg(Irp+dt)-1;
else
    zp2 = NaN;
    zp1 = NaN;
    zp  = NaN;

    tp2 = NaN;
    tp1 = NaN;
    tp  = NaN;    
end

if ~isempty(Irn) & length(Irn) > 0
    zn2 = 0;
    zn1 = 0;
    zn  = 0;
    for k = 0:dt-1
        zn2 = zn2 + dS2(Irn+dt-k);
        zn1 = zn1 + dS1(Irn+dt-k);
        zn  = zn  + dS(Irn+dt-k);
    end
    tn2 = dno+tg(Irn+dt)-1;
    tn1 = dno+tg(Irn+dt)-1;
    tn  = dno+tg(Irn+dt)-1;
else
    zn2 = NaN;
    zn1 = NaN;
    zn  = NaN;

    tn2 = NaN;
    tn1 = NaN;
    tn  = NaN;    
end

if showplots == 0
    return;
end
figure(1);clf;hold on;grid on;

    zp2c = cumsum(zp2);
    zn2c = cumsum(zn2);
    zp1c = cumsum(zp1);
    zn1c = cumsum(zn1);
    zpc = cumsum(zp);
    znc = cumsum(zn);

    z1 = cumsum(dS1);
    t1 = dno+tg(1:length(z1))-1;
    z2 = cumsum(dS2);
    t2 = dno+tg(1:length(z2))-1;

    stairs(tp2,zp2c,'r','LineWidth',4);
    stairs(tn2,zn2c,'g','LineWidth',4);
    stairs(tp1,zp1c,'r','LineWidth',2);
    stairs(tn1,zn1c,'g','LineWidth',2);
    stairs(tp,zpc,'r','LineWidth',1);
    stairs(tn,znc,'g','LineWidth',1);

    stairs(t1,z1,'-','Color',[1,1,1]*0.5);
    stairs(t2,z2,'-','Color',[1,1,1]*0.5);

    set(gca,'FontSize',12);

    th = title(sprintf('dt = %d; \\DeltaS = \\Delta%s/%s - \\Delta%s/%s',dt,symbolref,symbolref,symbol,symbol));
    set(th,'FontSize',16);
    lh = legend(...
            [' \Delta',symbolref,'/',symbolref,' after ',ref,' > ',num2str(T),'%'],...
            [' \Delta',symbolref,'/',symbolref,' after ',ref,' < -',num2str(T),'%'],...
            [' \Delta',symbol,'/',symbol,' after ',ref,' > ',num2str(T),'%'],...
            [' \Delta',symbol,'/',symbol,' after ',ref,' < -',num2str(T),'%'],...
            [' \DeltaS after ',ref,' > ',num2str(T),'%'],...
            [' \DeltaS after ',ref,' < -',num2str(T),'%']);
    set(lh,'FontSize',14);
    set(lh,'Location','SouthWest');
    datetick('x','yy');

    if (1)
    text(tp2(end),zp2c(end),sprintf(' N=%d,\\mu=%.2f',length(zp2),zp2c(end)/length(zp2)))
    text(tn2(end),zn2c(end),sprintf(' N=%d,\\mu=%.2f',length(zn2),zn2c(end)/length(zn2)))
    text(tp1(end),zp1c(end),sprintf(' N=%d,\\mu=%.2f',length(zp1),zp1c(end)/length(zp1)))
    text(tn1(end),zn1c(end),sprintf(' N=%d,\\mu=%.2f',length(zn1),zn1c(end)/length(zn1)))
    text(tp(end),zpc(end),sprintf(' N=%d,\\mu=%.2f',length(zp),zpc(end)/length(zp)))
    text(tn(end),znc(end),sprintf(' N=%d,\\mu=%.2f',length(zn),znc(end)/length(zn)))
    text(t1(end),z1(end),sprintf(' %s, N=%d,\\mu=%.2f',symbol,length(z1),z1(end)/length(z1)))
    text(t2(end),z2(end),sprintf(' %s, N=%d,\\mu=%.2f',symbolref,length(z2),z2(end)/length(z2)))
    end

    if (saveplots)
        fprintf('Writing png and eps files ...\n');
        %print('-depsc',sprintf('./figures/stocks_%s_%d.eps',symbol,comp));
        print('-dpng','-r600',sprintf('./figures/stocks_%s_T-%d_dt-%d_C-%d.png',symbol,T,dt,signal));
        fprintf('Done.\n');
    end