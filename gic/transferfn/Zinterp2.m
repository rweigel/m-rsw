function Zi = Zinterp(fe,Z,fg,verbose)
% ZINTERP - Interpolate transfer function onto frequency grid
%
%  Zi = Zinterp(fe,Z,fgrid) where fe >= 0 and fgrid >= 0 are evaluation
%  and grid frequencies, respectively.
%
%  Rows of fe are frequencies of corresponding rows of Z. Each column of
%  Z is interpolated using INTERP1. If fe(1) = 0, it is not used for
%  interpolation. If fg(1) = 0, first row of Zi is set equal to first
%  row of Z if fe(1) = 0. Otherwise, first row of Zi is zeros.
%
%  Zi = Zinterp(fe,Z,fgrid,verbose) Displays logging information if
%  verbose = 1.
%
%  See also Z2H.

if (nargin < 4)
    verbose = 0;
end
if (size(fe,1) ~= size(Z,1))
    fe = fe';
end
if (size(fe,1) ~= size(fg,1))
    fg = fg';
end

if any(fe < 0) || any(fg < 0)
    error('fe and fg must be greater than or equal to zero');
end

% If 1, use value of Z for smallest non-zero fe as interpolated value
% of Z for fg < fe
extendLF = 1;

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

% Remove fe = 0
fe0 = 0;
if fe(1) == 0
    fe0 = 1;
    fe = fe(2:end);
    Z = Z(2:end,:);    
end

% Remove fg = 0
fg0 = 0;
if fg(1) == 0
    fg0 = 1;
    fg = fg(2:end);
end

if extendLF
    if fe(1) > fg(1)
        % Set lowest evaluation frequency to be the lowest grid
        % frequency and make Z equal to that for the lowest actual evaluation
        % frequency. This has the effect of making Z constant in range
        % [fg(1),fe(1)] after interpolation.
        fe = [fg(1);fe];
        Z = [Z(1,:);Z];
    end
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

if fg0 % If lowest grid frequency is zero (and so was removed)
    if fe0 == 0
        % If Z was given at fe = 0, use it as the "interpolated" value.
        Zi = [Z(1,:);Zi];
    else
        % Otherwise, set it to zero
        Zi = [zeros(1,size(Z,2));Zi];
    end
end
