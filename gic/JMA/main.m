addpath('../../time');
addpath('../../stats');
addpath('../transferfn');

clear;

[tGIC,GIC]  = prepGIC();        % Read GIC data from Watari
[tE,E,tB,B] = prepEB('second'); % Read 1s E and B data from Kyoto
%[tEd,Ed,tBd,Bd] = prepEB('decisecond'); % Data don't look like 1s data.

% GIC spans shorter time range than E and B.  This pads out GIC
% with NaNs and interpolates over gaps (but there were no gaps).
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

% Remove mean
GIC = GIC - repmat(mean_nonflag(GIC),size(GIC,1),1);
E = E - repmat(mean_nonflag(E),size(E,1),1);
B = B - repmat(mean_nonflag(B),size(B,1),1);

% Use first half of data
Ix = [1:floor(size(E,1)/2)];

mainCompute1
mainCompute2
main_plot


