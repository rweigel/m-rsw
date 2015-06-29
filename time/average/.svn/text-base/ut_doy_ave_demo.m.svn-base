addpath('../');
addpath('../../stats/');
addpath('../../set/');
addpath('../../plot/');
% Title on plot
TitleText = 'Test plot';

year_o = 1997;
year_f = 1999;

% Generate a time series
x = zeros(24*number_days(year_o,year_f),1);

% Give time series some features

% Put spike at UT=0.5 of every day with a value of 10.
x(1:24:length(x)) = 10;

% Put a spike of value 100 at day 31 at UT=11.5 for all years
I     = 30*24 + 12;
I(2)  = I(1) + 365*24;
I(3)  = I(2) + 365*24;
x(I)  = 100;

% Average by UT and DOY
[D1,UT,DOY] = ut_doy_ave(x,[year_o:year_f],24,[],[],NaN);
D1(:,1)
100/(30+30+1)
subplot(2,1,1)
 plot(x);
subplot(2,1,2)
 pcolor2(UT(:,1),DOY(1,:),D1');
 xlabel('UT');
 ylabel('DOY');
 colorbar;
 
break

[D2,UT,DOY] = ut_doy_ave(x,[year_o:year_f],24,[30 1],[1 1],NaN);

D2(:,1)
100/((30+30+1)*3)
  
 



