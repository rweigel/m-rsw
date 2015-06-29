N = 1000;
u = randn(N,1);
b = [0,1,1];
a = [1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Method 2
for i = 1:10
    z = filter(b,a,u)+i-1;

    % z = U*b
    U = [u(3:end),u(2:end-1),u(1:end-2)];
    b = U\z(3:end)
end
