force_slow = 1;

A         = ones(10,2);
A(1:4:10) = 99;
A(:,2)    = 2;

A
fprintf('[B,Ng] = mean_nonflag(A,2,99,1,force_slow)\n');fflush(stdout);
[B,Ng] = mean_nonflag(A,2,99,1,force_slow);
fprintf('[B,Ng] = \n');fflush(stdout);
[B,Ng]
input('Continue?');

A
fprintf('[B,Ng] = mean_nonflag(A,2,99,force_slow);\n');fflush(stdout);
[B,Ng] = mean_nonflag(A,1,99,force_slow);
fprintf('[B,Ng] = \n');fflush(stdout);
[B,Ng]

