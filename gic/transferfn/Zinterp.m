function Zi = Zinterp(fe,Z,fg,verbose)

if (nargin < 4)
    verbose = 0;
end
if (size(fe,1) ~= size(Z,1))
    fe = fe';
end
if (size(fe,1) ~= size(fg,1))
    fg = fg';
end

if nargin == 3 && (length(fe) == length(fg))
    if all(fe == fg)
	if (verbose)
	    warning('all(fe == fg) returned true.  No interpolation will be performed.');
	end
	Zi = Z;
	return;
    end
end

if (verbose)
    fprintf('First grid frequency       : %.4f\n',fg(1));
    fprintf('First evaluation frequency : %.4f\n',fe(1));
    fprintf('Last grid frequency        : %.4f\n',fg(end));
    fprintf('Last evaluation frequency  : %.4f\n',fe(end));
end

for k = 1:size(Z,2)
    % Interpolate onto frequency grid

    if (0)
	% Linearly interpolate in log space.
	logZio(:,k) = interp1(log(fe(2:end)),log(Z(2:end,k)),log(fg(2:end)));
	Zio(:,k) = exp(logZio(:,k));
	Zi(:,k) = [Z(1,k);Zio(:,k)];
    end
    
    if (1)
	Zio(:,k) = interp1(fe,Z(:,k),fg,'linear');
	Zi(:,k) = Zio(:,k);
    end

    if (0)
	Zio(:,k) = interp1(fe,Z(:,k),fg,'cubic');
	Zi(:,k) = Zio(:,k);
    end

    % Set NaN values to zero
    I = find(isnan(Zi(:,k)));
    if (length(I) > 0)
	if (verbose)
	    fprintf('Setting %d value(s) to zero in Z(:,%d)\n',length(I),k);
	end
    end
    Zi(I,k) = 0;
end
%Zi = [Z(1,:);Zi];
