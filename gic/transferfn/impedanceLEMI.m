 function [Z,f] = impedanceLEMI(ide_file)

fid = fopen(ide_file);
ide = textscan(fid,...
    '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',...
    'headerlines',3);
fclose(fid);

ide = cell2mat(ide);

% sort in ascending order by frequency column
ide = sortrows(ide,1); 

f = ide(:,1);

ZXXR = ide(:,3); % real part of Zxx
ZXXI = ide(:,4); % imaginary part of Zxx
ZXX  = ide(:,3) + ide(:,4);

ZXYR = ide(:,6);
ZXYI = ide(:,7);
ZXY  = ide(:,6) + ide(:,7);

ZYXR = ide(:,9);
ZYXI = ide(:,10);
ZYX  = ide(:,9) + ide(:,10);

ZYYR = ide(:,12);
ZYYI = ide(:,13);
ZYY  = ide(:,12) + ide(:,13);
%ZYY=sqrt(ZYYR.^2+ZYYI.^2); 

if (f(1) > 0) % Add DC term
    f = [0;f];
    ZXX = [0;ZXX];
    ZXY = [0;ZXY];
    ZYY = [0;ZYY];
    ZYX = [0;ZYX];
end

Z{1,1} = ZXX;
Z{1,2} = ZXY;
Z{2,1} = ZYX;
Z{2,2} = ZYY;   