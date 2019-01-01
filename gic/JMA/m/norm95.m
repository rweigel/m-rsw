function lims = norm95(z)
    if size(z,2) == 1
        z = transpose(z);
    end
    m = mean(z,2);
    s = std(z,0,2);
    lower = m-1.96*s/sqrt(size(z,2));
    upper = m+1.96*s/sqrt(size(z,2));
    lims = [lower, upper];
end