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

if 0
    k = 1;
    for i = 1:length(Scell)
        if ~isempty(Scell{i})
            I(k) = i;
            k = k+1;
        end
    end
    Scell = Scell(I); % Removes empty elements
end

S = struct();

S.In  = Scell{1}.In;
S.Out = Scell{1}.Out;
S.Predicted = Scell{1}.Predicted;
S.Time      = Scell{1}.Time;

S.MSE = Scell{1}.MSE;
S.PE  = Scell{1}.PE;
S.CC  = Scell{1}.CC;

S.SN = Scell{1}.SN;

S.In_PSD    = Scell{1}.In_PSD;
S.Out_PSD   = Scell{1}.Out_PSD;
S.Error_PSD = Scell{1}.Error_PSD;
S.Coherence = Scell{1}.Coherence;

for i = 2:length(Scell)
    S.In  = cat(3,S.In,Scell{i}.In);
    S.Out = cat(3,S.Out,Scell{i}.Out);
    S.Predicted = cat(3,S.Predicted,Scell{i}.Predicted);
    S.Time      = cat(3,S.Time,Scell{i}.Time);

    S.PE  = cat(3,S.PE,Scell{i}.PE);
    S.CC  = cat(3,S.CC,Scell{i}.CC);
    S.MSE = cat(3,S.MSE,Scell{i}.MSE);

    S.SN = cat(3,S.SN,Scell{i}.SN);

    S.In_PSD    = cat(3,S.In_PSD,Scell{i}.In_PSD);
    S.Out_PSD   = cat(3,S.Out_PSD,Scell{i}.Out_PSD);
    S.Error_PSD = cat(3,S.Error_PSD,Scell{i}.Error_PSD);
    S.Coherence = cat(3,S.Coherence,Scell{i}.Coherence);
end

if isfield(Scell{1},'ao')
    S.ao = Scell{1}.ao;
    S.bo = Scell{1}.bo;
    for i = 2:length(Scell)
        S.ao = cat(3,S.ao,Scell{i}.ao);
        S.bo = cat(3,S.bo,Scell{i}.bo);
    end
else
    S.fe  = Scell{1}.fe;
    S.Z   = Scell{1}.Z;
    S.H   = Scell{1}.H;
    S.Phi = Scell{1}.Phi;

    if isfield(Scell{1},'In_FT') % Alt TF does not have *_FT fields.    
        S.In_FT  = Scell{1}.In_FT;
        S.Out_FT = Scell{1}.Out_FT;
        S.F_FT   = Scell{1}.F_FT;
    end
    for i = 2:length(Scell)
        S.Z   = cat(3,S.Z,Scell{i}.Z);
        S.H   = cat(3,S.H,Scell{i}.H);
        S.Phi = cat(3,S.Phi,Scell{i}.Phi);

        if isfield(Scell{i},'In_FT') % Alt TF does not have *_FT fields.
            S.In_FT  = cat(3,S.In_FT,Scell{i}.In_FT);
            S.Out_FT = cat(3,S.Out_FT,Scell{i}.Out_FT);
            S.F_FT   = cat(3,S.F_FT,Scell{i}.F_FT);
        end
    end
end
