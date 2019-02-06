function exponent_relabel(ax,dir)

    if nargin == 1
        exponent_relabel(ax,'x');
        exponent_relabel(ax,'y');
        return;
    end

    drawnow;
    
    if strcmp(dir,'x')
        l = get(ax,'XTickLabel');
    elseif strcmp(dir,'y')
        l = get(ax,'YTickLabel');
    else
        error('dir must be x or y');
    end

    for i = 1:length(l)
        if strcmp(l{i},'10^{-1}')
            l{i} = '0.1';
        end
        if strcmp(l{i},'$10^{-1}$')
            l{i} = '$0.1$';
        end
        if strcmp(l{i},'10^{0}')
            l{i} = '1';
        end
        if strcmp(l{i},'$10^{0}$')
            l{i} = '$1$';
        end
        if strcmp(l{i},'10^{1}')
            l{i} = '10';
        end
        if strcmp(l{i},'$10^{1}$')
            l{i} = '$10$';
        end
        if strcmp(l{i},'10^{2}')
            l{i} = '100';
        end
        if strcmp(l{i},'$10^{2}$')
            l{i} = '$100$';
        end
    end

    if strcmp(dir,'x')
        set(ax,'XTickLabel',l);
    else
        set(ax,'YTickLabel',l);
    end
    
end
