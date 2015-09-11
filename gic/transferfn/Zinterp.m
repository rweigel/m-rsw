function Zi = Zinterp(fe,Z,fg)

if (size(fe,1) ~= size(Z,1))
	fe = fe';
end
if (size(fe,1) ~= size(fg,1))
	fg = fg';
end

if nargin == 3 && (length(fe) == length(fg))
	if all(fe == fg)
		warning('all(fe == fg) returned true.  No interpolation will be performed.');
		Zio = Z;
		return;
	end
end

fprintf('First grid frequency       : %.4f\n',fg(1));
fprintf('First evaluation frequency : %.4f\n',fe(1));
fprintf('Last grid frequency        : %.4f\n',fg(end));
fprintf('Last evaluation frequency  : %.4f\n',fe(end));

for k = 1:size(Z,2)
	% Interpolate onto frequency grid
	Zi(:,k) = interp1(fe,Z(:,k),fg);
	% Set NaN values to zero
	I = find(isnan(Zi(:,k)));
	if (length(I) > 0)
		fprintf('Setting %d value(s) to zero in Z(:,%d)\n',length(I),k);
	end
	Zi(I,k) = 0;
end