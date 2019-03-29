function mtplots(S)

for i = 1:1
    fh(i) = figure(i);
    set(fh(i),'DefaultTextInterpreter','latex');
    set(fh(i),'DefaultLegendInterpreter','latex');
    set(fh(i),'DefaultAxesTickLabelInterpreter','latex');
end

c = {[255/255,168/255,0],'r','b','g'};
fe = S.fe;
Z  = S.Z;
Za = abs(S.Z);

figure(1);clf;
    components = {'$Z_{xx}$','$Z_{xy}$','$Z_{yx}$','$Z_{yy}$'};
    sf = 1;
    for i = 1:4
        loglog(1./fe(2:end),sf*Za(2:end,i),'Color',c{i},...
            'LineStyle','-','LineWidth',2,'Marker','.','MarkerSize',20);
        if i == 1;hold on;grid on;end
    end
    if size(Z,2) > 4
        for i = 5:8
            errorbars(1./fe(2:end),sf*Za(2:end,i),sf*Za(2:end,i),'y',c{i-4});
        end
    end
    xlabel('Period [s]');
    if isfield(S,'InUnits') && isfield(S,'OutUnits')
        ylabel(sprintf('[%s/(%s)]',OutUnits,InUnits));
    else
        ylabel(sprintf('[]/[]'));
    end
    lh = legend(components,'Location','Best');

figure(2);clf;
    components = {'$\rho_{xx}$','$\rho_{xy}$','$\rho_{yx}$','$\rho_{yy}$'};
    sf = 0.2;
    % rho=(mu_o/w)Z^2 where E = Z*B/mu_o. If [E] is mV/km and [B] is nT, 
    % sf = 0.2.
    for i = 1:4
        loglog(1./fe(2:end),(sf./fe(2:end)).*Za(2:end,i).^2,'Color',c{i},...
            'LineStyle','-','LineWidth',2,'Marker','.','MarkerSize',20);
        if i == 1;hold on;grid on;end
    end
    if size(Z,2) > 4
        for i = 5:8
            errorbars(1./fe(2:end),(sf./fe(2:end)).*Za(2:end,i).^2,'y',c{i-4});
        end
    end
    lh = legend(components,'Location','Best');

figure(3);clf    
    components = {'$\phi_{xx}$','$\phi_{xy}$','$\phi_{yx}$','$\phi_{yy}$'};
    for i = 1:size(S.Z,2)
        semilogx(1./S.fe(2:end),(180/pi)*S.Phi(2:end,i),'Color',c{i},...
            'Marker','.','MarkerSize',20);
        hold on;
    end
    lh = legend(components,'Location','Best');
    xlabel('Period [s]');
    ylabel('[degrees]');
    grid on;
    
end
