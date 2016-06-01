function [Z,f,H,t,Ep] = transferfnTDri(B,E,Nc,Na,Tw)

if Tw == 1
    [Z,f,H,t,Ep] = transferfnTD(B,E,Nc,Na);
    return
end

Ni = floor(size(B,1)/Tw);
%fprintf('Number of averaging intervals: %d\n',Ni);
for i = 1:size(B,2)
    Br(:,i) = mean( reshape(B(1:Tw*Ni,i),Tw,Ni) ,1);
    Er(:,i) = mean( reshape(E(1:Tw*Ni,i),Tw,Ni) ,1);
end
[Z,f,H,t,Ep] = transferfnTD(Br,Er,Nc,Na);

th  = [0:Nc-1]'*Tw;
t   = [0:Tw*Nc-1]';
H   = interp1(th,H,t)/Tw;
Ep  = Hpredict(t,H,B);
