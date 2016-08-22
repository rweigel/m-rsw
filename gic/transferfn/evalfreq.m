function [feP,NeP,IcP] = evalfreq(f,verbose)

if (nargin < 2)
    verbose = 0;
end

if (f(1) == 0)
    fmin = f(2);
    N = 2*(length(f)-1);
else
    fmin = f(1);
    N = 2*(length(f));
end


% Evaluation frequencies for frequency domain smoothing
if verbose
    fprintf('--\nComputing evaluation frequencies.\n--\n')
end
k = 1;
feP(k) = f(end)/2;
NeP(k) = floor(feP(k)/(2*(1/N)));
IcP(k) = find(f-feP(1) > 0,1);
if verbose
    fprintf('Computed evaluation frequency:      %.8f\n',feP(k));
    fprintf('Nearest larger frequency available: %.8f\n',f(IcP(k))); 
    fprintf('Nearest larger period available:    %.1f\n',1./f(IcP(k))); 
    
    fl = f(IcP(k)-NeP(k));    
    fr = f(IcP(k)+NeP(k));

    r = [IcP(k)-NeP(k):IcP(k)+NeP(k)];  
    if verbose
	fprintf('Window has %d points; fl = %.8f fr = %.8f\n',...
		length(r),fl,fr)
    	fprintf('Window has %.d points; Tl = %.1f Tr = %.1f\n',...
		length(r),1/fl,1/fr)
    end
end

while feP(k) > fmin
    k = k+1;
    tmp = feP(1)/sqrt(2^(k-1));
    %tmp = feP(1)/(1.1^(k-1));
    if (tmp < fmin),break,end
    feP(k) = tmp;
    IcP(k) = find(f-feP(k) > 0,1);
    if verbose
	fprintf('Computed evaluation frequency:      %.8f\n',feP(k));
	fprintf('Nearest larger frequency available: %.8f\n',f(IcP(k))); 
    fprintf('Nearest larger period available:        %.1f\n',1./f(IcP(k)));     
    end
    feP(k) = f(IcP(k));
    % Number of points to left and right of fe to apply window to.
    NeP(k) = floor(feP(k)/(2*(1/N)));
    fl = f(IcP(k)-NeP(k));    
    fr = f(IcP(k)+NeP(k));
    r = [IcP(k)-NeP(k):IcP(k)+NeP(k)];  
    if verbose
	fprintf('Window has %d points; fl = %.8f fr = %.8f\n',...
		length(r),fl,fr)
	fprintf('Window has %d points; Tl = %.1f Tr = %.1f\n',...
		length(r),1/fl,1/fr)
    end

end

if (verbose)
    fprintf('Created %d evaluation frequencies.\n',length(feP));
end
feP = fliplr(feP);
NeP = fliplr(NeP);
IcP = fliplr(IcP);

lo = length(feP);
[feP,Iu] = unique(feP);
NeP = NeP(Iu);
IcP = IcP(Iu);
if (lo > length(feP))
    if (verbose)
	fprintf('Removed %d duplicate frequencies.\n',lo-length(feP));
    end
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
