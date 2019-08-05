clear;
setpaths;

site = 'mmb';
regen = 0;
opts = main_options(1);

addpath('../window_compare');
showplot = 0;

for codever = 1:1
for interval = 8:8

    [t,E,B,datakey] = window_compare_data(interval,site,regen,showplot,codever);
    diary(sprintf('log/main_%s-v%d.log',datakey,codever));

    fname = sprintf('./mat/main_%s_%s-v%d.mat',upper(site),datakey,codever); 

    [E,B] = removemean(E,B);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'OLS Stack';
    opts.td.window.width = 86400;
    opts.td.window.shift = 86400;
    opts.fd.regression.method = 1;
    Sc{1} = transferfnFD(B(:,1:2,1),E,opts);
        Sa{1} = transferfnAverage(Sc{1},opts);
        transferfnSummary(Sc{1},Sa{1},desc);
        
        S.OLS_Stack = Sa{1}.Mean;
        S.OLS_Stack.description = desc;
        S.OLS_Stack.opts = opts;
        S.OLS_Stack = rmfield(S.OLS_Stack,{'H','H_StdErr'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'OLS Full';
    opts.td.window.width = size(B,1);
    opts.td.window.shift = size(B,1);
    opts.fd.regression.method = 1;    
    Sc{2} = transferfnFD(B(:,1:2,1),E,opts);
        Phi = Sc{2}.Phi;
        
        % Re-do metrics using 1-day segments
        Sc{2} = transferfnMetrics(Sc{1}.In,Sc{1}.Out,Sc{2}.fe,Sc{2}.Z,opts);
        S.OLS_Full = Sc{2};
        S.OLS_Full.Phi = Phi;
        S.OLS_Full.description = desc;
        S.OLS_Full.opts = opts;    
        S.OLS_Full = rmfield(S.OLS_Full,{'In','Out'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'OLS No Stack';
    opts.td.window.width = 86400;
    opts.td.window.shift = 86400;
    opts.fd.regression.method = 1;
    Sc{3} = transferfnFD2(Sc{1},opts);
        S.OLS_No_Stack = Sc{3}.OLS;
        S.OLS_No_Stack.description = desc;
        S.OLS_No_Stack.opts = desc;
        S.OLS_No_Stack = rmfield(S.OLS_No_Stack,'H');
    
        S.Robust_No_Stack = Sc{3}.Robust1;    
        S.Robust_No_Stack.description = 'Robust No Stack';
        S.Robust_No_Stack.opts = opts;
        S.Robust_No_Stack = rmfield(S.Robust_No_Stack,'H');        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Robust Stack';
    opts.td.window.width = 86400;
    opts.td.window.shift = 86400;
    opts.fd.regression.method = 3;
    %opts.fd.window.function = @parzenwin; 
    %opts.fd.window.functionstr = 'parzen';
    Sc{4} = transferfnFD(B(:,1:2,1),E,opts);
        Sa{4} = transferfnAverage(Sc{4},opts);
        transferfnSummary(Sc{4},Sa{4},desc);
        S.Robust_Stack = Sa{4}.Mean;
        S.Robust_Stack.description = desc;
        S.Robust_Stack.opts = opts;
        S.Robust_Stack = rmfield(S.Robust_Stack,{'H','H_StdErr'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Robust Full';
    opts.td.window.width = size(B,1);
    opts.td.window.shift = size(B,1);
    opts.fd.regression.method = 3;
    %opts.fd.window.function = @parzenwin; 
    %opts.fd.window.functionstr = 'parzen';
    Sc{6} = transferfnFD(B(:,1:2,1),E,opts);
        Phi = Sc{6}.Phi;
        % Re-do metrics using 1-day segments
        Sc{6} = transferfnMetrics(Sc{1}.In,Sc{1}.Out,Sc{6}.fe,Sc{6}.Z,opts);
        S.Robust_Full = Sc{6};
        S.Robust_Full.Phi = Phi;        
        S.Robust_Full.description = desc;
        S.Robust_Full.opts = opts;    
        S.Robust_Full = rmfield(S.Robust_Full,{'In','Out'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Robust + Parzen Full';
    opts.td.window.width = size(B,1);
    opts.td.window.shift = size(B,1);
    opts.fd.regression.method = 3;
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';
    Sc{7} = transferfnFD(B(:,1:2,1),E,opts);
        Phi = Sc{7}.Phi;
        % Re-do metrics using 1-day segments
        Sc{7} = transferfnMetrics(Sc{1}.In,Sc{1}.Out,Sc{7}.fe,Sc{7}.Z,opts);
        S.Robust_Full = Sc{7};
        S.Robust_Full.Phi = Phi;        
        S.Robust_Full.description = desc;
        S.Robust_Full.opts = opts;    
        S.Robust_Full = rmfield(S.Robust_Full,{'In','Out'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    desc = 'Fujii et al. 2015';
    Sc{7} = transferfnFujii(Sc{1},site,opts,codever);
        S.Fujii = Sc{7};
        S.Fujii.description = desc;
        S.Fujii.opts = opts;
        S.Fujii = rmfield(S.Fujii,{'In','Out','Time','H','In_FT','Out_FT','F_FT'});    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Summarize results. Use Sc{1} for input/output data, which is the same for
    % all.
    fprintf('main.m: Segement prediction averaged metrics.\n');
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

    fprintf('main.m: Full time series prediction metrics.\n');
    metric = {'PE','CC','MSE'};
    comps = ['x','y'];    
    keys = fieldnames(S);
    % Get padding
    for m = 1:length(metric)
        for j = 1:length(keys)
            L(m,j) = length(metric{m}) + length(keys{j});
        end
    end
    l = max(L(:));
    for m = 1:length(metric)
        for j = 1:length(keys)
            s{m,j} = repmat(' ',1,l-L(m,j));
        end
    end
    % Print results
    for m = 1:length(metric)
        for c = 1:length(comps)
            for j = 1:length(keys)
                fprintf('Ave %s %s %s: %s %7.3f\n',...
                    comps(c),...
                    metric{m},...
                    keys{j},...
                    s{m,j},...
                    S.(keys{j}).Full.PE(c));
            end
        end
    end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    t_segments = Sc{1}.Time;
    E_segments = Sc{1}.Out;
    B_segments = Sc{1}.In;

    fprintf('Saving %s\n',fname);
    save(fname,'S','Sa','t','E','B','t_segments','E_segments','B_segments','a','b','site');
    fprintf('Saved %s\n',fname);    
    
    diary off;
    
    main_plot;

end
end