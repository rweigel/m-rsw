function lims = boot95(z)
    V = bootstrp(1000,@mean,z);
    if size(z,2) == 1
        V = transpose(V);
    end
    V = sort(V,2);
    upper = V(:,1000-50); 
    lower = V(:,50);
    lims = [lower, upper];
end
