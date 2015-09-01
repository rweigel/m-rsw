function Ep = Hpredict(t,H,B)

N        = find(t == 0);
tmp      = filter(H(:,1),1,B(:,2));
Ep(:,1)  = tmp(N:end);
tmp      = filter(H(:,2),1,B(:,1));
Ep(:,2)  = tmp(N:end);