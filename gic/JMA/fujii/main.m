clear;

site = 'mmb';
opts = main_options(1);

for interval = 8:8
    
    [t,E,B,datakey] = main_data(interval,site);

    fname = sprintf('./mat/%s_%s.mat',upper(site),datakey); % Save file name

    [E,B] = removemean(E,B);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'OLS Stack';
    opts.td.window.width = 86400;
    opts.td.window.shift = 86400;
    opts.fd.regression.method = 1;
    Sc{1} = transferfnFD(B(:,1:2,1),E,opts);
        Sa{1} = transferfnAverage(Sc{1},opts);
        transferfnSummary(Sc{1},Sa{1},desc);

        Z{1} = Sa{1}.Mean.Z;
        fe{1} = Sa{1}.Mean.fe;
        S.OLS_Stack = Sa{1}.Mean;
        S.OLS_Stack.description = desc;
        S.OLS_Stack.opts = opts;
        S.OLS_Stack = rmfield(S.OLS_Stack,{'H','H_StdErr'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Robust + Parzen Stack';
    opts.fd.regression.method = 3;
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';
    Sc{2} = transferfnFD(B(:,1:2,1),E,opts);
        Sa{2} = transferfnAverage(Sc{2},opts);
        transferfnSummary(Sc{2},Sa{2},desc);
        Z{2} = Sa{2}.Mean.Z;
        fe{2} = Sa{2}.Mean.fe;
        S.Robust_Parzen_Stack = Sa{2}.Mean;
        S.Robust_Parzen_Stack.description = desc;
        S.Robust_Parzen_Stack.opts = opts;
        S.Robust_Parzen_Stack = rmfield(S.Robust_Parzen_Stack,{'H','H_StdErr'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Sc{3} = transferfnFD2(Sc{2},opts);
        Z{3} = Sc{3}.OLS.Z;
        fe{3} = Sc{3}.OLS.fe;
        S.OLS_No_Stack = Sc{3}.OLS;
        S.OLS_No_Stack.description = 'OLS No Stack';
        S.OLS_No_Stack.opts = 'OLS No Stack';        
        S.OLS_No_Stack = rmfield(S.OLS_No_Stack,'H');

        Z{4} = Sc{3}.Robust1.Z;
        fe{4} = Sc{3}.Robust1.fe;

        S.Robust_No_Stack = Sc{3}.Robust1;    
        S.Robust_No_Stack.description = 'Robust + Parzen No Stack';
        S.Robust_No_Stack.opts = opts;
        S.Robust_No_Stack = rmfield(S.Robust_No_Stack,'H');        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Fujii et al. 2015';
    Sc{5} = transferfnFujii(Sc{1},site,opts);
        fe{5} = Sc{5}.fe;
        Z{5}  = Sc{5}.Z;
        S.Fujii = Sc{5};
        S.Fujii.description = desc;
        S.Fujii.opts = opts;
        S.Fujii = rmfield(S.Fujii,{'In','Out','H','In_FT','Out_FT','F_FT'});    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Robust + Parzen Full';
    opts.td.window.width = size(B,1);
    opts.td.window.shift = size(B,1);
    opts.fd.regression.method = 3;
    opts.description = desc;
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';

    Sc{6} = transferfnFD(B(:,1:2,1),E,opts);
    fe{6} = Sc{6}.fe;
    Z{6} = Sc{6}.Z;

    % Re-do metrics using 1-day segments
    Sc{6} = transferfnMetrics(Sc{1}.In,Sc{1}.Out,fe{6},Z{6},opts);
    S.Robust_Parzen_Full = Sc{6};
    S.Robust_Parzen_Full.description = desc;
    S.Robust_Parzen_Full.opts = opts;    
    S.Robust_Parzen_Full = rmfield(S.Robust_Parzen_Full,{'In','Out'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Summarize results. Use Sc{1} for input/output data, which is the same for
    % all.
    transferfnSummary(Sc{1},S,'');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Metrics calculations

    a = opts.td.Ntrim; % Will be same for all.
    b = size(B,1)-a+1;

    % Compute spectral amplitude using trimmed interval
    [N,xfe] = smoothSpectra(E(a:b,:));

    % Compute predicted E using each Z.
    % SN is for when predictions are made for full interval. No averaging.
    fns = fieldnames(S);
    for i = 1:length(fns)
        S.(fns{i}).Full = struct();
        S.(fns{i}).Full.SNfe = xfe;        
        S.(fns{i}).Full.Predicted = Zpredict(S.(fns{i}).fe,S.(fns{i}).Z,B(:,1:2,1));
        S.(fns{i}).Full.SN = N./smoothSpectra(E(a:b,:)-S.(fns{i}).Full.Predicted(a:b,:));
        %Ep{i} = Zpredict(S.(fns{i}).fe,S.(fns{i}).Z,B(:,1:2,1));
        %SN{i} = N./smoothSpectra(E(a:b,:)-Ep{i}(a:b,:));

        comp = ['x','y'];
        % TODO: Filter both E and Ep above 12 h so comparison is only
        % for frequencies that the model predicts.
        % Should also plot only E and Ep filtered.

        %M{i}(1,:) = pe(E(a:b,:),Ep{i}(a:b,:));
        %M{i}(2,:) = cc(E(a:b,:),Ep{i}(a:b,:));
        %M{i}(3,:) = mse(E(a:b,:),Ep{i}(a:b,:));
        S.(fns{i}).Full.PE  = pe(E(a:b,:),S.(fns{i}).Full.Predicted(a:b,:));
        S.(fns{i}).Full.CC  = cc(E(a:b,:),S.(fns{i}).Full.Predicted(a:b,:));
        S.(fns{i}).Full.MSE = mse(E(a:b,:),S.(fns{i}).Full.Predicted(a:b,:));        
        
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    t_segments = Sc{1}.Time;
    E_segments = Sc{1}.Out;
    B_segments = Sc{1}.In;

    fprintf('Saving %s\n',fname);
    save(fname,'S','t','E','B','t_segments','E_segments','B_segments');
    fprintf('Saved %s\n',fname);    
    
    main_plot;

end
