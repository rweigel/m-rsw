function Zi = Zinterp(fe,Z,fg)

s = dbstack;
n = s(1).name;

if (size(fe,1) ~= size(Z,1))
	fe = fe';
end
if (size(fe,1) ~= size(fg,1))
	fg = fg';
end

if nargin == 3 && (length(fe) == length(fg))
	if all(fe == fg)
		fprintf('%s: all(fe == fg) returned true.  No interpolation will be performed.\n',n);
		Zi = Z;
		return;
	end
end

fprintf('%s: First grid frequency       : %.4f\n',n,fg(1));
fprintf('%s: First evaluation frequency : %.4f\n',n,fe(1));
fprintf('%s: Last grid frequency        : %.4f\n',n,fg(end));
fprintf('%s: Last evaluation frequency  : %.4f\n',n,fe(end));

for k = 1:size(Z,2)
	% Interpolate onto frequency grid
	%Zi(:,k) = interp1(fe,Z(:,k),fg);
	%Zi(:,k) = interp1(fe(2:end),Z(2:end,k),fg(2:end));
	%Zi(:,k) = interp1(fe(2:end),Z(2:end,k),fg(2:end),'linear','extrap');
	Zi(:,k) = interp1(fe(2:end),Z(2:end,k),fg(2:end),'linear');
	% Set NaN values to zero
	I = find(isnan(Zi(:,k)));
	if (length(I) > 0)
		fprintf('%s: Setting %d value(s) to zero in Z(:,%d)\n',n,length(I),k);
	end
	Zi(I,k) = 0;
end
Zi = [Z(1,:);Zi];