%% MMB_ab_estiamte.m
% Script to estimate the "a" and "b" parameters of the GIC measured at MMB
% from the measured GIC and E-field, based on the following assumptions:
%  1. At every epoch the spatial variation of the E-field over the length
%  of the line is negligible.
%  2. The network is purely resistaive, so that the peak of the GIC occurs
%  at the same epoch as the peak of the E-field, when the E-field is
%  aligned with the direction of the power line.
%  3. The polarity of the Ey should be reversed 

% Pierre Cilliers, SANSA Space Science, 2019-07-23

close all
clear 
clc

%% Inputs
% Paths
Root='c:\Users\pjcilliers\Documents\Research\Papers in progress\2019\Weigel\';
script_path=[Root,'Data\MMB\'];
MT_path=[Root,'Data\MMB\'];
Processed_data_path='c:\Users\pjcilliers\Documents\Research\Papers in progress\2019\Weigel\Data\Processed data\';

% data_files
Processed_data_file='data/jma/mat/prepEB_mmb_20060805-20060808-despiked.mat';
Processed_data_file2='data-private/watari/mat/prepGIC_20060805-20060808-despiked.mat';

% flags
B_field_plot_flag=1;     % plot Bx and By vs. UT
E_field_plot_flag=1;     % Plot of ex=Ex-mean(Ex) and ey=Ey-mean(Ey) vs. UT
Estimate_a_and_b_flag=1; % Estimate the "a" and "b" parameters using the method of Matandirotya 2013
Check_GIC_peaks_vs_Efield_angle=1; % Check the angle of the E-field at which the GIC peaks occur

% MMB total field values for the period 20060805 to 20060808
Bx0=26129.9; % [nT]
By0=-4125.9; % [nT]
Bz0=41986.6; % [nT]    

% other parameters
mu0=4*pi*1e-7;
r2d=180/pi;

%% Initialize
addpath(script_path);
set(0,'DefaultAxesFontSize',16);
Station_code='MMB';
Lat=43.910;
Lon=144.189;

%% Read the processed MMB data
fprintf('[MMB2Lemi] Reading processed MMB data from %s ...\n',Processed_data_file);
%cd(Processed_data_path);
D=load(Processed_data_file);
D2=load(Processed_data_file2);
D.GIC = D2.GIC;
D.tGIC = D2.tGIC;


break

% find the start time of the GIC
GIC_start_dn=D.tGIC(1);
GIC_end_dn=D.tGIC(end);
b_ind=find(D.tB>=GIC_start_dn & D.tB<=GIC_end_dn);
tt=D.tB(b_ind);  % MATLAB datenumber
bx=D.B(:,1);     % [nT]
by=D.B(:,2);     % [nT]
bz=D.B(:,3);     % [nT]
ex=D.E(:,1);     % [mV/km]
ey=D.E(:,2);     % [mV/km]
GIC=D.GIC(:,2);  % cleaned GIC [A];

MT_site='MMB';

%% Estimate the "a" and "b" parameters using the method of Matandirotya et al. 2015
if Estimate_a_and_b_flag
   % find large GIC times with corresponding large Ex and Large Ey
   k_big=1;
   k_small=0.1;
   ey0=ey;
   % reverse the polarity of ey
   ey=-ey0;
   % reference values for big and small
   GIC_std=std(GIC);
   Ex_std=std(ex);
   Ey_std=std(ey);

   GIC_ind1=find(GIC>k_big*GIC_std);  % large positive GIC
   GIC_ind2=find(GIC<-k_big*GIC_std); % large negative GIC
   
   % indices related to finding "a"
   a_ind=find((ex>k_big*Ex_std & GIC>k_big*GIC_std & abs(ey)<k_small*Ey_std) | (ex<-k_big*Ex_std & GIC<-k_big*GIC_std & abs(ey)<k_small*Ey_std)); % case a>0
   if isempty(a_ind)
      a_ind=find((ex<-k_big*Ex_std & GIC>k_big*GIC_std & abs(ey)<k_small*Ey_std) | (ex>k_big*Ex_std & GIC<-k_big*GIC_std & abs(ey)<k_small*Ey_std)); % case a<0   Ex_small_ind=find(abs(ex)<k_small*Ex_std);
   end

 % indices related to finding "b"
   b_ind=find((ey>k_big*Ey_std & GIC>k_big*GIC_std & abs(ex)<k_small*Ex_std) | (ey<-k_big*Ey_std & GIC<-k_big*GIC_std & abs(ex)<k_small*Ex_std)); % case b>0
   if isempty(b_ind)
      b_ind=find((ey<-k_big*Ey_std & GIC>k_big*GIC_std & abs(ex)<k_small*Ex_std) | (ey>k_big*Ey_std & GIC<-k_big*GIC_std & abs(ex)<k_small*Ex_std)); % case b<0   Ex_small_ind=find(abs(ex)<k_small*Ex_std);
   end
         
   figure
   % Ex
   subplot(3,2,1);
   plot(tt,ex,'b-');
   datetick('x');
   hold on
   grid on
   plot(tt(a_ind),ex(a_ind),'r.');
   ylabel('Ex [mV/km]');
   Xlims=[min(tt) max(tt)];
   set(gca,'Xlim',Xlims);
   Xticks=get(gca,'Xtick');
   
   % GIC @ large Ex, small Ey
   subplot(3,2,3)
   plot(tt,GIC,'b-');
   datetick('x');
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);
   hold on
   grid on 
   plot(tt(a_ind),GIC(a_ind),'r.')
   ylabel('GIC');
   
   % a_estiamtes
   subplot(3,2,5)
   a_est=GIC(a_ind)./ex(a_ind);
   plot(tt(a_ind),a_est,'k.','MarkerSize',6);
   datetick('x');
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);
   grid on
   xlabel('Time [UT]');
   ylabel('a(est) [A/(mV/km)]');
   a_mean=mean(a_est);
   a_std=std(a_est);
      
   % Ey
   subplot(3,2,2);
   plot(tt,ey,'b-');
   datetick('x');
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);   
   hold on
   grid on
   plot(tt(b_ind),ey(b_ind),'r.');
   ylabel('Ey [mV/km]');
   
   % GIC @ large Ey, small Ex
   subplot(3,2,4)
   plot(tt,GIC,'b-');
   datetick('x');
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);   
   hold on
   grid on 
   plot(tt(b_ind),GIC(b_ind),'r.')
   ylabel('GIC');
   
   % b estimates
   subplot(3,2,6)
   b_est=GIC(b_ind)./ey(b_ind);
   plot(tt(b_ind),b_est,'k.','MarkerSize',6);
   datetick('x');
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);   
   grid on
   xlabel('Time [UT]');
   ylabel('b(est) [A/(mV/km)]');
   a_mean=mean(a_est);
   a_std=std(a_est);

   b_mean=mean(b_est);
   b_std=std(b_est);

   fprintf('a-estimate = %5.2f A/(mV/km), STD = %5.2f A/(mV/km) \n', a_mean,a_std);
   fprintf('b-estimate = %5.2f A/(mV/km), STD = %5.2f A/(mV/km) \n', b_mean,b_std);
   
    set(gcf,'units','normalized');
    set(gcf,'position',[0    0.0463    1.0000    0.8667]);

    % restore ey polarity to the measured value
    ey=ey0;
end

%% Check the angle of the E-field at which the GIC peaks occur
if Check_GIC_peaks_vs_Efield_angle
   % find large GIC times with corresponding large Ex and Large Ey
   k_big=1;
   k_small=0.1;
   ey0=ey;
   % reverse the polarity of ey
   ey=-ey0;
   % reference values for big GIC
   GIC_std=std(GIC);
   % E-field angle
   A=atan2d(ey,ex);
   % normalise the angle range to [-180 180]
   A(A>180)=A(A>180)-360;
   A(A<-180)=A(A<-180)+360;
   GIC_ind1=find(GIC>k_big*GIC_std);  % large positive GIC
   GIC_ind2=find(GIC<-k_big*GIC_std); % large negative GIC   
   
   figure
   % GIC with large values marked
   subplot(2,1,1)
   plot(tt,GIC,'b-');
   datetick('x');
   Xlims=[min(tt) max(tt)];
   set(gca,'Xlim',Xlims);
   Xticks=get(gca,'Xtick');
   ylabel('GIC [A]');
   grid on
   hold on
   plot(tt(GIC_ind1),GIC(GIC_ind1),'r.','Markersize',3);
   plot(tt(GIC_ind2),GIC(GIC_ind2),'g.','Markersize',3);
   
   % E-field angle with occasions of large GIC marked 
   subplot(2,1,2)
   plot(tt,A,'b-');
   datetick('x');
   Xlims=[min(tt) max(tt)];
   set(gca,'Xlim',Xlims);
   set(gca,'Xtick',Xticks);
   ylabel('angle(E) [deg]');
   xlabel('Time [UT]');
   grid on
   hold on
   plot(tt(GIC_ind1),A(GIC_ind1),'r.','Markersize',3);
   plot(tt(GIC_ind2),A(GIC_ind2),'g.','Markersize',3);
   
    set(gcf,'units','normalized');
    set(gcf,'position',[0    0.0463    1.0000    0.8667]);   
   
   % find mean angles for large GIC
   A1_mean=mean(A(GIC_ind1));
   A1_std=std(A(GIC_ind1));
   A2_mean=mean(A(GIC_ind2));
   A2_std=std(A(GIC_ind2));

   fprintf('E-field angle for large GIC>0: Mean = %5.2f deg, STD=%5.2f deg \n',A1_mean,A1_std);
   fprintf('E-field angle for large GIC<0: Mean = %5.2f deg, STD=%5.2f deg \n',A2_mean,A2_std);
end