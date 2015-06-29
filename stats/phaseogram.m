function dphase = phaseogram(T,aib,left)
%PHASEOGRAM
%
%  dphase = PHASEOGRAM(T,aib,k) compares the phase angle given by
%  exp(-i*phi) = a + ib with a reference wave with integer period T where
%  the reference wave has amplitude zero at k = 1, T+1, ...
%  
%  If phi = 90, then exp(-i*phi) = a + ib = 0 - ib, which equals to -90
%  degrees in the imaginary plane where i points along the +y-axis.
%  
%  If phi = 90 degrees and aib = 0 - i, then dphase is considered to be
%  zero.
%  

% Compute phase of reference wave (should really define left so that the
% left is used in place of (left - 1).
phases = 360*mod((left-1)./repmat(T,1,size(left,2)),1);

% Compute phase implied by aib 
phase = (180/pi)*atan2(imag(aib),real(aib));

% Map atan2 onto 0-360 degrees
phase(phase<0) = phase(phase<0)+360;

% The 180 degree rotation to make -90 degree in imaginary plane = 90 degrees.
% (Alternatively could shift reference wave by 180 degrees).
phase = -1*(phase-90);

% phase difference
dphase = phase - phases;

% Map back to 360 degrees
dphase = mod(dphase,360);

% deal with areas in dphase array where jumps occur, for example when
% phase(1) = 0, phases(1)=359 => dphase(1) = -1
dphase = (180/pi)*unwrap( (pi/180)*dphase,[],2 );

% Map back to 360 degrees again
dphase = mod(dphase,360);

% Not really needed except in special cases where it makes things 
% "look right".
dphase(dphase>359.999) = 0; 
