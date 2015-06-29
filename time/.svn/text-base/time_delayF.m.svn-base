function [T,xd,t] = time_delayF(T,x,Nc,Ts,Na)
%TIME_DELAYF Fast and low-memory version of TIME_DELAY
%
%   Calls time_delayF.c to create time delay matrix.  time_delayF.c
%   removes rows with NaN values.
%  
%   If length(T)/(Na+Nc) or Na > 0, may have fewer rows than what is given
%   by TIME_DELAY.
  
Lf = Nc+Na;
Nd = Lf;

if ~exist('/tmp/ramdisk')
  % sudo mount -t tmpfs none /tmp/ramdisk -o size=8g
  mkdir('/tmp/ramdisk');
end

%Nl = Lf*floor(length(x)/Lf);
%x = x(1:Nl);
%T = T(1:Nl);

fid = fopen('/tmp/ramdisk/in.bin','w');
cnt = fwrite(fid,x,'double');
fclose(fid);
clear x

bindir = fileparts(which('time_delayF.m'));
com = sprintf('gcc %s/time_delayF.c -o %s/time_delayF',bindir,bindir);
system(com);
com = sprintf(['%s/time_delayF /tmp/ramdisk/in.bin /tmp/ramdisk/out.bin' ...
	       ' /tmp/ramdisk/time.bin %d %d 0 %d'],bindir,length(T),Lf,Nd);
fprintf('Calling time_delayF ...');
system(com);
fprintf('Done.\n');

fprintf('Reading time.bin ...');
fid = fopen('/tmp/ramdisk/time.bin','r');
t   = fread(fid,Inf,'double');
fclose(fid);
fprintf('Done.\n');

fprintf('Reading out.bin ...');
fid = fopen('/tmp/ramdisk/out.bin','r');
xd  = fread(fid,Lf*length(t),'double');
fclose(fid);
xd  = fliplr(reshape(xd,Nd,length(xd)/Nd)');
t = t+Nc+1;
T = T(t);
fprintf('Done.\n');

I = find(isnan(T)==0);
T = T(I);
xd = xd(I,:);
t = t(I);

if (Ts > 0)
  error('');
end






