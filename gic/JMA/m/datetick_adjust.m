function datetick_adjust();

drawnow
xl = cellstr(get(gca,'XTickLabel'));
xt = get(gca,'XTick');
xl{1} = sprintf('\\begin{tabular}{c} %s \\\\ %s \\end{tabular}',xl{1},datestr(xt(1),'yyyy-mm-dd'));
xl{end} = sprintf('\\begin{tabular}{c} %s \\\\ %s \\end{tabular}',xl{end},datestr(xt(end),'yyyy-mm-dd'));
for i = 1:length(xl)
    if strcmp(xl{i},'00:00')
        xl{i} = sprintf('\\begin{tabular}{c} %s \\\\ %s \\end{tabular}',xl{i},datestr(xt(i),'yyyy-mm-dd'));
    end
end
set(gca,'XTickLabel',xl);
