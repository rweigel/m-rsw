function [feP,NeP,IcP] = evalfreq(f,verbose)

if nargin < 2
  verbose = 0;
end
s = dbstack;
n = s(1).name;

N = 2*(length(f)-1);
% Evaluation frequencies for frequency domain smoothing
fprintf('%s: Computing evaluation frequencies.\n',n)
k = 1;
feP(k) = f(end)/2;
NeP(k) = floor(feP(k)/(2*(1/N)));
IcP(k) = find(f-feP(1) > 0,1);
if verbose
  fprintf('%s: Computed evaluation frequency:      %.8f\n',n,feP(k));
  fprintf('%s: Nearest larger frequency available: %.8f\n',n,f(IcP(k))); 
end
while feP(k) > f(2)
    k = k+1;
    tmp = feP(1)/sqrt(2^(k-1));
    if (tmp < f(2)),break,end
    feP(k) = tmp;
    IcP(k) = find(f-feP(k) > 0,1);
    if verbose
      fprintf('%s: Computed evaluation frequency:      %.8f\n',n,feP(k));
      fprintf('%s: Nearest larger frequency available: %.8f\n',n,f(IcP(k)));
    end
    feP(k) = f(IcP(k));
    % Number of points to left and right of fe to apply window to.
    NeP(k) = floor(feP(k)/(2*(1/N)));
    %f(IcP(k)-NeP(k))
end

if verbose
  fprintf('%s: Created %d evaluation frequencies.\n',n,length(feP));
end
feP = fliplr(feP);
NeP = fliplr(NeP);
IcP = fliplr(IcP);

lo = length(feP);
[feP,Iu] = unique(feP);
NeP = NeP(Iu);
IcP = IcP(Iu);
if (lo > length(feP))
    fprintf('%s: Removed %d duplicate frequencies.\n',n,lo-length(feP));
end

% Add zero frequency and have outputs match dimension of input f.
if (size(f,1) > 0)
  feP = [0,feP]';
  NeP = [0,NeP]';
  IcP = [1,IcP]';
else
  feP = [0,feP];
  NeP = [0,NeP];
  IcP = [1,IcP];
end	
