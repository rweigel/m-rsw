function spectrogram_demo(demo_to_run,plotit,printit,rerunit)
%SPECTROGRAM_DEMO Runs demos for SPECTROGRAM
%
%   SPECTROGRAM_DEMO - runs demo number 6
%   SPECTROGRAM_DEMO(demo) - runs specified demo
%
%   SPECTROGRAM_DEMO(demo_to_run,plotit,printit,rerunit)
%   where the last three arguments are zero or one (default).
%   Set rerunit to plot or print previously computed spectrogram.
%
% Notes:  
%
% - In plots with only one vertical strip, width of strip is arbitrary
%   because there is only one center point.
%
% - If shown, ignore black lines that surround white areas.  They show NaN
%   values of matrix inserted to force pcolor to display the matrix
%   in a sensible manner.
%
% - Horizontal green lines show period values.  Note that period values
%   are not centered. Lines are suppressed if there are too many of them.
%
% - Green and black boundary lines are not shown if there are more than
%   10 intervals in period or time.  When w is small, they won't be
%   centered on the colored patches because of how computation for patch
%   boundary is performed.  Need to address this by
%   (1) For Nw = 1, explicitly compute boundaries
%   (2) For Nw > 1, deal with overlapping boundaries (modify spectrogram so
%   that it gives upper and lower boundary for each period).
%   Composite plot will be overlapping patches of different sizes.
%
%   See also BANDPASS_DEMO.

addpath('../plot');
addpath('../is');
addpath('../time');

if (nargin == 0)
  demo_to_run = 6;
end
if (nargin < 2)
  plotit = 1;
end
if (nargin < 3)
  printit = 1;
end
if (nargin < 4)
  rerunit = 1;
end

if ~exist('spectrogram','dir')
  mkdir('./spectrogram');
end
figname = sprintf('./spectrogram/spectrogram_demo%d',demo_to_run);

figure(demo_to_run);

switch demo_to_run

 case 1  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 1.  A single wave.  Window width = period (= number of points).
  x  = [0.0, 1, 0.0, -1];       
  w  = 4;  % Width of window
  
  [T,P,aib,left,d_o] = spectrogram(x,w);
  spectrogram_plot(x,T,P,aib,d_o,left);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 case 2  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 2. Two waves.  Window width = 2*period (= number of pts).
  x  = [0.0, 1, 0.0, -1];
  x  = [x,x];
  w  = 4;  % Width of window
  Nw = 1;  % Number of windows
  
  [T,P,aib,left,d_o] = spectrogram(x,w);
  spectrogram_plot(x,T,P,aib,d_o,left);
  % - Note difference in amplitude compared to first plot.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 case 3  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 2. Two waves.  Window width = 2*period (= number of pts).
  x  = [0.0, 1, 0.0, -1];
  x  = [x,x];
  w  = 8;  % Width of window
  Nw = 2;  % Number of windows
  
  % Horizontal green lines mark the periods.
  % Note how some colored patches are thicker.
  
  [T,P,aib,left,d_o] = spectrogram(x,w);
  spectrogram_plot(x,T,P,aib,d_o,left);
  % - Note difference in amplitude compared to first plot.
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 case 4  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 4. Three sine waves.   First spectrogram operates on all three.
  % Second operates on inner wave only.  The periods are degenerate for
  % T=4.  At T=4 periodogram is the same for both.
  
  x  = [0.0, 1, 0.0, -1];
  x  = [x,x,x];
  w  = 12; % Width of window
  Nw = 1;  % Number of windows
  
  [T,P,aib,left,d_o] = spectrogram(x,w,Nw);
  spectrogram_plot(x,T,P,aib,d_o,left);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 case 5  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 5 
  T  = 16;
  w  = 2*pi/T;
  t  = [0:100*T-1];
  x  = sin(w*t) + sin(2*w*t);
  %x  = x;+0.1*randn(1,length(x));
  Nw = 3; % Number of windows
  w  = 10*T;  % Width of window
  dw = 1; 
  dx = 2;  % Shift window center by 1/2 of a wave (180 degrees)
	   % Horizontal green lines mark the periods.
  [T,P,aib,left,d_o] = spectrogram(x,w,Nw,dw,dx,6,20);
  spectrogram_plot(x,T,P,aib,d_o,left);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
case 6
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % 
 T  = 16;
 w  = 2*pi/T;
 t  = [0:10*T-1];
 x  = sin(w*t) + cos(2*w*t);
 Nw = 32;  % Number of windows
 w  = 6*T;  % Width of window
 dw = 1; 
 dx = 2;  
 % Horizontal green lines mark the periods.
 
 [T,P,aib,left,d_o,T1,P1] = spectrogram(x,w,dw,dx,Nw,0,Inf);
 spectrogram_plot(x,T,P,aib,d_o,left,T1,P1);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 case 7
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Case 7.  Hourly averaged Sunspot Number starting in [00:00-01:00) UT on
  % January 1, 1963.
  if ~exist('./spectrogram/spectrogram_demo7.mat')
    X = ts_get('R Sunspot number (OMNI2 1-hour)');
    x  = X(1:end-4416); clear SSN; % Remove NaNs (all at end)
    save ./spectrogram/spectrogram_demo7.mat x;
  else
    load ./spectrogram/spectrogram_demo7.mat
  end
  Nw = 1;        % Number of windows
  w  = 24*27*10; % Width of window
  dw = 24;       % For each Nw, shrink w by this amount on left and right.
  dx = 24*1;     % Shift of window center.  Ignored if w=length(x).
  
  [T,P,aib,left,d_o,T1,P1] = spectrogram(x',w,Nw,dw,dx,24*10,24*60);
  spectrogram_plot(x,T/24,P,aib,d_o,left,T1/24,P1);
  save ./spectrogram/spectrogram_demo7.mat x T P aib left d_o T1 P1;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 case 8
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  if ~exist('./spectrogram/spectrogram_demo8.mat')
    X = ts_get('Plasma (Bulk) speed (OMNI2 1-hour)');
    save ./spectrogram/spectrogram_demo8.mat X;
  else
    load ./spectrogram/spectrogram_demo8.mat
  end
  if (rerunit)
    Nh    = length(X);                % Number of hours
    Igood = find(isnan(X)==0);
    Xgood = X(Igood);
    Xgood = [Xgood(1);Xgood;Xgood(end)];
    Igood = [1;Igood;Nh];
    x     = interp1(Igood,Xgood,[1:Nh],'linear');
    
    Nh = length(x);   % Number of non-NaN hours
    Nw = 20;          % Number of windows
    w  = 24*27*10;    % Width of window
    dw = 24;          % For each Nw, shrink w by this amount on left and right.
    dx = 24*1;        % Shift of window center.  Ignored if w=length(x).
    
    
    [T,P,aib,left,d_o,T1,P1] = spectrogram(x,w,dw,dx,Nw,24*10,24*60,1963);
    save ./spectrogram/spectrogram_demo8.mat X x T P aib left d_o T1 P1;
  end
  if (plotit)
    spectrogram_plot(x,T/24,P,aib,d_o,left,T1/24,P1);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 case 9
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  if ~exist('./spectrogram/spectrogram_demo9.mat')
    X = ts_get('Bx near Earth (GSE) (OMNI2 1-hour)');
    save ./spectrogram/spectrogram_demo9.mat X;
  else
    load ./spectrogram/spectrogram_demo9.mat
  end

  if (rerunit)
    Nh    = length(X);                % Number of hours
    Igood = find(isnan(X)==0);
    Xgood = X(Igood);
    Xgood = [Xgood(1);Xgood;Xgood(end)];
    Igood = [1;Igood;Nh];
    x     = interp1(Igood,Xgood,[1:Nh],'linear');
    
    Nh = length(x);  % Number of non-NaN hours
    Nw = 10;         % Number of windows
    w  = 24*27*10;   % Width of window
    dw = 24;         % For each Nw, shrink w by this amount on left and right.
    dx = 24*1;       % Shift of window center.  Ignored if w=length(x).
    Tkeep = 24*[12 15;24 28];
    
    [T,P,aib,left,d_o,T1,P1] = spectrogram(x,w,dw,dx,Nw,24*10,24*60);
    save ./spectrogram/spectrogram_demo9.mat X x T P aib left d_o T1 P1;
  end
  if (plotit)
    spectrogram_plot(x,T/24,P,aib,d_o,left,T1/24,P1,1963);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  
 case 10
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  if ~exist('spectrogram_demo10.mat')
    X = ts_get('Ulysses Plasma Flow speed, RTN (COHOWeb 1-hour)');
    save ./spectrogram/spectrogram_demo10.mat X;
  else
    load spectrogram_demo10.mat
  end
  latstr = 'Ulysses Helographic Inertial latitude of ';
  lat    = ts_get(latstr);
  
  Nh    = length(X);                % Number of hours
  Igood = find(isnan(X)==0);
  Xgood = X(Igood);
  Xgood = [Xgood(1);Xgood;Xgood(end)];
  Igood = [1;Igood;Nh];
  x     = interp1(Igood,Xgood,[1:Nh],'linear');
  
  Nh = length(x); % Number of non-NaN hours
  Nw = 40;        % Number of windows
  w  = 24*27*10;  % Width of window
  dw = 24;        % For each Nw, shrink w by this amount on left and right.
  dx = 24*1;      % Shift of window center.  Ignored if w=length(x).
  Tkeep = 24*[12 15;24 28];
  
  [T,P,aib,left,d_o,T1,P1] = spectrogram(x,w,dw,dx,Nw,24*10,24*60);
  spectrogram_plot(x,T/24,P,aib,d_o,left,T1/24,P1,1990);
  save ./spectrogram/spectrogram_demo10.mat X x T P aib left d_o T1 P1;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end % case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (printit == 1)
  fprintf('plotcmds: Writing %s.eps\n',figname);
  eval(sprintf('print -painters -depsc %s.eps',figname))
  fprintf('plotcmds: Converting %s.eps to png\n',figname);
  system(sprintf('convert -quality 100 -density 100 %s.eps %s.png',...
		 figname,figname));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%