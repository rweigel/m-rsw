function errorbars(x,y,yl,yu,scale)

    if nargin < 5
        scale = 'linear';
    end
    if nargin == 4 && isa(yu,'char')
        % errorbars(x,y,yl,scale)
        scale = yu;
        yu = yl; % Set yu = yl
    end
    if nargin == 3
        yu = yl;
    end
    if strmatch(scale,'linear','exact')
        for i = 1:length(x)
            plot([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end
    if strmatch(scale,'loglog','exact')    
        for i = 1:length(x)
            loglog([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end
    if strmatch(scale,'semilogx','exact')    
        for i = 1:length(x)
            semilogx([x(i),x(i)],[y(i)+yu(i),y(i)-yl(i)],'k-');
        end
    end    
end