function transferfnSummary(S,Savg,desc)

fprintf('___________________________________________________________________________\n');
fprintf('%s\n',desc);
fprintf('___________________________________________________________________________\n');

if isfield(S,'ao')
    fprintf('Ave ao       mean:              %6.3f;         median: %6.2f;       huber: %6.2f\n',...
        mean(Savg.Mean.ao(2)),mean(Savg.Median.ao(2)),mean(Savg.Huber.ao(2)));
    fprintf(' ao 95%% Lims (norm):        [%6.3f,%6.3f]\n',...
            norm95(squeeze(S.ao(1,2,:))));
    fprintf(' ao 95%% Lims (boot):        [%6.3f,%6.3f]\n',...
            boot(squeeze(S.ao(1,2,:)),@mean,1000,50));

    fprintf('Ave bo       mean:              %6.3f;         median: %6.2f;       huber: %6.2f\n',...        
            mean(Savg.Mean.bo(2)),mean(Savg.Median.bo(2)),mean(Savg.Huber.bo(2)));
    fprintf(' bo 95%% Lims (norm):        [%6.3f,%6.3f]\n',...
            norm95(squeeze(S.bo(1,2,:))));
    fprintf(' bo 95%% Lims (boot):        [%6.3f,%6.3f]\n',...
            boot(squeeze(S.bo(1,2,:)),@mean,1000,50));
end

comps = ['x','y'];
for j = 1:2
    if isfield(Savg,'Fuji')
        fprintf('Ave PE%s            :  in-sample: %6.3f;   using mean:   %6.3f;   |   fuji: %6.3f;   median: %6.3f;   mlochuber:    %6.3f\n',...
                comps(j),mean(S.PE(1,j,:)),mean(Savg.Mean.PE(1,j,:)),mean(Savg.Fuji.PE(1,j,:)),mean(Savg.Median.PE(1,j,:)),mean(Savg.Huber.PE(1,j,:)));
    else
        fprintf('Ave PE%s            :  in-sample: %6.3f;   using mean:   %6.3f;   |   median: %6.3f;   mlochuber:    %6.3f\n',...
                comps(j),mean(S.PE(1,j,:)),mean(Savg.Mean.PE(1,j,:)),mean(Savg.Median.PE(1,j,:)),mean(Savg.Huber.PE(1,j,:)));
    end
    fprintf('   95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            norm95(S.PE(1,j,:)),norm95(Savg.Mean.PE(1,j,:)));
    fprintf('   95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            boot(S.PE(1,j,:),@mean,1000,50),boot(Savg.Mean.PE(1,j,:),@mean,1000,50));
    end
for j = 1:2
    if isfield(Savg,'Fuji')
        fprintf('Ave CC%s            :  in-sample: %6.3f;   using mean: %6.3f;     |   fuji %6.3f\n',...
                comps(j),mean(S.CC(1,j,:)),mean(Savg.Mean.CC(1,j,:)),mean(Savg.Fuji.CC(1,j,:)));
    else
        fprintf('Ave CC%s            :  in-sample: %6.3f;   using mean: %6.3f;\n',...
                comps(j),mean(S.CC(1,j,:)),mean(Savg.Mean.CC(1,j,:)));    
    end
    fprintf('   95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            norm95(S.CC(1,j,:)),norm95(Savg.Mean.CC(1,j,:)));
    fprintf('   95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            boot(S.CC(1,j,:),@mean,1000,50),boot(Savg.Mean.CC(1,j,:),@mean,1000,50));
end

for j = 1:2
    if isfield(Savg,'Fuji')
        fprintf('Ave MSE%s           :  in-sample: %6.3f;   using mean: %6.3f;     | fuji %6.3f\n',...
                comps(j),mean(S.MSE(1,j,:)),mean(Savg.Mean.MSE(1,j,:)),mean(Savg.Fuji.MSE(1,j,:)));    

    else
        fprintf('Ave MSE%           :  in-sample: %6.3f;   using mean: %6.3f;\n',...
                comps(j),mean(S.MSE(1,j,:)),mean(Savg.Mean.MSE(1,j,:)));
    end
    fprintf('   95%% Lims (norm):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            norm95(S.MSE(1,j,:)),norm95(Savg.Mean.MSE(1,j,:)));
    fprintf('   95%% Lims (boot):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
            boot(S.MSE(1,j,:),@mean,1000,50),boot(Savg.Mean.MSE(1,j,:),@mean,1000,50));
end
fprintf('___________________________________________________________________________\n')