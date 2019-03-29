function [lims,bias] = boot(z,fn,N,n)
%BOOT
%
%
%

z = squeeze(z);

if nargin < 2
    fn = @mean;
end
if nargin < 3
    N = 1000;
end
if nargin < 4
    n = 50;
end

if size(z,2) == 1
    z = transpose(z);
end

V = bootstrp(N,fn,z); % Each row in V contains N bootstrap samples from that row in z
V = sort(V,1); % Sort each column
l = V(n,:);
u = V(N-n+1,:); 
lims = [l',u'];


end
