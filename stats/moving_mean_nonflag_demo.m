force_slow = 1;
N          = 3

FLAGv     = 99999;
x         = cumsum([1:12]');
x(10)     = FLAGv;
[temp,Ng] = moving_mean_nonflag(x,8,1,FLAGv,1);
temp
Ng

A          = ones(3,1);
A(1)       = 99999;
A(:,2)     = 2;

C = [99999 ; 10    ; 10 ;10];
D = [2    ; 99999 ; 99999 ;2];
C = [C , D];

C
fprintf('[B,Ng] = moving_mean_nonflag(C,N,1,99999,1,1);\n');fflush(stdout);
[B,Ng] = moving_mean_nonflag(C,N,1,99999,1,1);
B
Ng

input('Continue?');

C
N = 2;
fprintf('[B,Ng] = moving_mean_nonflag(C,N,2,99999,1,1);\n');fflush(stdout);
[B,Ng] = moving_mean_nonflag(C,N,2,99999,1,1);
B
Ng

input('Continue?');

C
fprintf('[B,Ng] = moving_mean_nonflag(C,N,1,99999,1);\n');fflush(stdout);
[B,Ng] = moving_mean_nonflag(C,N,1,99999,1);
B
Ng

input('Continue?');
echo on
C
[B,Ng] = moving_mean_nonflag(C,N,2,99999,1);
B
Ng

input('Continue?');

[B,Ng] = moving_mean_nonflag(A,N,1,99999,1,force_slow);
B
Ng

[B,Ng] = moving_mean_nonflag(A,N,1,99999,1);
B
Ng

input('Continue?');

A
[B,Ng] = moving_mean_nonflag(A,N,2,99999,1,force_slow);
B
Ng

[B,Ng] = moving_mean_nonflag(A,N,2,99999,1);
B
Ng
echo off

