function [mlat,mlon] = APEX_geo2magf(glon,glat,epoch)
%APEX_geo2magf Function to determined the geomagnetic coordinates of 
%              a location on the Earth during a given epoch
%  Inputs:
%   glon = geographic longitude vector [deg]
%   glat = geographic latitude vector [deg]
%   epoch = epoch for APEX model (2006-2015) - for dates outside this range
%          the nearest extreme is used.
%  outputs:
%   mlon = geomagnetic longitude vector [deg]
%   mlat = geomagnetic latitude vector [deg]
%
% Author: Pierre Cilliers
% Date: 2019-04-06
%
% Notes: The APEX corrected geomagnetic COORDINATE CONVERSION UTILITY and various versions of the software can be downloaded from 
%        https://www.ngdc.noaa.gov/geomag/geom_util/apex.shtml
%
% Usage:
%     apx_file_windows.exe f INPUTFILENAME.txt OUTPUTFILENAME.txt
%     
% Input file format for the apx_file_windows.exe
%     The input file may have any number of entries but they must follow
%     the following format
%     Date and location Formats: 
%        Date: xxxx.xxx for decimal  (2013.7)
%        Lat/Lon: xxx.xxx in decimal  (-76.53)
%                 (Lat and Lon must be specified in the same format.)
%        Date must fit model.
%        Lat: -90 to 90 (Use - to denote Southern latitude.)
%        Lon: -180 to 180 (Use - to denote Western longitude.)
%        Date: 1990.0 to 2015.0
%        An example of an entry in input file
%        1997.0 30.3  30.8
%
% Output:
%      mlat = geomagnetic longitude vector [deg]
%      mlon = geomagnetic longitude vector [deg]

    apex_path='c:\Users\pjcilliers\Documents\Research\Geomagnetics\APEX\';
    cd(apex_path);

    % check the input size
    N=numel(glat);
    
    % adjust the epoch
    if epoch > 2015
        epoch=2015;
    elseif epoch < 1990
        epoch=1990;
    end
    
    %% Create an input file for running the APEX Coordinate conversion utility
    INPUTFILENAME='INPUT.txt';
    OUTPUTFILENAME='OUTPUT.txt';
    fid=fopen(INPUTFILENAME,'w');
    for ip=1:N
        fprintf(fid,'%6.1f  %6.1f  %6.1f\n',epoch,glat(ip),glon(ip));
    end
    fclose(fid);

    %% Compile and execute the system command
    sys_cmd=sprintf('apx_file_windows.exe f INPUT.txt OUTPUT.txt');
    [status,cmdout]=system(sys_cmd);
    if status==0
        fprintf('[APEX_geo2mag] Conversion OK \n');
    else
        fprintf('[APEX_geo2mag] Conversion failed. Command output: \n');
        disp(cmdout);
        return
    end

    %% Read the output
    % read output
    fid=fopen(OUTPUTFILENAME);
    OUTPUT=textscan(fid,'%f %f %f %f %f','HeaderLines',1);
    fclose(fid);

    glatv=cell2mat(OUTPUT(:,2));
    glonv=cell2mat(OUTPUT(:,3));
    mlat=cell2mat(OUTPUT(:,4));
    mlon=cell2mat(OUTPUT(:,5));
end