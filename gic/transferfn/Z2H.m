function h = Z2H(fe,Z,fg)
% Z2H Convert frequency domain transfer function to time domain

if nargin == 3
	Zi = Zinterp(fe,Z,fg);
else
	Zi = Z;
end

Zifull = [Zi(1,:);Zi(2:end,:);flipud(conj(Zi(2:end,:)))];
% Compute impulse response
h = ifft(Zifull);
