%% APEX_geo2mag.m
% Script to calculate the geoomagnetic latitude corresponding to given geodetic
% latitude and longitude by means of the APEX model
%
% Author: Pierre Cilliers
% Date: 2019-04-06
%
% Notes: The APEX corrected geomagnetic COORDINATE CONVERSION UTILITY and various versions of the software can be downloaded from 
%        https://www.ngdc.noaa.gov/geomag/geom_util/apex.shtml
%
% Usage:
%     apx_file_windows.exe f INPUTFILENAME.txt OUTPUTFILENAME.txt
%     for comparison with the geomagnetic equator derived from Swarm
%     magnetometer data, the following files must be in the data_path:
%         'Swarm_dip_equator.txt'
%         'MagEquator.mat'
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
%     The output is a text file with the name Apex_geomagnetic_isolines.txt with the following columns
%       Column 1: Geographic longitudes -180:1:180
%       Columns 2 to end: Geographic latitudes of the geomagnetic latitudes
%       given in the header of each column.

close all
clear all

%% Inputs
glon=-180:1:180;  % geographic longitude range
% glon=[-10 10];  % geographic longitude range
glat=-89:1:89;    % geographic latitude range (must exceed the magnetic latitude range)
% mlatq=0;  % magnetic latitude isolines for which the geographic coordinates are to be produced
mlatq=-70:5:75;   % magnetic latitude isolines for which the geographic coordinates are to be produced
epoch=2015;       % the APEX model is only valid up to 2015
mag_eq_date=2015; % Date of magnetic equator determined from Swarm magnetometer data. Options '2015', '2018'

% paths
script_path='c:\Users\pjcilliers\Documents\Research\Geomagnetics\APEX\';
apex_path='c:\Users\pjcilliers\Documents\Research\Geomagnetics\APEX\';
Swarm_path='C:\Users\pjcilliers\Documents\Research\Papers in progress\2018\Olwendo\Scripts';
Swarm_file_2015='Swarm_dip_equator.txt';
Swarm_file_2018='MagEquator.mat';

% flags
mlat_vs_glat_plot_flag=1; % plot the geomagnetic latitude vs. geographic latitude for a given geographic longitude (use only for debugging when only a few  geographic longitudes are considered)
save_isolines_flag=1;     % save the geographic coordinates of selected geomagnetic isolines
compare_Swarm_flag=1;     % Superimpose dip equator derived from Swarm data to compare with Apex model

%% Initialize
set(0,'DefaultAxesFontSize',16);
addpath(script_path);
cd(apex_path);
fprintf('[APEX_geo2mag] Determining the geographic coordinates of given geomagnetic latitudes in the range %i:%i:%i ...\n',...
    mlatq(1),mlatq(2)-mlatq(1),mlatq(end));

%% Create an input file for running the APEX Coordinate conversion utility
INPUTFILENAME='INPUT.txt';
OUTPUTFILENAME='OUTPUT.txt';
fid=fopen(INPUTFILENAME,'w');
for iplon=1:numel(glon)
    for iplat=1:numel(glat)
        fprintf(fid,'%6.1f  %6.1f  %6.1f\n',epoch,glat(iplat),glon(iplon));
    end
end
fclose(fid);

%% Compile and execute the system command
sys_cmd=sprintf('apx_file_windows.exe f INPUT.txt OUTPUT.txt');
tic
[status,cmdout]=system(sys_cmd);
if status==0
    fprintf('[APEX_geo2mag] Conversion OK \n');
    toc
else
    fprintf('[APEX_geo2mag] Conversion failed. Command output: \n');
    disp(cmdout);
    return
end

%% Read and plot the output
% read output
fid=fopen(OUTPUTFILENAME);
OUTPUT=textscan(fid,'%f %f %f %f %f','HeaderLines',1);
fclose(fid);

glatv=cell2mat(OUTPUT(:,2));
glonv=cell2mat(OUTPUT(:,3));
mlatv=cell2mat(OUTPUT(:,4));
% plot mlat vs. glat for a selected geographic longitude
if mlat_vs_glat_plot_flag
    figure
    % remove jumps in glat
    dlat=[NaN;diff(glatv(:))];
    fj=find(abs(dlat)>10);
    pglat=glatv;
    pmlat=mlatv;
    pglat(fj)=NaN;
    pmlat(fj)=NaN;
    plot(pglat,pmlat);
    xlabel('Geographic latitude [^o]');
    ylabel('Geomagnetic latitude [^o]');
    title_str=sprintf('Magnetic latitude vs. geographic latitude for epoch %i, geo lon = %5.1f%s',epoch(1),glon(1),char(176));
    title(title_str);
    grid on
    % set Figure size
    set(gcf,'units','normalized')
    set(gcf,'position',[0    0.0463    1.0000    0.8667]);
end

%% Find the geographic latitudes of chosen magnetic latitudes for all the specified longitudes
glatm=zeros(numel(glon),numel(mlatq));
for iplon=1:numel(glon)
    % find the indices of the geographic and geomagnetic latitudes corresponding to each longitude bin
    lon_ind=find(abs(glon(iplon)-glonv)<1);
    glats=glatv(lon_ind);
    mlats=mlatv(lon_ind);
    % select unique values of mlats for interpolation
    [mlats,ia,ic] = unique(mlats);
    glats=glats(ia);
    % interpolate the geographic latitudes to the selected set of magnetic latitudes (mlatq)
    glatm(iplon,:)=interp1(mlats,glats,mlatq);
%     disp([glon(iplon),glatm(iplon,:)]);
% mark the geographic coordinates of these points on the glat-mlat-curve
    if mlat_vs_glat_plot_flag
        hold on
        plot(glatv(1,:),mlatq,'r*');
        for iplat=1:numel(mlatq)
            text(glatv(iplat)+0.3,mlatq(iplat),sprintf('%5.2f%s',glatv(iplat),char(176)),'FontSize',16);
        end
    end
end

%% Plot the geomagnetic contours
figure
plot(glon,glatm,'LineWidth',2);
grid on 
hold on
xlim([min(glon) max(glon)]);
ylim([-88 88]);
xlabel('Geographic longitude [^o]');
ylabel('Geographic latitude [^o]');
title('Geographic location of geomagnetic contours');
for ip=1:numel(mlatq)
    mlati=mlatq(ip);
    label=sprintf('%i%s',mlati,char(176));
    label_x=min(glon)+1;
    label_y=glatm(1,ip);
    text(label_x,label_y,label,'FontSize',14);
end
% set Figure size
set(gcf,'units','normalized')
set(gcf,'position',[0    0.0463    1.0000    0.8667]);

%% Compare Apex with Swarm dip equator
if compare_Swarm_flag
    cd(Swarm_path);
    % load Swarm-derived magnetic equator
    switch mag_eq_date
        case 2015
            sd=load(Swarm_file_2015);
        case 2018
            load(Swarm_file_2018);
            sd(:,1)=MagEquator.lon;
            sd(:,2)=MagEquator.lat;
    end
    
    hold on
    plot(sd(:,1),sd(:,2),'k','Linewidth',2);
    legend('Apex -20^o','Apex 0^o','Apex +20^o','Swarm dip equator');
end

%% save the geographic coordinates of selected geomagnetic isolines
if save_isolines_flag
    save_file='Apex_geomagnetic_isolines.txt';
    cd(apex_path);
    fid=fopen(save_file,'w');
    fprintf(fid,'Geographic coordinates of geomagnetic geomagnetic latitudes vs. geographic longitude derived by means of the APEX algorithm described on https://www.ngdc.noaa.gov/geomag/geom_util/apex.shtml\n');
    fprintf(fid,'Lon          Geodetic latitudes \n');
    % Compile the headerline and format string of the output file
    mlat_header='        ';
    mlat_format='%6.2f    ';
    for ip=1:numel(mlatq)
        mlati=mlatq(ip);
        mlat_header=[mlat_header,sprintf(' %i(mag)',mlati)];
    end
    % print the header line
    fprintf(fid,[mlat_header,' \n']);
    Ng=numel(glon);
    Nm=size(glatm,2);
    for ip=1:Ng
        % write output values without an end-of-line character
        fprintf(fid,'%6.2f ',glon(ip));
        for im=1:Nm-1
            fprintf(fid,'   %5.2f',glatm(ip,im));
        end
        % write last entry per line and terminate with end-of-line character (\n)
        fprintf(fid,'  %5.2f \n',glatm(ip,Nm));
%         fprintf(fid,mlat_format,glon(ip), glatm(ip,1), glatm(ip,2), glatm(ip,3));
    end
    fclose(fid);
    fprintf('[APEX_geo2mag]Geographic coordinates of geomagnetic isolines written to %s \n',save_file);
end








