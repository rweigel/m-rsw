% ORF03, LQE, counts
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot

urlwrite('http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot','ORF03_E_Counts.png');
Ic = imread('ORF03_E_Counts.png');

figure(1);clf
imagesc(Ic);
grid on;
set(gca,'YTick',[32:1:1000])

% (determined from zooming in)
% 0 counts @ y = 559
% 8 counts @ y = 143
% Max @ 32
% Min @ 670
% => max - min = 8*(670-32)/(559-143) = 12.26 e5 Counts

% ORF03, LQE, natural
% http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&correct=true&units=DEF&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot
% Note the inconsistent filename created by API.  Should start with EM.ORF03..?
urlwrite('http://service.iris.edu/irisws/timeseries/1/query?net=EM&sta=ORF03&loc=--&correct=true&cha=LQE&starttime=2007-09-01T00:00:00&endtime=2007-09-01T23:59:59&output=plot','ORF03_E_Natural.png');
In = imread('ORF03_E_Natural.png');

figure(2);clf;
imagesc(In);
grid on;
set(gca,'YTick',[32:1:1000])

% -1 @ y = 602
% 1.5 @ y = 127
% Max @ y = 32
% Min @ y = 670
% => max - min = 2.5*(670-31)/(602-127) = 3.36 e-5 V/m

% => (3.36e-5 V/m) / (12.26e5 Counts) = 2.7e-11 (V/m)/Count = 2.7e-5 (mV/km)/Count

% Anna's calculation
% length_X = 100; % m (approximate)
% length_Y = 100; % m (approximate)
% gain     = 200; % (approximate)
% Ecount   = 8.192*1e3/(256*256*256)/gain; % 2.4414e-6 (units?, what is 8.192 from)
% lengthX  = Ex_wire_length*1e-3; % km
% lengthY  = Ey_wire_length*1e-3; % km
% EX = Data(4,:)*Ecount/lengthX; % mV/km
% EY = Data(5,:)*Ecount/lengthY; % mV/km

% If Data is in counts, then conversion factor is 2.4414e-6/0.1, e.g.,
% (mV/km)/Count = 2.4414e-5 
% or
% (V/m)/Count = 2.4414e-11 






