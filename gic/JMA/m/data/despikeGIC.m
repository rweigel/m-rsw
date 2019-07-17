function [GIC,N,f] = despikeGIC(GIC)
% DESPIKEGIC Remove spikes in GIC
%
%   [GIC,N,f] = despikeGIC(GIC)
%
%   GIC is a Nx1 or 1xN matrix
%   N is the number of spikes found
%   f is the fraction of data modified

a = 2;
b = 100;

I = find(abs(diff(GIC)) >= 0.05);
for i = 1:length(I)
    if (I(i) - a < 1)
        a = 0;
    end
    if (I(i) + b >= length(GIC))
        b = 0;
    end
    GIC(I(i)-a:I(i)+b) = NaN;
end
Ig = ~isnan(GIC);
N = length(I);
f = (length(GIC)-length(find(Ig==1)))/length(GIC);
t = [1:length(GIC)]';
GIC = interp1(t(Ig),GIC(Ig),t);
fprintf('despikeGIC.m: Removed %d possible spikes in GIC. %.2f%% of data modified.\n',N,100*f);
