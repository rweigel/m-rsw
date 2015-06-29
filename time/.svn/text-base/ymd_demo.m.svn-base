clear ymd;

ymd([365*24*60*60,367*24*60*60],2000,'sec')     
ymd([365*24*60,367*24*60],2000,'min')     
ymd([365*24,367*24],2000,'hour')     
ymd([365+1,367+1],2000)     

ymd(365*24*60*60,2000,'sec')
ymd(365*24*60,2000,'min')
ymd(365*24,2000,'hour')
ymd(365+1,2000)     

ymd(0,2000,'sec')
ymd(0,2000,'min')
ymd(0,2000,'hour')
ymd(0+1,2000)

tic
ymd([1:number_days(0,2000)],0);
toc

% If exectued from Matlab, compares answers using Matlab's DATENUM and
% DATEVEC.

% Get date vector for DOY 10, year 2000 using YMD.
DV = ymd(10,0)

% Which is equivalent to 10 + the number of days from day 1 0000 to the last
% day of 1999.
N  = 10;

% Invert this to get DV back
DV = ymd(N)

% Compare YMD with MATLAB's DATEVEC.
if ( is_octave == 0 )
  fprintf('Comparing answer with Matlab function DATEVEC');
  N  = datenum(2000,1,10)
  N  = number_days(0,1999) + 10
  tic
  V  = ymd([1:now*2]',0);
  toc
  tic
  Vm = datevec(datenum([1:now*2]));
  toc
  max(V-Vm(:,1:3))
end

% Compare YMD with OCTAVE function DATEVEC.
if ( is_octave == 1 )
  fprintf('Comparing answer with Octave function DATEVEC\n');
  N  = datenum(2000,1,10)
  N  = number_days(0,1999) + 10
  tic
  V  = ymd([1:now*2]',0);
  toc
  tic
  Vm = datevec(datenum([1:now*2]));
  toc
  max(V-Vm(:,1:3))
end

% Compare YMD with DATEVEC using fractional days
fprintf('Comparing answer with DATEVEC\n');
Ns = 24*60*60;
for i = 1:121%Ns-1
  V1(i,:) = ymd(725000+i/Ns);
  V2(i,:) = datevec(725000+i/Ns);
  if (V1(i,5) ~= V2(i,5))
    fprintf('V1(%d,:) = %4d %2d %2d %2d %2d %.8f\n',i,V1(i,:)');fflush(stdout);
    fprintf('V2(%d,:) = %4d %2d %2d %2d %2d %.8f\n',i,V2(i,:)');fflush(stdout);
  end
end

Ns = 60*60;
for i = 1:60%Ns-1
  V1(i,:) = ymd(725000+i/Ns);
  V2(i,:) = datevec(725000+i/Ns);
  if (V1(i,5) ~= V2(i,5))
    fprintf('V1(%d,:) = %4d %2d %2d %2d %2d %.8f\n',i,V1(i,:)');fflush(stdout);
    fprintf('V2(%d,:) = %4d %2d %2d %2d %2d %.8f\n',i,V2(i,:)');fflush(stdout);
  end
end

% looks like DATEVEC has some problems!
% (10/3600)*24*60 = 4

% Another example case where datevec gets the wrong answer:
datevec(10.2)
% Minute should be 48! (.2*24=4.8 => .8*60 = 48)
ymd(10.2)


V  = ymd([1:32]',2003*ones(32,1),'day');
V  = ymd([0:24*32-1]',2003*ones(24*32,1),'hour');
V  = ymd([1:24*61]',2003*ones(24*61,1),'min');

