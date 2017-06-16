t = [0:9999];

p = sin(2*pi*t/10);

% Actual is prediction + noise
a0 = p + randn(1,10000);

a1 = p + randn(1,10000) + sin(2*pi*t/5) + randn(1,10000);

a2 = p + randn(1,10000) + 2*sin(2*pi*t/5) + 0*randn(1,10000);

pe0 = pe(a0,p);
cc0 = corrcoef(a0,p);
pe1 = pe(a1,p);
cc1 = corrcoef(a1,p);
pe2 = pe(a2,p);
cc2 = corrcoef(a2,p);

fprintf('a0: pe = %.2f cc = %.2f\n',pe0,cc0(2));
fprintf('a1: pe = %.2f cc = %.2f\n',pe1,cc1(2));
fprintf('a2: pe = %.2f cc = %.2f\n',pe2,cc2(2));


