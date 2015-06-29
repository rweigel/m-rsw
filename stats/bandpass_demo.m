
if (0)
T  = 16;
w  = 2*pi/T;
t  = [0:100*T-2];
x  = sin(w*t);% + sin(2*w*t);
Tkeep = 16.0;
Tkeep = [15.9,16.1];

[x_bp,aib_bp,aib] = bandpass(x,Tkeep);
figure(1);clf
subplot(2,1,1)
 plot(x,'b','LineWidth',2);hold on;
 plot(x_bp,'r');
 plot(x_bp-x,'k');
 legend('Original','Bandpassed','Difference');
subplot(2,1,2)
 plot(aib.*conj(aib),'b','LineWidth',2);hold on;
 plot(aib_bp.*conj(aib_bp),'r')
 plot(aib_bp.*conj(aib_bp)-aib.*conj(aib),'r')
 legend('Original','Bandpassed','Difference');
end 


