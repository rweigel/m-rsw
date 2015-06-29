function [To,PSDo,AIBo,LEFTo,x_c,Tall,Pall] = spectrogram(x,wo,Nw,dw,dx,Tmin,Tmax);
%SPECTROGRAM
%   
%   SPECTROGRAM(x,w)
%
%   Computes a spectrogram of array x with non-overlapping windows
%   of width w
%
%   SPECTROGRAM(x,w,Nsw)
%
%   Create a higher-resolution (in frequency) spectrogram by computing
%   periodogram at each point in time Nsw (N sub-window) times.  First
%   sub-window is of width w and each subsequent window is 2 points
%   smaller.
%  
%   SPECTROGRAM(x,w,Nsw,dw)
%   
%   Each subwindow is 2*dw smaller than the previous.  Default is dw = 1.
%
%   SPECTROGRAM(x,w,Nsw,dw,dx)
%
%   Compute overlapping spectrogram by shifting each window center
%   by dx instead of the default of w.
%
%   Center points at xc = [w/2+0.5:dx:length(x)-w/2+0.5]; At each center
%   point, computes periodogram Nsw times.  First sub-window is of width w
%   and each subsequent window is 2*dw points smaller.  Use Nsw = Inf to
%   compute until window with has shrunk to four points.
%
%   SPECTROGRAM(x,w,Nsw,dw,dx,Tmin,Tmax)
%

if (nargin < 3)
  Nw = 1;
end
if (nargin < 4)
  dw = 1;
end
if (nargin < 5)
  dx = wo;
end
if (nargin < 6)
  Tmax = Inf;
end
if (nargin < 7)
  Tmin = 0;Tmax = Inf;
end

if (nargout > 5)
  [Tall,Pall] = spectrogram(x',length(x),1,0,0,Tmin,Tmax);
end

flip_x = 0;  
if (size(x,1)==1)
  flip_x = 1;
  x = x';
end
%if iseven(length(x))
  x_c = wo/2+0.5;     % First center point.
  if (wo < length(x));
    x_c = [x_c:dx:length(x)-wo/2+0.5];
  end
%end

if Nw > floor(1 + (wo-4)/(2*dw))
  Nw = floor(1 + (wo-4)/(2*dw));
  warning(sprintf('Nsw is too large.  Setting to %d',Nw));
end

for i = 1:length(x_c)
  if (mod(i,10) == 0) || (i == 1)
    fprintf('spectogram: Interval %02d/%d. Center = %.1f. Nsw = %d.',...
	    i,length(x_c),x_c(i),Nw);
  end
  tic();
  tmpT = [];
  for j = 1:Nw

    w     = wo - 2*dw*(j-1);  % window width at a given center point x_c(i)
    
    left  = x_c(i)-(w-1)/2; % left boundary
    right = x_c(i)+(w-1)/2; % right boundary
    xs    = x(left:right);  % Subsegment
    %W    = tukeywin(length(xs));
    W     = 1;
    tmp   = fft(W.*(xs-mean(xs)));
    N_nan = sum(isnan(xs));        % Number of NaN values

    if (N_nan == 0)
      psd = tmp.*conj(tmp);        
      psd = psd(2:end);            % Remove D.C. value
      aib = tmp(2:end);            % fourier coefficients a+ib
    else
      psd = repmat(NaN,size(xs));  % Return NaN if any value in xs is NaN
      aib = repmat(NaN,size(xs));
    end
    
    N = length(xs);
    f = [1:N/2]'/N;   
    T = 1./f;

    aI  = find(T>Tmin & T<Tmax);
    if isempty(aI)
      fprintf('spectogram: All values of T are less than Tmin (at window\n');
      fprintf('            number %d/%d)\n',j,Nw);
      aI = 1;
    end
    T   = T(aI);

    psd = psd(aI);
    aib = aib(aI);

    [T,I] = sort(T);    % Put period in ascending order
    psd   = psd(I);     % Line up psd vector with T by sorting.
    aib   = aib(I);     % Line up aib vector with T by sorting.
                        % Note the above drops out the first 1/2 of the data.

    psd = psd/(length(psd)).^2; % Normalize by square of number of points
    psd = psd/mean(psd);        % Normalize by mean


    
    tmpleft{j,1} = repmat(left,size(T));
    tmpTc{j,1}   = T;
    %tmpT         = [tmpT;T];
    tmpPSDc{j,1} = psd;
    tmpAIBc{j,1} = aib;
    if(0)
    fprintf(...
'spectogram: sub-interval %d/%d. left, center, right = %d, %.1f, %d\n',...
	j,Nw,left,left+(right-left)/2,right);
    end
  end



  Tc{i}      = cat(1,tmpTc{:,1});   % Combine all Tc (Period) values
  PSDc{i}    = cat(1,tmpPSDc{:,1}); % Combine all Pc (Periodogram) values
  AIBc{i}    = cat(1,tmpAIBc{:,1}); % Combine all AIBc (a + ib) values
  LEFTc{i}   = cat(1,tmpleft{:,1}); % Combine all AIBc (a + ib) values


%  xtmp = Tc{i};
%  whos xtmp
  [To(1,:),I] = sort(Tc{i});       % Sort on period
%  toc  

  if (i == 1)
    % Approximate memory requirements without 
    memrequired = 3*length(x_c)*length(I)*8/1e9;
    if memrequired > 2
      fprintf('\nApproximate memory required = %.2f GB\n',memrequired);
      input('Continue? (Enter to continue, CTRL-C to abort)');
      %error(sprintf('Too much memory required'));
    end
    PSDo  = zeros(length(x_c),length(I));
    AIBo  = zeros(length(x_c),length(I));
    LEFTo = zeros(length(x_c),length(I));
  end

  PSDo(i,:)   = PSDc{i}(I);        % Re-order output periodogram values
  AIBo(i,:)   = AIBc{i}(I);        % Re-order output phase values
  LEFTo(i,:)  = LEFTc{i}(I);
  
  if (mod(i,10) == 0) || (i == 1)
    fprintf(' %.2f seconds\n',toc());
  end

end

if (flip_x == 1)
  To    = To';
  PSDo  = PSDo';
  AIBo  = AIBo';
  LEFTo = LEFTo';
end
