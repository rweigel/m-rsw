function transferfnSummary(S,Savg,desc)

S.PE  = squeeze(S.PE);
S.CC  = squeeze(S.CC);
S.MSE = squeeze(S.MSE);

Savg.PE  = squeeze(Savg.PE);
Savg.CC  = squeeze(Savg.CC);
Savg.MSE = squeeze(Savg.MSE);

fprintf('___________________________________________________________________________\n')
fprintf('%s\n',desc);
fprintf('___________________________________________________________________________\n')
if isfield(S,'ao')
    fprintf('Ave ao            :             %6.3f\n',mean(Savg.ao(2)));
    fprintf(' ao 95%% Lims (norm):        [%6.3f,%6.3f]\n',...
            norm95(squeeze(S.ao(1,2,:))));
    fprintf(' ao 95%% Lims (boot):        [%6.3f,%6.3f]\n',...
            boot(squeeze(S.ao(1,2,:)),@mean,1000,50));

    fprintf('Ave bo            :             %6.3f\n',mean(Savg.bo(2)));
    fprintf(' bo 95%% Lims (norm):        [%6.3f,%6.3f]\n',...
            norm95(squeeze(S.bo(1,2,:))));
    fprintf(' bo 95%% Lims (boot):        [%6.3f,%6.3f]\n',...
            boot(squeeze(S.bo(1,2,:)),@mean,1000,50));
end

fprintf('Ave PE            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
        mean(S.PE(2,:)),mean(Savg.PE(2,:)));
fprintf('   95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        norm95(S.PE(2,:)),norm95(S.PE(2,:)));
fprintf('   95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        boot(S.PE(2,:),@mean,1000,50),boot(S.PE(2,:),@mean,1000,50));

fprintf('Ave CC            :  in-sample: %6.3f;     using mean: %6.3f;\n',...
        mean(S.CC(2,:)),mean(Savg.CC(2,:)));
fprintf('   95%% Lims (norm):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        norm95(S.CC(2,:)),norm95(S.CC(2,:)));
fprintf('   95%% Lims (boot):        [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        boot(S.CC(2,:),@mean,1000,50),boot(S.CC(2,:),@mean,1000,50));

fprintf('Ave MSE           :  in-sample: %6.3f;     using mean: %6.3f;\n',...
        mean(S.MSE(2,:)),mean(Savg.MSE(2,:)));
fprintf('   95%% Lims (norm):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        norm95(S.MSE(2,:)),norm95(S.MSE(2,:)));
fprintf('   95%% Lims (boot):       [%6.3f,%6.3f];        [%6.3f,%6.3f];\n',...
        boot(S.MSE(2,:),@mean,1000,50),boot(S.MSE(2,:),@mean,1000,50));
fprintf('___________________________________________________________________________\n')