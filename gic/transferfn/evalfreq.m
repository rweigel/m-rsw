function [fe,Ne,Ic] = evalfreq(f,method,N,verbose)
%EVALFREQ Select logarithmically spaced freqs from uniform freq. array.
%
%  [fe,Ne,Ic] = EVALFREQ(f)
%
%  If fo = f(end)/2 returns frequencies fe near
%
%   f(1) (if f(1) = 0, then f(2))
%   ...
%   fo/sqrt(2^k)
%   fo/sqrt(2^3)
%   fo/sqrt(2^2)
%   fo/sqrt(2)
%   fo/2
%
%   Result is approximately 8 frequencies per decade. The elements
%   of fe are all 
%
%   f(Ic) = fe.
%
%   Ne = floor(fe(k)/(2*(1/N))) is a number of points
%   to right an left of fe that can be used for averaging.

% TODO: Allow N to be interpreted as spacing by N^2 for
% method = 'logarithmic'

if nargin < 4
    verbose = 0;
end
if nargin < 3
    N = 1;
end
if nargin < 2
    method = 'logarithmic';
end

if strmatch(method,'linear','exact')
    % Linearly spaced center frequencies
    Ic = [N+2:2*N+1:length(f)-N]; % Indices of center points
    % e.g., if N = 3, first window center at 5 and
    % window will extend from 2 through 8.
    % second window center at 12 and window from 9 through 15.
    for j = 1:length(Ic)
        fe(j) = f(Ic(j)); % Evaluation frequency
        Ne(j) = N;        % Number of points to right and left used in window.
    end

    % Add zero frequency. Ne (# to include to left and right) will always
    % be 0 at fe=0 so that we never average f=0 with f ~= 0 values.
    if f(1) == 0
        fe = [0,fe]';
        Ne = [0,Ne]';
        Ic = [1,Ic]';
    end
    if size(f,1) > 0
        fe = fe';
        Ne = Ne';
        Ic = Ic';
    end
    return;
end

% Note that Simpson and Bahr Figure 4.2 sets fmin to the second
% lowest non-zero frequency. Here we set fmin to the lowest non-zero
% frequency.
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
fe(k) = f(end)/2;
Ne(k) = floor(fe(k)/(2*(1/N)));
Ic(k) = find(f-fe(1) >= 0,1);
if verbose
    fprintf('Computed evaluation frequency:      %.8f\n',fe(k));
    fprintf('Nearest equal or larger frequency available: %.8f\n',f(Ic(k))); 
    fprintf('Nearest equal or larger period available:    %.1f\n',1./f(Ic(k))); 
    
    fl = f(Ic(k)-Ne(k));    
    fr = f(Ic(k)+Ne(k));

    r = [Ic(k)-Ne(k):Ic(k)+Ne(k)];  
    if verbose
	fprintf('Window has %d points; fl = %.8f fr = %.8f\n',...
		length(r),fl,fr)
    	fprintf('Window has %.d points; Tl = %.1f Tr = %.1f\n',...
		length(r),1/fl,1/fr)
    end
end

while fe(k) > fmin
    
    k = k+1;

    tmp = fe(1)/sqrt(2^(k-1));
    %tmp = fe(1)/(1.1^(k-1));
    if (tmp < fmin),break,end
    fe(k) = tmp;
    Ic(k) = find(f-fe(k) >= 0,1);
    if verbose
        fprintf('Computed evaluation frequency:      %.8f\n',fe(k));
        fprintf('Nearest larger frequency available: %.8f\n',f(Ic(k))); 
        fprintf('Nearest larger period available:        %.1f\n',1./f(Ic(k)));     
    end
    fe(k) = f(Ic(k));

    % Number of points to left and right of fe to apply window to.
    % This formula was used to get a match to Figure 4.2 of Simpson and
    % Bahr. Another option is to use Ne = [0;diff(Ic)];
    Ne(k) = floor(fe(k)/(2*(1/N)));

    if verbose
        fl = f(Ic(k)-Ne(k));    
        fr = f(Ic(k)+Ne(k));
        %r = [Ic(k)-Ne(k):Ic(k)+Ne(k)];  
        fprintf('Window has %d points; fl = %.8f fr = %.8f\n',...
        		2*Ne(k)+1,fl,fr)
    	fprintf('Window has %d points; Tl = %.1f Tr = %.1f\n',...
                2*Ne(k)+1,1/fl,1/fr)
    end

end

if (verbose)
    fprintf('Created %d evaluation frequencies.\n',length(fe));
end
fe = fliplr(fe);
Ne = fliplr(Ne);
Ic = fliplr(Ic);

lo = length(fe);
[fe,Iu] = unique(fe);
Ne = Ne(Iu);
Ic = Ic(Iu);
if (lo > length(fe))
    if (verbose)
	fprintf('Removed %d duplicate frequencies.\n',lo-length(fe));
    end
end

% Add zero frequency and have outputs match dimension of input f.

if (size(f,1) > 0)
    fe = [0,fe]';
    Ne = [0,Ne]';
    Ic = [1,Ic]';
else
    fe = [0,fe];
    Ne = [0,Ne];
    Ic = [1,Ic];
end	



