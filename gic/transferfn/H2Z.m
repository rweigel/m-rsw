function [Z,f,Hi,tg] = H2Z(te,H,tg)

dointerp = true;
if nargin == 3 && (length(te) == length(tg))
	if all(te == tg)
		warning('all(te == tg) returned true.  No interpolation will be performed.');
		dointerp = false;
	end
end

fprintf('First time value : %.4f\n',tg(2));
fprintf('First grid time  : %.4f\n',te(2));
fprintf('Last time value  : %.4f\n',te(end));
fprintf('Last grid time   : %.4f\n',tg(end));

if dointerp
	for k = 1:size(H,2)
		% Interpolate onto frequency grid
		Ho(:,k) = interp1(te,H(:,k),tg(2:end));
		Hi(:,k) = Hio(:,k);
		% Set NaN values to zero
		I = find(isnan(Hi(:,k)));
		if (length(I) > 0)
			fprintf('Setting %d value(s) to zero in H(:,%d)\n',length(I),k);
		end
		Hi(I,k) = 0;
		Z(:,k) = fft(Hi(:,k));
	end

else
	Iz  = [];
	Hi  = H;
	Hio = H;
end

N = size(H,1);
Z = Z(1:floor(N/2)+1);
f = [0:N/2]'/N;
