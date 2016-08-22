function Ep = Hpredict(t,H,B)
%HPREDICT
%

ti = [t(1):t(end)];
Hi = interp1(t,H,ti);
Ep(:,1) = filter(Hi(:,2),1,B(:,2));
Ep(:,2) = filter(Hi(:,3),1,B(:,1));
Ep(1:size(Hi,1)-1,:) = NaN;

a = find(t > -1,1);

Ep = Ep(a:end,:);
Ep = [Ep; NaN*ones(a-1,2)];


