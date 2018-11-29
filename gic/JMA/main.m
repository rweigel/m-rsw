addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

dt = 0;
dateo = '20060408'; % Best interval
datef = '20060410';

clear;

dateos = {'20061214','20060818','20061107','20060402','20060805','20060725','20071118','20071122','20061128','20061201'};
datefs = {'20061215','20060821','20061112','20060412','20060808','20060729','20071120','20071122','20061129','20061201'};
dts    = [    66    ,    17    ,    32    ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ];
0 % Full intervals

dt = 66;
dateo = '20061214';
datef = '20061215';

dt = 17;
dateo = '20060818'; % E field has ~4 hrs of bad data on 17th, so skip.
datef = '20060821';

dt = 32;
dateo = '20061107';
datef = '20061112';

dt = 0;
dateo = '20060402';
datef = '20060412';

dt = 0; % not checked
dateo = '20060805';
datef = '20060808';

dt = 0; % not checked
dateo = '20060725';
datef = '20060729';

dt = 0; % not checked
dateo = '20071118';
datef = '20071120';
% 21st has bad E and B data all of day. 
dt = 0;
dateo = '20071122';
datef = '20071122';

dt = 60; % not checked
dateo = '20061128'; 
datef = '20061129';
% 30th has no GIC data. 12/01 is fine.
dt = 60; % not checked
dateo = '20061201'; 
datef = '20061201';

png = 0;

FD_only = 1;
regenfiles = 1;

dirmat = sprintf('mat/%s',dateo);
if ~exist(dirmat,'dir'),mkdir(dirmat);end
dirfig = sprintf('figures/%s',dateo);
if ~exist(dirfig,'dir'),mkdir(dirfig);end

%!rm -f mat/*

% Read 1s E and B data from Kyoto
[tE,E,tB,B] = prepEB('second',dateo,datef,regenfiles); 

% Read GIC data from Watari
[tGIC,GIC]  = prepGIC(dateo,datef,regenfiles);        

% Correct for clock drift
tGIC = tGIC + dt;

close all

main_plot_raw(tGIC,GIC,tE,E,tB,B,dateo);

% Remove spikes in GIC
if (1)
    GIC(:,3) = GIC(:,2);
    I = find(abs(diff(GIC(:,2))) >= 0.04);
    %I = [I;find( abs(GIC(3:end,2)-GIC(1:end-2,2)) >= 0.03)];
    for i = 1:length(I)
        a = 2;b = 100;
        if (I(i) - a < 1),a = 0;end
        if (I(i) + b >= size(GIC,1)),b = 0;end
        GIC(I(i)-a:I(i)+b,3) = NaN;
    end
    Ig = ~isnan(GIC(:,3));
    x = tGIC(Ig);
    y = GIC(Ig,3);
    GIC(:,3) = interp1(x,y,tGIC);
    %GIC(:,2) = GIC(:,3);
end
fprintf('main.m: Removed %d possible spikes in GIC.\n',length(I));

% GIC spans shorter time range than E and B.  

% This pads out GIC
% with NaNs and interpolates over gaps (no gaps in GIC data - no timestamps
% in files and only use files with 86400 lines)

a = find(tE == tGIC(1));
b = 86400-a+1;
L = size(E,1);
% Trim off start and end of E and B so cover same timespan as GIC
E = E(a:L-b,:); 
B = B(a:L-b,:);
t = tGIC;

% Remove mean
for i = 1:2
    Ig = find(~isnan(E(:,i)));
    E(:,i) = E(:,i)-mean(E(Ig,i));
end
for i = 1:3
    Ig = find(~isnan(B(:,i)));
    B(:,i) = B(:,i)-mean(B(Ig,i));
end
for i = 1:size(GIC,2)
    Ig = find(~isnan(GIC(:,i)));
    GIC(:,i) = GIC(:,i)-mean(GIC(Ig,i));
end

save(sprintf('%s/main_%s.mat',dirmat,dateo),'GIC','E','B','t');

intervalno = 0;

mainCompute1(t,GIC,E,B,dateo,intervalno);
mainCompute2(t,GIC,E,B,dateo,intervalno);
close all;
main_plot_timeseries(dateo,intervalno,png);
main_plot_spectra(dateo,intervalno,png);
main_plot_H(dateo,intervalno,png);
main_plot_Z(dateo,intervalno,png);

rmold = sprintf('rm %s/mainCompute*_FD_%s-*.mat',dirmat,dateo);
system(rmold);

k = 1;
Tw = 3600*24;
Ts = 3600*24;
Io = [1:Ts:length(t)-Tw+1];
for io = Io(1:end)
    fn = 0;
    intervalno = k;
    fprintf('-------\nInterval %d of %d for %s\n',k,length(Io),dateo);
    k = k+1;
    Ix = [io:io+Tw-1];

    tr = t(Ix); % Time values for segment.
    Er = E(Ix,:);
    Br = B(Ix,:);
    GICr = GIC(Ix,:);
        
    mainCompute1(tr,GICr,Er,Br,dateo,intervalno);
    mainCompute2(tr,GICr,Er,Br,dateo,intervalno);
    close all
    main_plot_timeseries(dateo,intervalno,png);
    main_plot_spectra(dateo,intervalno,png);
    main_plot_H(dateo,intervalno,png);
    main_plot_Z(dateo,intervalno,png);
    %input('Continue?')
end
%main_plot_FD_summary(dateo,png)
