
http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&correct=true&units=DEF&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot
http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot

http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&correct=true&units=DEF&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=ascii
http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=ascii


http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=NEK32&loc=--&cha=LFE&starttime=2018-05-09T23:00:00&endtime=2018-05-10T01:00:00&output=plot
http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=NEK32&loc=--&cha=LFE&correct=true&units=DEF&starttime=2018-05-09T23:00:00&endtime=2018-05-10T01:00:00&output=plot

% ORF03, LQE, counts
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot

sta = 'ORF03';
cha = 'LQE';
start = '

urlwrite('http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot','Counts.png');
Ic = imread('Counts.png');

figure(1);
imagesc(Ic);
grid on;
set(gca,'YTick',[32:1:1000])
break

% (determined from zooming in)
% 0 counts @ 559
% 8 counts @ 143
% Max @ 31
% Min @ 670
% => max - min = 8*(670-31)/(599-143) = 11.2 e5 Counts

% ORF03, LQE, natural
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&correct=true&units=DEF&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot
% Note the inconsistent filename created by API.  Should start with EM.ORF03..?
urlwrite('http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot','Natural.png');
In = imread('Natural.png');

figure(2);
imagesc(In);
grid on;
set(gca,'YTick',[32:1:1000])

% My calculation.
% -1 @ 602
% 1.5 @ 127
% Max @ 31
% Min @ 670
% => max - min = 2.5*(670-31)/(602-127) = 3.36 e-5 V/m

% => (3.36e-5 V/m) / (11.2e5 Counts) = 3.0e-11 (V/m)/Count = 3.0e-5 (V/m)/Count

% Anna's calculation
% length_X = 100; % m (approximate)
% length_Y = 100; % m (approximate)
% gain     = 200; % (approximate)
% Ecount   = 8.192*1e3/(256*256*256)/gain; % 2.4414e-6 (units? 8192 is 2^13
% - where is this from?)
% lengthX  = Ex_wire_length*1e-3; % km
% lengthY  = Ey_wire_length*1e-3; % km
% EX = Data(4,:)*Ecount/lengthX; % mV/km
% EY = Data(5,:)*Ecount/lengthY; % mV/km

% If Data is in counts, then conversion factor is 2.4414e-6/0.1, e.g.,
% (mV/km)/Count = 2.4414e-7 
% or
% (V/m)/Count = 2.4414e-13 






