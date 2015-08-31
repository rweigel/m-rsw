function Ep = Zpredict(B,Z)

Z = [ Z(1,:); Z(2:end,:) ; flipud(conj(Z(2:end,:))) ];

Ep(:,1) = ifft(B(:,1).*Z(:,1) + B(:,2).*Z(:,2));
Ep(:,2) = ifft(B(:,1).*Z(:,3) + B(:,2).*Z(:,4));
