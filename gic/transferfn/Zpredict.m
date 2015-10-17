function Ep = Zpredict(fe,Z,B)

N  = size(B,1);
fg = [0:floor(N/2)]'/N;

fprintf('Zpredict: Interpolating Z onto same frequency grid as input.\n');
Z = Zinterp(fe,Z,fg);

if mod(N,2) == 0
	Z = [ Z(1,:); Z(2:end,:) ; flipud(conj(Z(2:end-1,:))) ];
else
	Z = [ Z(1,:); Z(2:end,:) ; flipud(conj(Z(2:end,:))) ];
end

if (size(Z,2) == 1)
	Ep(:,1) = ifft(fft(B(:,2)).*Z(:,1));
	Ep(:,2) = -ifft(fft(B(:,1)).*Z(:,1));
end

if (size(Z,2) == 2)
	Ep(:,1) = ifft(fft(B(:,2)).*Z(:,1));
	Ep(:,2) = -ifft(fft(B(:,1)).*Z(:,2));
end

if (size(Z,2) == 4)
	Ep(:,1) = ifft(fft(B(:,1)).*Z(:,1) + fft(B(:,2)).*Z(:,2));
	Ep(:,2) = ifft(fft(B(:,1)).*Z(:,3) + fft(B(:,2)).*Z(:,4));
end
