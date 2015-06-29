%DIFF_NONFLAG_DEMO Demo of DIFF_NONFLAG.

FLAG = 99999;
A    = [1:10]';
A(1) = FLAG;
A(4) = FLAG;
A(8) = FLAG;
DIM  = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dA = diff_nonflag(A,DIM,FLAG);
fprintf('\n\n');
fprintf('dA = diff_nonflag(A,%d,%d)\n',DIM,FLAG);
fprintf(' A     dA\n_____________\n');
fprintf('%5d %5d\n',[A dA]');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A  = reflag(A,FLAG,NaN);
dA = diff_nonflag(A);
fprintf('\n\n');
fprintf('dA = diff_nonflag(A)\n');
fprintf(' A     dA\n_____________\n');
dA = diff_nonflag(A');
fprintf('%5d %5d\n',[A' dA]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

