function [GIC,E,B] = removemean(GIC,E,B)

% Remove mean
for i = 1:size(E,2)
    Ig = find(~isnan(E(:,i)));
    E(:,i) = E(:,i)-mean(E(Ig,i));
end
for k = 1:size(B,3)
    for i = 1:size(B,2)
        Ig = find(~isnan(B(:,i,k)));
        B(:,i,k) = B(:,i,k)-mean(B(Ig,i,k));
    end
end
for i = 1:size(GIC,2)
    Ig = find(~isnan(GIC(:,i)));
    GIC(:,i) = GIC(:,i)-mean(GIC(Ig,i));
end
