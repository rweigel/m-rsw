

clf;
i = 3;
figure(1);clf
title('z_x');
semilogx(T,real(V{1}.NoStack_OLS.Z(2:end,i)),'k');hold on;grid on;
semilogy(T,real(V{1}.Mean.Z(2:end,i)),'r','LineWidth',2);
semilogx(T,imag(V{1}.NoStack_OLS.Z(2:end,i)),'k--');
semilogx(T,imag(V{1}.Mean.Z(2:end,i)),'r--','LineWidth',2);
semilogx(T,abs(V{1}.NoStack_OLS.Z(2:end,i)),'k','LineWidth',3);
semilogx(T,abs(V{1}.Mean.Z(2:end,i)),'r','LineWidth',3);

legend('Real No Stack OLS','Real Stack OLS','Imag No Stack OLS','Imag Stack OLS','Mag. No Stack OLS','Mag. Stack OLS');

figure(2);clf;
title('z_x');
semilogx(T,abs(V{1}.Mean.SN(2:end,2)),'r','LineWidth',2);hold on;grid on;
semilogx(T,abs(V{1}.NoStack_OLS.SN(2:end,2)),'k','LineWidth',2);
legend('SN No Stack','SN Stack');