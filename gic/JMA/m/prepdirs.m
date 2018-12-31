function prepdirs(dateo,clean)

dirmat = sprintf('mat/%s',dateo);
if ~exist(dirmat,'dir')
    mkdir(dirmat);
else
    if clean
        system(sprintf('rm -f %s/compute_*',dirmat));
    end
end

dirfig = sprintf('figures/%s',dateo);
if ~exist(dirfig,'dir')
    mkdir(dirfig);
else
    if clean
        system(sprintf('rm -f %s/compute_*',dirfig));
    end
end
