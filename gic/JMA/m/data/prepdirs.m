function prepdirs(dateo,filestr,clean)

if nargin < 3
    clean = 1;
end

dirmat = sprintf('mat/%s',dateo);
if ~exist(dirmat,'dir')
    mkdir(dirmat);
else
    if clean
        system(sprintf('rm -f %s/*%s*',dirmat,filestr));
    end
end

dirfig = sprintf('figures/%s',dateo);
if ~exist(dirfig,'dir')
    mkdir(dirfig);
else
    if clean
        system(sprintf('rm -f %s/*%s*',dirfig,filestr));
    end
end
