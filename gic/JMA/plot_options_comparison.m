if 1
    file = sprintf('mat/compute_TF_aves-%s.mat','options-1');
    fprintf('plot_options_comparison: Loading from %s\n',file);
    F1 = load(file);

    file = sprintf('mat/compute_TF_aves-%s.mat','options-2');
    fprintf('plot_options_comparison: Loading from %s\n',file);
    F2 = load(file);

    file = sprintf('mat/compute_TF_aves-%s.mat','options-3');
    fprintf('plot_options_comparison: Loading from %s\n',file);
    F3 = load(file);

    file = sprintf('mat/compute_TF_aves-%s.mat','options-4');
    fprintf('plot_options_comparison: Loading from %s\n',file);
    F4 = load(file);
end

fn = 0;
sf = 1e3;

fn=fn+1;figure(fn);clf;
    for i = 3:4
        loglog(1./F1.GE.fe(2:end),sf*F1.GE.Zabs_Mean(2:end,i),'k',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F2.GE.fe(2:end),sf*F2.GE.Zabs_Mean(2:end,i),'g',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F3.GE.fe(2:end),sf*F3.GE.Zabs_Mean(2:end,i),'b',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F4.GE.fe(2:end),sf*F4.GE.Zabs_Mean(2:end,i),'m',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    errorbars(1./F1.GE.fe(2:end),sf*F1.GE.Zabs_Mean(2:end,3),sf*F1.GE.Zabs_StdErr(2:end,3),sf*F1.GE.Zabs_StdErr(2:end,3),'y','k');
    errorbars(1./F1.GE.fe(2:end),sf*F1.GE.Zabs_Mean(2:end,4),sf*F1.GE.Zabs_StdErr(2:end,4),sf*F1.GE.Zabs_StdErr(2:end,4),'y','k');    
    legend('Options 1 - $A(\omega)$','Options 1 - $B(\omega)$',...
           'Options 2 - $A(\omega)$','Options 2 - $B(\omega)$',...
           'Options 3 - $A(\omega)$','Options 3 - $B(\omega)$',...
           'Options 4 - $A(\omega)$','Options 4 - $B(\omega)$',...
           'Location','Best');
       
fn=fn+1;figure(fn);clf;
    for i = 3:4
        loglog(1./F1.GB.fe(2:end),sf*F1.GB.Zabs_Mean(2:end,i),'k',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F2.GB.fe(2:end),sf*F2.GB.Zabs_Mean(2:end,i),'g',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F3.GB.fe(2:end),sf*F3.GB.Zabs_Mean(2:end,i),'b',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    for i = 3:4
        loglog(1./F4.GB.fe(2:end),sf*F4.GB.Zabs_Mean(2:end,i),'m',...
            'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',20);
        hold on;
    end
    errorbars(1./F1.GB.fe(2:end),sf*F1.GB.Zabs_Mean(2:end,3),sf*F1.GB.Zabs_StdErr(2:end,3),sf*F1.GB.Zabs_StdErr(2:end,3),'y','k');
    errorbars(1./F1.GB.fe(2:end),sf*F1.GB.Zabs_Mean(2:end,4),sf*F1.GB.Zabs_StdErr(2:end,4),sf*F1.GB.Zabs_StdErr(2:end,4),'y','k');    
    legend('Options 1 - $Z_x(\omega)$','Options 1 - $Z_y(\omega)$',...
           'Options 2 - $Z_x(\omega)$','Options 2 - $Z_y(\omega)$',...
           'Options 3 - $Z_x(\omega)$','Options 3 - $Z_y(\omega)$',...           
           'Options 4 - $Z_x(\omega)$','Options 4 - $Z_y(\omega)$',...           
           'Location','Best');       