function S = transferfnCombine(Scell)

if isstruct(Scell)
    S = Scell;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Case where elements of Scell are cell arrays.
% Flatten Scell to be a cell array of structures.
k = 1;
for i = 1:length(Scell)
    if iscell(Scell{i})
        for j = 1:length(Scell{i})
            Stmp{k} = Scell{i}{j};
            k = k+1;
        end
    end
end
if k > 1
    Scell = Stmp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S = struct();

for i = 1:length(Scell)
    S.In(:,:,i)  = Scell{i}.In;
    S.Out(:,:,i)  = Scell{i}.Out;
    S.Predicted(:,:,i) = Scell{i}.Predicted;

    S.MSE(1,:,i) = Scell{i}.MSE;
    S.PE(1,:,i)  = Scell{i}.PE;
    S.CC(1,:,i)  = Scell{i}.CC;
    
    S.SN(:,:,i) = Scell{i}.SN;
    
    S.In_PSD(:,:,i)    = Scell{i}.In_PSD;
    S.Out_PSD(:,:,i)   = Scell{i}.Out_PSD;
    S.Error_PSD(:,:,i)   = Scell{i}.Error_PSD;
    S.Coherence(:,:,i) = Scell{i}.Coherence;
end

if isfield(Scell{1},'ao')
    for i = 1:length(Scell)
        S.ao(:,:,i)   = Scell{i}.ao;
        S.bo(:,:,i)   = Scell{i}.bo;
    end
else
    S.fe = Scell{1}.fe;
    for i = 1:length(Scell)
        S.Z(:,:,i)   = Scell{i}.Z;
        S.H(:,:,i)   = Scell{i}.H;
        S.Phi(:,:,i) = Scell{i}.Phi;
    end
end
