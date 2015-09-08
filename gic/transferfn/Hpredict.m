function Ep = Hpredict(t,H,B)

% Note that when not enough data are available, FILTER assumes input is zero.
% For causal filters (t > 0 only), first length(t) values are not based on
% full filter.

% When there are acausal terms t < 0, need to shift output of FILTER
% which only allows t >= 0 terms.
N       = find(t == 0);
tmp     = filter(H(:,2),1,B(:,2));
% Pad prediction with NaNs to make prediction array same length.
Ep(:,1) = [tmp(N:end);repmat(NaN,N-1,1)];
tmp     = filter(H(:,3),1,B(:,1)); % Hyx Bx
Ep(:,2) = [tmp(N:end);repmat(NaN,N-1,1)];
