% BASIC_LINEAR approach is faster for small N
% ARX takes less memory for large N (? Need to verify)
% Both give similar answers

load basic_linear_demo_arxcompare.mat

t = [0:0.1:10]';
%h = exp(-t);
N = 1e3;
u = randn(N,1);
y = filter([0;h],1,u);

y  = y(length(h)+1:end);
u  = u(length(h)+1:end);

Na = 10;
Nc = length(h);
Ts = 0;

tic
[T,X] = time_delay(y,u,Nc,Ts,Na,'pad');
LIN = basic_linear(X,T);
hbl = LIN.Weights(1:end-1);
toc

tic
Tc = [1:Nc];
%Tc = [1:Nc-2,Nc];
%Tc = [1:40,41:5:Nc];
Tc = [1:12,13:5:Nc];
%Tc = [1:12];
Ta = [1:Na];
[T,X] = time_delayT(y,u,Tc,Ts,Ta,'pad');
LIN = basic_linear(X,T);
hblT = LIN.Weights(1:end-1);
toc

clf;
plot([0:Nc],[0;h],'r','linewidth',4);hold on;
plot([-Na:Nc],[0;hbl],'g');hold on;
plot([-fliplr(Ta),0,Tc],[0;hblT],'b');hold on;
plot([-fliplr(Ta),0,Tc],[0;hblT],'.');hold on;
