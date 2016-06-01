function h = Z2H(fe,Z,fg)
% Z2H Convert frequency domain transfer function to time domain

if nargin == 3
	Zi = Zinterp(fe,Z,fg);
else
	Zi = Z;
end

if (0)
% Need full array to compute ifft.
if mod(size(Z,1),2) == 0
	Zifull = [Zi(1,:);Zi(2:end,:);flipud(conj(Zi(2:end-1,:)))];
else
	Zifull = [Zi(1,:);Zi(2:end,:);flipud(conj(Zi(2:end,:)))];
end
end
Zifull = [Zi(1,:);Zi(2:end,:);flipud(conj(Zi(2:end,:)))];
% Compute impulse response
h = ifft(Zifull);
