%function main_plot(interval)

setpaths;

writepng = 0;
show = {'Robust_Parzen_Stack','Fujii','Robust_Parzen_Full'};

if 0
    site = 'mmb';
    dateo = '20051202';
    datef = '20051226';

    fname = sprintf('./mat/%s_%s-%s.mat',upper(site),dateo,datef);
    fprintf('Loading %s\n',fname);
    load(fname);
    fprintf('Loaded %s\n',fname);
end

a = opts.td.Ntrim+1; % Metrics calculation exclusion points at start of interval
b = size(B,1)-a;     % At end of interval

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do this in case prep_EB does not return data over full time range
% requested.
dateo = datestr(t(1),'yyyymmdd');
datef = datestr(t(end),'yyyymmdd');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fns = fieldnames(S);
for i = 1:length(show)
    showi(i) = strmatch(show{i},fns,'exact');
end

% Temporary description
%S.Robust_Parzen_Full.description = 'Robust';

for m = 1:length(fns)
    methods{m} = S.(fns{m}).description;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%c = {[255/255,168/255,0],'r','b','g','m','c','k'};
components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};

figprep(writepng,1200,1200);

fns = fieldnames(S);

figure(1);clf;
for i = 1:4
    subplot(2,2,i)
    clear lstr
    for m = 1:length(show)
        loglog(1./S.(show{m}).fe(2:end),abs(S.(show{m}).Z(2:end,i)),...
              'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',25-3*m);
        hold on;grid on;
        lstr{m} = sprintf('%s %s',components{i},methods{m});
    end
    set(gca,'XLim',[10,86400/2]);
    title(sprintf('%s %s; %s-%s',upper(site),components{i},dateo,datef),'FontWeight','normal');
    legend(methods{showi},'Location','Best');
    xlabel('Period [s]');
    ylabel('[(mV/km)/nT]');
end
drawnow;
if writepng
    figsave(sprintf('figures/%s-Z-%s-%s.pdf',upper(site),dateo,datef));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figprep(writepng,1200,1200);

fns = fieldnames(S);
for i = 1:length(fns)
    for j = 1:2
        LL{i,j} = sprintf('%s PE/CC/MSE = %.2f/%.2f/%.2f',...
            S.(fns{i}).description,...
            S.(fns{i}).Full.PE(j),...
            S.(fns{i}).Full.CC(j),...
            S.(fns{i}).Full.MSE(j));
    end
end
 
lw = [2,1,2,1,2,2];
figure(2);clf;
    subplot(2,1,1)
        for i = showi
            loglog(1./S.(fns{i}).Full.SNfe(2:end),...
                S.(fns{i}).Full.SN(2:end,1),'LineWidth',lw(i));
            grid on; hold on;
        end
        set(gca,'XLim',[10,86400/2]);
        ylabel('SN for $E_x$')
        legend(methods{showi},'Location','Best');
    subplot(2,1,2)
        for i = showi
            loglog(1./S.(fns{i}).Full.SNfe(2:end),...
                S.(fns{i}).Full.SN(2:end,2),'LineWidth',lw(i));
            grid on; hold on;
        end
        set(gca,'XLim',[10,86400/2]);
        ylabel('SN for $E_y$')
        legend(methods{showi},'Location','Best');        
    drawnow;
    if writepng
        figsave(sprintf('figures/%s-SN-%s-%s.pdf',upper(site),dateo,datef));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figprep(writepng,1200,1200);
figure(3);clf;
    keys = fieldnames(S);

    % TODO: This SN does not use trimmed output and predictions. It should.
    for k = 1:length(fns)
        SNx{k} = mean(S.(fns{k}).SN,3);
        fex{k} = Sa{1}.Mean.fe;
    end

    subplot(2,1,1)
        for i = showi
            loglog(1./fex{i}(2:end),SNx{i}(2:end,1),'LineWidth',lw(i));
            grid on; hold on;
        end
        ylabel('SN for $E_x$')
        legend(methods{showi},'Location','Best');        
    subplot(2,1,2)
        for i = showi
            loglog(1./fex{i}(2:end),SNx{i}(2:end,2),'LineWidth',lw(i));
            grid on; hold on;
        end
        ylabel('SN for $E_y$')
        legend(methods{showi},'Location','Best');
    drawnow;        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m1 = showi(1);
m2 = showi(2);

figprep(writepng,800,1000);
figure(4);clf;
subplot(5,1,1);grid on;hold on;box on;
    title(sprintf('%s',upper(site)),'FontWeight','normal');
    plot(t(a:b),B(a:b,1:2));
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    legend('$B_x$','$B_y$','Location','Best');        
    hx = zoom(gca);
    hx.ActionPreCallback = @(obj,evd) fprintf('');
    hx.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are B([%10d:%10d],:)\n.',round(evd.Axes.XLim-t(a))*86400);
subplot(5,1,2);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1),'k');
    plot(t(a:b),S.(fns{m1}).Full.Predicted(a:b,1),'b');
    plot(t(a:b),S.(fns{m2}).Full.Predicted(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    ylabel('mV/m');    
    legend('$E_x$ Measured',methods{m1},methods{m2},'Location','Best');        
    hx = zoom(gca);
    hx.ActionPreCallback = @(obj,evd) fprintf('');
    hx.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%10%:%10d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(5,1,3);grid on;hold on;box on;
    plot(t(a:b),E(a:b,1)-S.(fns{m1}).Full.Predicted(a:b,1),'b');
    plot(t(a:b),E(a:b,1)-S.(fns{m2}).Full.Predicted(a:b,1),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_x$ Prediction Error','VerticalAlignment','top');
    legend(LL{m1,1},LL{m2,1},'Location','Best');    
subplot(5,1,4);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2),'k');
    plot(t(a:b),S.(fns{m1}).Full.Predicted(a:b,2),'b');
    plot(t(a:b),S.(fns{m2}).Full.Predicted(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd')    
    ylabel('mV/m');
    legend('$E_y$ Measured',methods{m1},methods{m2},'Location','Best');        
    hy = zoom(gca);
    hy.ActionPreCallback = @(obj,evd) fprintf('');
    hy.ActionPostCallback = @(obj,evd) fprintf('The new X-Limits are E([%d:%d],1)\n.',(evd.Axes.XLim-t(a))*86400);
subplot(5,1,5);grid on;hold on;box on;
    plot(t(a:b),E(a:b,2)-S.(fns{m1}).Full.Predicted(a:b,2),'b');
    plot(t(a:b),E(a:b,2)-S.(fns{m2}).Full.Predicted(a:b,2),'r');
    set(gca,'XLim',[t(1),t(end)]);
    datetick('x','dd');
    ylabel('mV/m');
    yl = get(gca,'YLim');
    text(t(1),yl(2),'$E_y$ Prediction Error','VerticalAlignment','top');
    xl = cellstr(get(gca,'XTickLabel'));
    xl{1} = [xl{1},'/',dateo(1:4)];
    set(gca,'XTickLabel',xl);
    legend(LL{m1,2},LL{m2,2},'Location','Best');
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
