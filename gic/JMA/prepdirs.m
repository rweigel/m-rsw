function prepdirs(dateo)

dirmat = sprintf('mat/%s',dateo);
if ~exist(dirmat,'dir')
    mkdir(dirmat);
else
    system(sprintf('rm %s/*',dirmat))
end
dirfig = sprintf('figures/%s',dateo);
if ~exist(dirfig,'dir')
    mkdir(dirfig);
else
    system(sprintf('rm %s/*',dirfig))
end
