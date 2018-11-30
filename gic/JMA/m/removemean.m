function [GIC,E,B] = removemean(GIC,E,B)

% Remove mean
for i = 1:2
    Ig = find(~isnan(E(:,i)));
    E(:,i) = E(:,i)-mean(E(Ig,i));
end
for i = 1:3
    Ig = find(~isnan(B(:,i)));
    B(:,i) = B(:,i)-mean(B(Ig,i));
end
for i = 1:size(GIC,2)
    Ig = find(~isnan(GIC(:,i)));
    GIC(:,i) = GIC(:,i)-mean(GIC(Ig,i));
end
