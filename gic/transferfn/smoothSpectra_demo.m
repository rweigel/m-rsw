N = 1024;
window = ones(N/4,1);
noverlap = 0;

err = sin(8*2*pi*[0:N-1]'/N);

[Perr,ferr] = pwelch(err,window,noverlap);
[Perr2,ferr2] = smoothSpectra(err,'parzen');
[Perr3,ferr3] = pmtm(err);
[Perr4,ferr4] = periodogram(err);
Perr5 = fft(err).*conj(fft(err))/(2*length(err));
Perr5 = Perr5(1:length(err)/2+1);
ferr5 = [0:length(err)/2]/length(err);

figure();
clf;
loglog(2*pi./ferr(2:end),Perr(2:end),'LineWidth',2);
hold on;
loglog(1./ferr2(2:end),Perr2(2:end)/sf/(2*pi),'LineWidth',2);
loglog(2*pi./ferr3(2:end),Perr3(2:end),'LineWidth',2);
loglog(2*pi./ferr4(2:end),Perr4(2:end),'LineWidth',2);
loglog(1./ferr5(2:end),Perr5(2:end),'LineWidth',2);
grid on;
[lh,lo] = legend('pwelch','smoothSpectra','pmtm','periodogram','fft','Location','Best');
set(lo,'LineWidth',2);
