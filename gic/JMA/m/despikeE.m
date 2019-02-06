function E = despikeE(t,E)

for c = 1:size(E,2) % Columns
    I = find(abs(diff(E(:,c))) >= 1); % Find spikes
    for i = 1:length(I)
        a = 2;b = 4;
        if (I(i) - a < 1),a = 0;end
        if (I(i) + b >= size(E,1)),b = 0;end
        E(I(i)-a:I(i)+b,c) = NaN;
    end
    Ig = ~isnan(E(:,c));
    x = t(Ig);
    y = E(Ig,c);
    E(:,c) = interp1(x,y,t);
    f = (size(E,1)-length(find(Ig == 1)))/size(E,1);
    fprintf('despikeE.m: Removed %d possible spikes in E(:,%d). %.2f%% of data modified\n',length(I),c,100*f);
end