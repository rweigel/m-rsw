function Zi = Zinterp(fe,Z,fg,verbose)
% ZINTERP - Interpolate transfer function onto frequency grid
%
%  Zi = Zinterp(fe,Z,fgrid)
%
%  Rows of fe are frequencies of corresponding rows of 
%  Z = [Zxx,Zxy,Zyx,Zyy]. Each column of Z is interpolated using INTERP1
%  onto fgrid.
%
%  Zi = Zinterp(fe,Z,fgrid,verbose)
%

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
    fprintf('Zinterp.m: First grid frequency       : %.4f\n',fg(1));
    fprintf('Zinterp.m: First evaluation frequency : %.4f\n',fe(1));
    fprintf('Zinterp.m: Last grid frequency        : %.4f\n',fg(end));
    fprintf('Zinterp.m: Last evaluation frequency  : %.4f\n',fe(end));
end

for k = 1:size(Z,2)

    if (0)
        % Linearly interpolate in log space.
        logZio(:,k) = interp1(log(fe(2:end)),log(Z(2:end,k)),log(fg(2:end)));
        Zio(:,k) = exp(logZio(:,k));
        Zi(:,k) = [Z(1,k);Zio(:,k)];
    end
    
    if (0)
        Zio(:,k) = interp1(fe,Z(:,k),fg,'cubic');
        Zi(:,k) = Zio(:,k);
    end

    % Will remove any NaN element.
    Ig = ~isnan(Z(:,k));
    if verbose && (length(Ig) ~= size(Z,1))
        fprintf('Zinterp.m: Dropping %d NaN values in Z(:,%d)\n',size(Z,1)-length(Ig),k);
    end
    
    Zi(:,k) = interp1(fe(Ig),Z(Ig,k),fg,'linear');
    %Zi(:,k) = Zio(:,k);

    % Set NaN values to zero
    % (values of fg outside of fe are set to NaN by interp1)
    I = find(isnan(Zi(:,k)));
    if (length(I) > 0)
        if (verbose)
            fprintf('Zinterp.m: Setting %d value(s) to zero in Z(:,%d)\n',length(I),k);
        end
    end
    Zi(I,k) = 0;
end

