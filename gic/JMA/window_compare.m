clear

interval = 11;
site = 'mmb';

[t,E,B,datakey] = main_data(interval,site);
dateo = datestr(t(1),'yyyy-mm-dd');
datef = datestr(t(end),'yyyy-mm-dd');

if size(B,1)/86400 > 27
    B = B(1:27*86400,:);
    E = E(1:27*86400,:);
    t = t(1:27*86400);
end

[E,B] = removemean(E,B);

opts = main_options(1);
a = opts.td.Ntrim;
b = size(B,1)-a;

[Nf,fef] = smoothSpectra(E(a:b,:));
comp = ['x','y'];

d = 0;
for v = [1,9,27]
    d = d+1;
    W(d) = v;
    opts.td.window.width = 86400*v;
    opts.td.window.shift = 86400*v;
    opts.fd.regression.method = 3;
    opts.td.pad = 0;
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';

    m = 1;
        methods{m} = 'Robust';
        Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
        if size(Sc{d,m}.In,3) > 1
            Sa{d,m} = transferfnAverage(Sc{d,m},opts);
            transferfnSummary(Sc{d,m},Sa{d,m},methods{m});
            Z{d,m} = Sa{d,m}.Mean.Z;
            fe{d,m} = Sa{d,m}.Mean.fe;
        else
            Z{d,m} = Sc{d,m}.Z;
            fe{d,m} = Sc{d,m}.fe;
        end

    if 1
        m = 2;
            methods{m} = 'Robust No Stack';
            Sc{d,m} = transferfnFD2(Sc{d,1},opts);
                Z{d,m} = Sc{d,m}.Robust1.Z;
                fe{d,m} = Sc{d,m}.Robust1.fe;

        m = 3;
            methods{m} = 'Robust Pad';
            opts.td.pad = 86400*v;
            Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
            if size(Sc{d,m}.In,3) > 1
                Sa{d,m} = transferfnAverage(Sc{d,m},opts);
                transferfnSummary(Sc{d,m},Sa{d,m},methods{m});
                Z{d,m} = Sa{d,m}.Mean.Z;
                fe{d,m} = Sa{d,m}.Mean.fe;
            else
                Z{d,3} = Sc{d,3}.Z;
                fe{d,3} = Sc{d,3}.fe;
            end

        m = 4;
            methods{m} = 'Robust 10/decade';
            opts.td.pad = 0;
            opts.fd.evalfreqN = 10;
            Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
            if size(Sc{d,m}.In,3) > 1
                Sa{d,m} = transferfnAverage(Sc{d,m},opts);
                transferfnSummary(Sc{d,m},Sa{d,m},methods{1});
                Z{d,m} = Sa{d,m}.Mean.Z;
                fe{d,m} = Sa{d,m}.Mean.fe;
            else
                Z{d,m} = Sc{d,m}.Z;
                fe{d,m} = Sc{d,m}.fe;
            end
    end

    % Get padding for fprintf.
    for m = 1:length(methods)
        L(m) = length(methods{m});
    end
    mL = max(L);
    for m = 1:length(methods)
        pad{m} = repmat(' ',1, mL - length(methods{m}));
    end

    In = Sc{1,1}.In;
    Out = Sc{1,1}.Out;
    as = 600;
    bs = size(In,1)-as;
    %Z{1,1}(19,:) = Z{4,1}(29,:);
    for i = 1:size(Z,2) % Loop over methods
        for s = 1:size(Sc{1,1}.In,3) % Loop over segments
            [Ns,fes] = smoothSpectra(Out(as:bs,:,s));
            Eps{d,i} = Zpredict(fe{d,i},Z{d,i},In(:,:,s));
            sns(:,:,s) = Ns./smoothSpectra(Out(as:bs,:,s)-Eps{d,i}(as:bs,:));
        end
        SNs{d,i} = mean(sns, 3);
    end 

    for i = 1:size(Z,2) % Loop over methods
        Ep{d,i} = Zpredict(fe{d,i},Z{d,i},B(:,1:2));
        SNf{d,i} = Nf./smoothSpectra(E(a:b,:)-Ep{d,i}(a:b,:));
        M{d,i}(1,:) = pe(E(a:b,:),Ep{d,i}(a:b,:));
        M{d,i}(2,:) = cc(E(a:b,:),Ep{d,i}(a:b,:));
        M{d,i}(3,:) = mse(E(a:b,:),Ep{d,i}(a:b,:));
        for j = 1:2
            LL{d,i,j} = sprintf('%s %sw = %d; PE/CC/MSE = %.2f/%.2f/%.2f',...
                methods{i},pad{m},W(d),M{d,i}(:,j)'); 
            fprintf('%s %s\n',comp(j),LL{d,i,j});
        end
    end
end


if 0
    % Use optimization to adjust parameter value
    for d = 1:1
        z = Z{1,1};
        z(19,:) = Z{4,1}(31,:);
        for i = 1:size(Z,2) % Loop over methods
            for s = 1:size(Sc{1,1}.In,3) % Loop over segments
                [Ns,fes] = smoothSpectra(Out(as:bs,:,s));
                Eps{d,i} = Zpredict(fe{d,i},z,In(:,:,s));
                sns(:,:,s) = Ns./smoothSpectra(Out(as:bs,:,s)-Eps{d,i}(as:bs,:));
            end
            SNs{d,i} = mean(sns, 3);
            SNs{d,i}(19,:)
        end 
    end

    po = fminsearch(@(p) sncalc(p,Z{1,1},fe{1,1},In,Out),[1,1,1,1]);

    Z{1,1}(19,3) = po(1)*real(Z{1,1}(19,3)) + po(2)*sqrt(-1)*imag(Z{1,1}(19,3));
    Z{1,1}(19,4) = po(3)*real(Z{1,1}(19,4)) + po(4)*sqrt(-1)*imag(Z{1,1}(19,4));
end

if 0
    [tw,D] = weather();

    tw = tw(9:end);
    D = D(9:end,:);

    for i = 1:size(D,2)
        Di(:,i) = interp1(tw,D(:,i),tE);
        Di(:,i) = (Di(:,i)-mean(Di(~isnan(Di(:,i)),i)));
    end

    I = find(isnan(Di(:,1)));
    Di(I,:) = 0;

    opts.td.window.width = 86400*27;
    opts.td.window.shift = 86400*27;
    opts.fd.regression.method = 3;

    err = E(:,1)-Ep{1,1}(:,1);
    Sw = transferfnFD(Di(:,1:2),err,opts);
    Sw = transferfnFD(Di(:,3:4),Sw.Predicted-Sw.Out,opts);
end


fprintf('________________________________\n');
for j = 1:2
    for i = 1:size(Z,2) % Loop over methods
        for d = 1:size(SNf,1)
            fprintf('%s %s%s\n',comp(j),pad{i},LL{d,i,j});
        end
    end
end

components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};

figprep(1,1200,1200);
figure(5);clf;
for i = 1:4
    subplot(2,2,i)
    k = 0;
    for d = 1:size(Z,1)
        for m = 1:size(Z,2)
            k = k+1;
            loglog(1./fe{d,m}(2:end),abs(Z{d,m}(2:end,i)),...
                  'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',10);
            hold on;grid on;
            ll{k} = sprintf('%s w = %d',methods{m},W(d));
        end
    end
    title(sprintf('%s %s; %s--%s',upper(site),components{i},dateo,datef),'FontWeight','normal');
    legend(ll,'Location','Best');
    xlabel('Period [s]');
    ylabel('[(mV/km)/nT]');
end

lc = ['r','g','b','k'];
ls = ['-','-','-','-'];

figure(6);clf;
    subplot(2,1,1)
        k = 0;
        for d = 1:size(SNf,1)
            for m = 1:size(SNf,2)
                k = k+1;
                loglog(1./fef(2:end),SNf{d,m}(2:end,1),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
                ll{k} = sprintf('%s w = %d',methods{m},d);
            end
        end
        ylabel('SN for $E_x$')
        legend(ll,'Location','Best');        
    subplot(2,1,2)
        for d = 1:size(SNf,1)
            for m = 1:size(SNf,2)
                loglog(1./fef(2:end),SNf{d,m}(2:end,2),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
            end
        end
        ylabel('SN for $E_y$')
        legend(ll,'Location','Best');   
        xl = get(gca,'XLim');

figure(7);clf;
    subplot(2,1,1)
        k = 0;
        for d = 1:size(SNs,1)
            for m = 1:size(SNs,2)
                k = k+1;
                loglog(1./fes(2:end),SNs{d,m}(2:end,1),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
                ll{k} = sprintf('%s w = %d',methods{m},d);
            end
        end
        set(gca,'XLim',xl);
        ylabel('SN for $E_x$')
        legend(ll,'Location','Best');        
    subplot(2,1,2)
        for d = 1:size(SNs,1)
            for m = 1:size(SNs,2)
                loglog(1./fes(2:end),SNs{d,m}(2:end,2),[lc(m),ls(d)],'LineWidth',d);
                grid on; hold on;
            end
        end
        set(gca,'XLim',xl);
        ylabel('SN for $E_y$')
        legend(ll,'Location','Best');        

m1 = 2;
m2 = 2;
d1 = 1;
d2 = 3;

figprep(1,800,1000);
figure(8);clf;
subplot(4,1,1);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1),'k');
    plot(t(a:b),Ep{d1,m1}(a:b,1),'b');
    plot(t(a:b),Ep{d2,m2}(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x');
    ylabel('mV/m');
    legend('$E_x$ Measured',methods{m1},methods{m2},'Location','Best');        
    title(sprintf('%s',upper(site)),'FontWeight','normal');
    hx = zoom(gca);
    hx.ActionPreCallback = @(obj,evd) fprintf('');
    hx.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,2);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1)-Ep{d1,m1}(a:b,1),'b');
    plot(t(a:b),E(a:b,1)-Ep{d2,m2}(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_x$ Prediction Error','VerticalAlignment','top');
    legend(LL{d1,m1,1},LL{d2,m2,1},'Location','Best');    
subplot(4,1,3);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2),'k');
    plot(t(a:b),Ep{d1,m1}(a:b,2),'b');
    plot(t(a:b),Ep{d2,m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x')    
    ylabel('mV/m');
    legend('$E_y$ Measured',methods{m1},methods{m2},'Location','Best');        
    hy = zoom(gca);
    hy.ActionPreCallback = @(obj,evd) fprintf('');
    hy.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(4,1,4);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2)-Ep{d1,m1}(a:b,2),'b');
    plot(t(a:b),E(a:b,2)-Ep{d2,m2}(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_y$ Prediction Error','VerticalAlignment','top');
    xl = cellstr(get(gca,'XTickLabel'));
    xl{1} = [xl{1},'/',dateo(1:4)];
    set(gca,'XTickLabel',xl);
    legend(LL{d1,m1,2},LL{d2,m2,2},'Location','Best');    
