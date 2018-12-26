function GIC = despikeGIC(tGIC,GIC)

% Remove spikes in GIC
GIC(:,3) = GIC(:,2);
I = find(abs(diff(GIC(:,2))) >= 0.04);
%I = [I;find( abs(GIC(3:end,2)-GIC(1:end-2,2)) >= 0.03)];
for i = 1:length(I)
    a = 2;b = 100;
    if (I(i) - a < 1),a = 0;end
    if (I(i) + b >= size(GIC,1)),b = 0;end
    GIC(I(i)-a:I(i)+b,3) = NaN;
end
Ig = ~isnan(GIC(:,3));
x = tGIC(Ig);
y = GIC(Ig,3);
GIC(:,3) = interp1(x,y,tGIC);
fprintf('main.m: Removed %d possible spikes in GIC.\n',length(I));
