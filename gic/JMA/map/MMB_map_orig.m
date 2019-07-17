%% MMB_map.m
% Script to plot the power line from Ashoro. to MMB on Hokkaido Island, Japan
% 
% Pierre Cilliers, SANSA Space Science, 2019-07-16
%
% Notes:
%   1. kml to Excel: The coordinates of the line were obtained using the "path" tool in
%   Google Earth. The path was saved as a *.kml file
%   The conversion from Google Earth’s kml to Excel format was done with the
%   free online software available at http://www.convertcsv.com/kml-to-csv.htm
% 
%   2. m_map: The m_map software package for plotting the map is a free package 
%   which can be retrieved from https://www.eoas.ubc.ca/~rich/map.html
% 
%   3.Geomagnetic coordinates: The APEX corrected geomagnetic COORDINATE CONVERSION UTILITY 
%   and various versions of the software can be downloaded from https://www.ngdc.noaa.gov/geomag/geom_util/apex.shtml
%
%   4. Power line coordinates: the two Excel files with the coordinates of the 187 kV line, should be in the location identified by data_path, 
%      and it should be the only Excel files in that directory.

clc
clear
close all

%% Inputs
Root='c:\Users\pjcilliers\Documents\';
script_path=[Root,'Research\Papers in progress\2019\Weigel\Software\'];
data_path=[Root,'Research\Papers in progress\2019\Weigel\'];
m_map_path=[Root,'Research\Mapping\M_map\'];
mlat_path=[Root,'Research\Geomagnetics\APEX\'];

projection='Mercator'; 
mlat_file='Apex_geomagnetic_isolines_5deg_spacing.txt';
set(0,'DefaultAxesFontSize',14);

addpath(script_path);
addpath(m_map_path);
cd(data_path);

%% Find the Excel files with the coordinates of the 187 kV power line
fn=dir('*.xlsx');
[num,txt,raw] = xlsread(fn(1).name);
cc1=cell2mat(raw);
[num,txt,raw] = xlsread(fn(2).name);
cc2=cell2mat(raw);
fs1=strfind(cc1,',');
fs2=strfind(cc2,',');

%% Extract coordinates
lons=[];
lats=[];
% first point of first set of points
lons=str2double(cc1(1:fs1(1)-1));
lats=str2double(cc1(fs1(1)+1:fs1(2)-1));
% read the rest of the points
for ip=2:2:numel(fs1)-2
    lon=str2double(cc1(fs1(ip)+3:fs1(ip+1)-1));
    lons=[lons;lon];
    lat=str2double(cc1(fs1(ip+1)+1:fs1(ip+2)-1));
    lats=[lats;lat];
end
% first point of seconds set of points
lon=str2double(cc1(1:fs2(1)-1));
lat=str2double(cc1(fs2(1)+1:fs2(2)-1));
lons=[lons;lon];
lats=[lats;lat];
% read the rest of the points
for ip=2:2:numel(fs2)-2
    lon=str2double(cc2(fs2(ip)+3:fs2(ip+1)-1));
    lons=[lons;lon];
    lat=str2double(cc2(fs2(ip+1)+1:fs2(ip+2)-1));
    lats=[lats;lat];
end

% sort the points in order of increasing latitude
[lats,bi]=sortrows(lats);
lons=lons(bi);

% extract the unique values of the line coordinates
[lats,ia,ib]=unique(lats);
lons=lons(ia);

%% Draw map
% map centre
mean_lon=144.21;
mean_lat=43.62;

lon_min=138;
lon_max=146;
lat_min=41;
lat_max=47;

%% Select the projection
switch projection
    case 'Satellite'
        m_proj('Satellite','lon',mean_lon,'lat',mean_lat);
    case 'Mercator'
        m_proj('Mercator','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
    case 'Sinusoidal'
        m_proj('Sinusoidal','lon',[lon_min lon_max],'lat',[lat_min lat_max]);          
    case 'albers equal-area'
        m_proj('albers equal-area','lat',[lat_min lat_max],'lon',[lon_min lon_max]);
    case 'lambert'
        m_proj('lambert','long',[lon_min lon_max],'lat',[lat_min lat_max]);
    case 'miller'
        m_proj('miller','lon',mean_lon,'lat',mean_lat);
    case 'none'
        % Do not call m_proj
        load('worldcoast.mat');
end

m_coast('line','Color','b','LineWidth',1);  % Draw the coastline in blue
m_coast('patch',[0.8 .8 .8]);                % Fill the continents with selected colours
m_grid('box','on','xtick',138:146,'ylick',41:47,'linestyle','--');
hold on
xlabel('Longitude [^o]');
ylabel('Latitude [^o]');


%% Plot the name of the island
m_text(141.5,43.5,'HOKKAIDO','FontSize',16);

%% Plot substations
Memanbetsu.Lon=144.217082;
Memanbetsu.Lat=43.832029;
Memanbetsu.name=sprintf('Memanbetsu \nsubstation');

Ashoro.Lon=143.546246; 
Ashoro.Lat=43.226309;
Ashoro.name=sprintf('Ashoro \npower station');

m_plot(Memanbetsu.Lon,Memanbetsu.Lat,'r^','LineWidth',2);
m_text(Memanbetsu.Lon+0.1,Memanbetsu.Lat-0.15,Memanbetsu.name,'FontSize',14);

m_plot(Ashoro.Lon,Ashoro.Lat,'r^','LineWidth',2);
m_text(Ashoro.Lon+0.1,Ashoro.Lat,Ashoro.name,'FontSize',14);

%% Plot MMB Magnetic Observatory
MMB.Lon=144.189;
MMB.Lat=43.910;
MMB_text=sprintf('Memanbetsu \nMagnetic \nObservatory');

m_plot(MMB.Lon,MMB.Lat,'ksq','LineWidth',2);
m_text(MMB.Lon-0.2,MMB.Lat+0.4,MMB_text,'FontSize',14,'HorizontalAlignment','center');

%% Plot the 187 kV power line from Ashoro power station to Memanbetsu substation
m_plot(lons,lats,'r','LineWidth',2);

%% Read & plot the geomagnetic latitudes
cd(mlat_path);
D=load(mlat_file);
glons=D(:,1);
mlats=-70:5:70;
% find mlat index range
mlat_ind=find(mlats>=35 & mlats<=45);
glon_ind=find(glons>=138 & glons<=146);
glon_p=glons(glon_ind);

% Extract and plot the lines of magnetic latitude that intersect the map
hold on
for ip=1:numel(mlat_ind)
    mlat_col=mlat_ind(ip)+1;
    glat_p=D(glon_ind,mlat_col);
    m_plot(glon_p,glat_p,'k--','Linewidth',2);
    mlat_txt_x=mean(glon_p);
    mlat_txt_y=mean(glat_p)-0.2;
    m_lat_txt=sprintf('mag. lat=%3.0f%s',mlats(mlat_col),char(176));
    m_text(mlat_txt_x,mlat_txt_y,m_lat_txt,'FontSize',14);
end

%% change the size of the map
set(gcf,'units','normalized');
set(gcf,'position',[0    0.0463    0.6000    0.8667]); 
    

