%% Convolution_demo.m
% Script to demonstrate convolution in the time domain being the equivalent
% of multiplication in the frequency domain
%
% Pierre Cilliers, SANSA Space Science, 2017-08-11
close all
clear all
clc

%% Generate random number time series
N=1000;
t=1:N;
dt=1;
x=randn(1,N);
figure(1)
subplot(3,1,1);
plot(t,x);
xlabel('Time [s]');
ylabel('x(t)');
title('Input time series');
v=axis;

%% Apply LPF using discrete equation x(t+1)=x(t)- x(t)*dt/tau + dt*n(t)
tau=10; % time constant of LPF
f=0.1*randn(1,N);
y1=zeros(1,N);
y1(1)=0;
for ip=1:N-1
   y1(ip+1)=y1(ip)-y1(ip)*dt/tau+dt*f(ip);
end
figure(1)
subplot(3,1,2);
plot(t,y1);
xlabel('Time [s]');
ylabel('y(t)=LPF{x(t)}');
title('Filtered time series');
axis(v);

%% Impulse response h(t) of filter
%h=x;
h(1) = 0;
f1=zeros(1,N);
f1(1)=1;
for ip=1:N-1
   h(ip+1)=h(ip)-h(ip)*dt/tau + dt*f1(ip);
end
figure(1);
subplot(3,1,3);
plot(t,h,'LineWidth',2);
xlim([1 5*tau]);
xlabel('Time [s]');
ylabel('h(t)');
title('Impulse response of filter');

h2 = ifft(fft(y1)./fft(f));
hold on;
plot(h2);
legend('Used','Recovered');
