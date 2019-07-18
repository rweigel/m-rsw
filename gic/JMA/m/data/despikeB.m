function B = despikeB(B,dateo)

Ib = [];

if 1 || dateo == '20060805'
    Ib = find(B > 5.7e4);
    if ~isempty(Ib)
        fprintf('despikeB.m: Removing %d values of B > 5.7e4 as probable missed spikes\n',length(Ib));
        B(Ib) = NaN;
    end
    Ib = [111585:115210];
    B(Ib,:,1) = NaN;
end

if ~isempty(Ib)
    for c = 1:size(B,2)
        t = [1:size(B,1)]';
        Ig = ~isnan(B(:,c,1));
        x = t(Ig);
        y = B(Ig,c,1);
        B(:,c,1) = interp1(x,y,t);
        fprintf('despikeB.m: Interpolated over %d of %d points in B_%d\n',size(B,1)-length(Ig),size(B,1),c);
    end
end
