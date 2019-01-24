function [t,E,B] = timealign(tGIC,tE,E,B)
%TIMEALIGN Force E and B time series to have same start/end time as GIC

% Due to GIC starting at JST of midnight, GIC spans
% shorter time range than E and B. 

% Align start and stop times.
a = find(tE == tGIC(1));
b = 86400-a+1;
L = size(E,1);

% Trim off start and end of E and B so cover same timespan as GIC
E = E(a:L-b,:); 
B = B(a:L-b,:);
t = tGIC;
