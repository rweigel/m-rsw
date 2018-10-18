addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

dateo = '20061213';
datef = '20061215';

%dateo = '20060818';
%datef = '20060821';

dateo = '20060402';
datef = '20060410';

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
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Data don't look like 1s data.

% Read GIC data from Watari
[tGIC,GIC]  = prepGIC(dateo,datef,regenfiles);        

if (1)
    GIC(:,3) = GIC(:,2);
    I = find(abs(diff(GIC(:,3))> 0.1));
    for i = 1:length(I)
        GIC(I(i)-2:I(i)+40,3) = NaN;
    end
    I = ~isnan(GIC(:,3));
    x = tGIC(I);
    y = GIC(I,3);
    GIC(:,3) = interp1(x,y,tGIC);
    GIC(:,2) = GIC(:,3);
end

% GIC spans shorter time range than E and B.  This pads out GIC
% with NaNs and interpolates over gaps (no gaps in GIC data - no timestamps
% and only used files with 86400 lines)

% Repeat first point so interpolation yeilds multiple of 86400
% valid points.
dt = tGIC(2)-tGIC(1);
tGIC = [tGIC(1)-dt;tGIC];
GIC = [GIC(1,:);GIC];

GIC = interp1(tGIC,GIC,tE); 
tGIC = tE;

% Find first/last non-NaN GIC
Ig = find(~isnan(GIC(:,2)));
GIC  = GIC(Ig,:);
E    = E(Ig,:);
B    = B(Ig,:);
tGIC = tGIC(Ig);
tE   = tE(Ig);
tB   = tB(Ig);

main_plot_overview;

k = 1;
Io = [1:3600*4:length(tE)-86400+1];
for io = Io
    intervalno = k;
    fprintf('Interval %d of %d\n',k,length(Io));
    k = k+1;
    Ix = [io:io+86400-1];

    % Remove mean
    for i = 1:2
        Ig = find(~isnan(E(Ix,i)));
        Ex(Ix,i) = E(Ix,i)-mean(E(Ix(Ig),i));
    end
    for i = 1:3
        Ig = find(~isnan(B(Ix,i)));
        Bx(Ix,i) = B(Ix,i)-mean(B(Ix(Ig),i));
    end
    for i = 1:size(GIC,2)
        Ig = find(~isnan(GIC(Ix,i)));
        GICx(Ix,i) = GIC(Ix,i)-mean(GIC(Ix(Ig),i));
    end

    mainCompute1(GICx,Ex,Bx,Ix,dateo,intervalno)
    mainCompute2(GICx,Ex,Bx,Ix,dateo,intervalno)
end
% main_plot_FD
