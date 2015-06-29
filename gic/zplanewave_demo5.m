clear;
clear global;
global Z;
global f;
global fmax;
global hmem;

load /home/weigel/SWA/code/dominion/SolarNow/hmem.mat

fmax = 0.5/5;

Nl = 5;
s = 1;
h = [];

hmem = -1e3*hmem;
hmem = [hmem];

tmem = 5*[1:length(hmem)];
N = length(hmem);
f = ([1:N/2]/N)/5;
Z = fft(hmem);
Z = transpose(Z(2:N/2+1));

C = zplanewave(s,h,f);
Zm = abs(Z);
Cm = abs(C);

pZ = (180/pi)*atan2(imag(Z),real(Z));
pC = (180/pi)*atan2(imag(C),real(C));


tf = 5*[0:N-1]';
global hmem;
global tf;

tau = [100,100,100];
a   = [hmem(1),hmem(1),hmem(1)];

x  = fminsearch('errfn2',[tau,a]);
[err,hf] = errfn2(x);

Zf   = fft(hf);
Zf   = Zf(2:N/2+1);
Zfm  = abs(Zf);
pZf  = (180/pi)*atan2(imag(Zf),real(Zf));

figure(1);clf;
    loglog(f,Zm,'.');
    hold on;grid on;
    loglog(f,Zfm,'m.');
figure(2);clf
    plot(f,pZ,'.');hold on;
    plot(f,pZf,'m.');
    hold on;grid on;
figure(3);clf
    plot(tmem,hmem,'.');
    hold on;grid on;
    plot(tf,hf,'m.');

    
for k = 1:Nl
    x  = [s,h];
    x  = fminsearch('errfn',x);
    err = errfn(x);
    if (k > 1)
        s = x(1:(length(x)+1)/2);
        s(end+1) = s(end);
        h = x((length(x)+1)/2+1:end);
        h(end+1) = h(end);
    else
        s(end+1) = x(1);
        h(1) = 1e3;
    end
end

    
if (length(x) == 1)
    s = x;
    h = [];
else
    s = x(1:(length(x)+1)/2);
    h = x((length(x)+1)/2+1:end);
end

C = zplanewave(s,h,f);
Zm = abs(Z);
Cm = abs(C);
pC = (180/pi)*atan2(imag(C),real(C));

%hm = fftshift(ifft([0,C,fliplr(conj(C))]));
%tm = 5*[-N/2:N/2];

hm = ifft([0,C,fliplr(conj(C))]);
tm = 5*[1:N+1];

err2 = mse(hmem,hm(1:end-1)');

ho = 1e4./[1:5:length(hm)];

fprintf('Nl = %d\tE1 = %.2f E2 = %.2f\n',Nl,err,err2);

figure(1);
    loglog(f,Cm,'k-');
    legend('Data','Fit','Optimized');
figure(2);
    plot(f,pC,'k-');
    legend('Data','Fit','Optimized');
figure(3);
    plot(tm,hm,'k-')
    %plot(ho,'g','LineWidth',3);
    legend('Data','Fit','Optimized');
