function [Zi,Pi] = H2Z(fe,H,Nf)

if (nargin == 3)
	if (length(Nf) == 1)
		fg = linspace(fe(1),fe(end),Nf)';
	else
		fg = Nf;
	end
else
	fg = fe;	
end

dointerp = true;
if nargin == 3 && (length(fe) == length(fg))
	if all(fe == fg)
		warning('all(fe == fg) returned true.  No interpolation will be performed.');
		dointerp = false;
	end
end

% Transfer Function
Zxy = fft(H);
N   = length(Zxy);
Zxy = Zxy(1:floor(N/2)+1);
fe  = [0:N/2]'/N;

% Transfer Function Phase
Pxy = (180/pi)*atan2(imag(Zxy),real(Zxy));

if (fe(2) > fg(2))
    % If lowest evaluation frequency is larger than first point on
    % frequency grid, extrapolate. 
    Zi = interp1(fe(2:end),Zxy(2:end),fg(2:end),'linear','extrap');
    Pi = interp1(fe(2:end),Pxy(2:end),fg(2:end),'linear','extrap');
else
    Zi = interp1(fe(2:end),Zxy(2:end),fg(2:end),'linear');
    Pi = interp1(fe(2:end),Pxy(2:end),fg(2:end),'linear');
end

Zi(isnan(Zi)) = 0;
Zi = [Zxy(1);Zi];

Pi(isnan(Pi)) = 0;
Pi = [Pxy(1);Pi];
