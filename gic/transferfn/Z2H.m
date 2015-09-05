function [h,t,Zio,fg] = Z2H(t,H,fg)
% Z2H Convert frequency domain transfer function to time domain

dointerp = true;
if nargin == 3 && (length(fe) == length(fg))
	if all(fe == fg)
		warning('all(fe == fg) returned true.  No interpolation will be performed.');
		dointerp = false;
	end
end

fprintf('Second grid frequency       : %.4f\n',fg(2));
fprintf('Second evaluation frequency : %.4f\n',fe(2));
fprintf('Last evaluation frequency   : %.4f\n',fe(end));
fprintf('Last grid frequency         : %.4f\n',fg(end));

if dointerp
	for k = 1:size(Z,2)
		% Interpolate onto frequency grid
		Zio(:,k) = interp1(fe(2:end,1),Z(2:end,k),fg(2:end));
		Zi(:,k) = Zio(:,k);
		% Set NaN values to zero
		I = find(isnan(Zi(:,k)));
		if (length(I) > 0)
			fprintf('Setting %d value(s) to zero in Z(:,%d)\n',length(I),k);
		end
		Zi(I,k) = 0;
	end
else
	Iz  = [];
	Zi  = Z;
	Zio = Z;
end

% Add DC value
Zio    = [Z(1,:);Zio];

% Need full array to compute ifft.
Zifull = [Z(1,:);Zi;flipud(conj(Zi))];

% Compute impulse response
h = fftshift(ifft(Zifull));
N = (length(h)-1)/2;
t = [-N:N]';
