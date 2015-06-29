function [Dg,UTg,DOYg,F] = ut_doy_ave(X,YEARS,Npd,WINDOWS,STEPS,FLAG)
%UT_DOY_AVE Average a time series by day of year (DOY) and universal time (UT)
%
%   [Dg,UTg,DOYg,F] = UT_DOY_AVE(X,YEARS) X is a single column array with
%   row separated by hours with the first element corresponding to data in
%   the range [0-1] UT of YEARS(1) and ending on the last interval of
%   YEARS(end).  The 366th day is simply removed for leap years.
%
%   UT_DOY_AVE(X,YEARS,Npd,[DOYwindow,UTwindow],[DOYstep,UTstep],FLAG)
%  
%   Npd       = num. of points per day (default = 24)
%   DOYwindow = num. of surrounding days to average over (default = 30)
%   UTwindow  = num. of surrounding points in UT to average over (default = 0)
%   DOYstep   = (default = 1)
%   UTstep    = (default = 1)
%   FLAG      = val. of data that should be ommitted from averaging 
%               (default = NaN)
%
%   F is the fraction of good data.
%
%   See also UT_DOY_AVE_DEMO

% R.S. Weigel, 07/01/2004  
if (nargin < 3)
  Npd = 24;
end
  
if (Npd*number_days(YEARS(1),YEARS(end)) ~= length(X))
  err_str = 'Length of X is inconsistent with number of time intervals in YEARS';
  error(sprintf('%s\n',err_str));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin < 4)
  WINDOWS = [30,0];
end
if (nargin < 5)
  STEPS = [1,1];
end
if (nargin < 6)
  FLAG = NaN;
end

if (isempty(WINDOWS))
  WINDOWS = [30,0];
end
if (isempty(STEPS))
  STEPS = [1,1];
end

DOYwindow = WINDOWS(1);
LTwindow  = WINDOWS(2);

DOYstep   = STEPS(1);
LTstep    = STEPS(2);

Nd        = Npd*365;  % Number of elements per year
D         = zeros(Nd,1);
YEARS     = [YEARS(1):YEARS(end)];  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove 366th day of year
for i = 1:length(YEARS)

  if is_leap_year(YEARS(i))
    delta = Npd;
  else
    delta = 0;
  end
  a      = 1 + Nd*(i-1)  + delta;
  b      = a + Nd - 1;
  D(:,i) = X(a:b,1);
end
% Each column of D contains first 365*Npd data points of year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Compute fraction of non-flag data
if (nargout > 3)
  F  = length(find(X ~= FLAG))/length(X); 
end

D   = D(:);
D   = reshape(D,Npd,length(D)/Npd);
% Each column of D now contains one day of data (Npd points)
Ix  = repmat([1:365],1,length(YEARS));

if (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New method.  10x faster because it avoids nested for loop but
% still wastes lots of flops.  Needs lots of memory.
Nut      = 1;
Ndoy     = 1;

for doy = 1:DOYstep:365
  Idoy      = doy_surround(doy,DOYwindow);
  J         = find(ismember(Ix,Idoy) == 1);
  JJ(doy,:) = J;
end

for ut  = 0:LTstep:(Npd-1)
  Iut         = 1 + ut_surround(ut,LTwindow,Npd);
  IDOY        = repmat(JJ,1,length(Iut));

  for i = 1:length(Iut)
    temp_c{i}  = Iut(i)*ones(size(JJ));
  end
  IUT         = cat(2,temp_c{:});
  II          = sub2ind(size(D),IUT,IDOY);
  Dg(Nut,:)   = mean_nonflag(D(II),2,FLAG,1)';
  Nut         = Nut + 1;

  fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bUT = %2.1f/%.1f',...
	  ut+0.5,Npd-0.5);

end
fprintf('\n');

[DOYg,UTg] = meshgrid([1:DOYstep:365]    + 0.5 ,...
		      [0:LTstep:(Npd-1)] + 0.5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% Old way (10x slower than above method when LTstep = 0)
if (1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For loops need to vectorized or put in loadable mex or oct function to
% speed things up.  Should be able to speed up considerably by just
% re-writing, however.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nut      = 1;
Ndoy     = 1;

for ut  = 0:LTstep:(Npd-1)
  Iut  = 1 + ut_surround(ut,LTwindow,Npd);
  Ndoy = 1;
  for doy = 1:DOYstep:365
    Idoy = doy_surround(doy,DOYwindow);
    J    = ismember(Ix,Idoy);
    J    = find(J == 1);

    temp           = D(Iut,J);
    Dg2(Nut,Ndoy)   = mean_nonflag(temp(:),1,FLAG,1);
    UTg2(Nut,Ndoy)  = ut + 0.5;
    DOYg2(Nut,Ndoy) = doy + 0.5;
    Ndoy           = Ndoy + 1;
  end

  fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bUT = %.1f/%.1f',...
	  ut+0.5,Npd-0.5);
  Nut  = Nut + 1;
end
fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1)
Dg   = Dg2;
UTg  = UTg2;
DOYg = DOYg2;
end

if (0)
max(abs(Dg(:) - Dg2(:)))
max(abs(UTg2(:) - UTg2(:)))
max(abs(DOYg2(:) - DOYg2(:)))
end

end
