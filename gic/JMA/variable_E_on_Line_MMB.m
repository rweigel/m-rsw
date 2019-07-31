clear;

regen = 0;
site1 = 'mmb';
site2 = 'kak';

dateo = '20060403';
datef = '20060418';
IbE1 = [882227:882233,1323746:1324585,1402202:1403151];

[tE1,E1,tB1,B1] = prep_EB(dateo,datef,site1,regen);
[tE2,E2,tB2,B2] = prep_EB(dateo,datef,site2,regen);

if ~isempty(IbE1)
    E1(IbE1,:) = NaN;
    Ig = setdiff([1:size(E1,1)],IbE1);
    for i = 1:size(E1,2)
        E1(:,i) = interp1(tE1(Ig),E1(Ig,i),tE1);
    end
end

I = [86400*7+1:86400*9];

E1 = E1(I,:);
E2 = E2(I,:);

E1(:,1) = -E1(:,1);
E2(:,2) = 0.1*E2(:,2);

tE1 = tE1(I);
tE2 = tE2(I);

[SE1,fe] = smoothSpectra(E1);
[SE2,fe] = smoothSpectra(E2);

figure(1);clf;hold on;grid on;
    subplot(2,1,1)
        plot(tE1,E1(:,1));
        hold on;
        plot(tE2,E2(:,1));
        legend(site1,site2);
        ylabel('$E_x$');
        datetick('x')
    subplot(2,1,2)
        plot(tE1,E1(:,2));
        hold on;
        plot(tE2,E2(:,2));
        legend(site1,site2);
        ylabel('$E_y$');
        datetick('x')

figure(2);clf;
    loglog(1./fe(2:end),SE1(2:end,1),'r');
    hold on;grid on
    loglog(1./fe(2:end),SE2(2:end,1),'r--');
    loglog(1./fe(2:end),SE1(2:end,2),'b');
    loglog(1./fe(2:end),SE2(2:end,2),'b--');
    loglog(1./fe(2:end),abs(SE2(2:end,1)-SE1(2:end,1))./SE1(2:end,1),'r','LineWidth',2);
    loglog(1./fe(2:end),abs(SE2(2:end,2)-SE1(2:end,2))./SE1(2:end,2),'b','LineWidth',2);
    legend('Ex MMB','Ex KAK','Ey KAK','Ey KAK','(Ex MMB-Ex KAK)/(Ex MMB)','(Ey MMB-Ey KAK)/(Ey MMB)','Location','Best');


%[SEr,fe] = smoothSpectra(r);

cc(E1,E2)
ao = 1;
bo = -1;
f = 0.2;
dim = 1;

opts = main_options(1);
if dim == 1
    c = 2;
    Gs(:,1) = ao*((1-f)*E1(:,c) + f*E2(:,c));

    GsE1o = transferfnConst(E1(:,c),Gs,opts);
    GsE2o = transferfnConst(E2(:,c),Gs,opts);
    fprintf('ao1 (comp %d) = %.2f\n',c,mean(GsE1o.ao(1,1,:)));
    fprintf('ao2 (comp %d) = %.2f\n',c,mean(GsE2o.ao(1,1,:)));
    GsE1 = transferfnFD(E1(:,c),Gs,opts);
    GsE2 = transferfnFD(E2(:,c),Gs,opts);
    GsE1_avg = transferfnAverage(GsE1,opts);
    GsE2_avg = transferfnAverage(GsE2,opts);
    figure(3);clf;
        semilogx(1./GsE1_avg.Mean.fe(2:end),abs(GsE1_avg.Mean.Z(2:end,1)),'b','LineWidth',2);
        hold on;grid on;
        semilogx(1./GsE2_avg.Mean.fe(2:end),abs(GsE2_avg.Mean.Z(2:end,1)),'b');
        legend(sprintf('a - E1 input (comp %d)',c),...
               sprintf('a - E2 input (comp %d)',c),'Location','Best');

    figure(4);clf;
        R = fft(E1(:,c)-E2(:,c));
        R = R./fft(E2(:,c));
        R = 1./(1+R);
        N = size(E1,1);
        f = [0:N/2-1]'/N; % Assumes N is even.
        [fe,Ne,Ic] = evalfreq(f);
        N = conj(fft(E1(:,c))).*fft(Gs);
        D = conj(fft(E1(:,c))).*fft(E1(:,c)) + conj(fft(E1(:,c))).*fft(E1(:,c)-E2(:,c));
        for j = 2:length(Ic)
            W = rectwin(2*Ne(j)+1);
            W = W/sum(W);
            r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];
            aw(j) = sum(W.*N(r))./sum(W.*D(r));
            Rs(j) = sum(W.*R(r));
        end
        loglog(1./f(2:end),abs(R(2:end/2)))
        hold on;grid on;
        loglog(1./fe(2:end),abs(Rs(2:end)))
        loglog(1./fe(2:end),abs(aw(2:end)),'m')

    figure(5);clf;
        [SE1,fe] = smoothSpectra(E1(:,c));
        [SdE,fe] = smoothSpectra(E1(:,c)-E2(:,c));
        loglog(1./fe(2:end),SE1(2:end),'k','LineWidth',2);hold on;grid on;
        loglog(1./fe(2:end),SdE(2:end),'b','LineWidth',2);
        loglog(1./fe(2:end),SdE(2:end)./SE1(2:end),'g','LineWidth',2);
        legend('E1','E1-E2','(E1-E2)/E1');
end

if dim == 2
    Gs(:,1) = ao*((1-f)*E1(:,1) + f*E2(:,1)) + bo*((1-f)*E1(:,2) + f*E2(:,2));
    Gs(:,2) = ao*((1-f)*E1(:,1) + f*E2(:,1)) + bo*((1-f)*E1(:,2) + f*E2(:,2));

    GsE1o = transferfnConst(E1,Gs,opts);
    GsE2o = transferfnConst(E2,Gs,opts);
    fprintf('ao1 = %.2f, bo1 = %.2f\n',mean(GsE1o.ao(1,1,:)),mean(GsE1o.bo(1,1,:)));
    fprintf('ao2 = %.2f, bo2 = %.2f\n',mean(GsE2o.ao(1,1,:)),mean(GsE2o.bo(1,1,:)));
    GsE1 = transferfnFD(E1,Gs,opts);
    GsE2 = transferfnFD(E2,Gs,opts);
    GsE1_avg = transferfnAverage(GsE1,opts);
    GsE2_avg = transferfnAverage(GsE2,opts);
    figure(3);clf;
        semilogx(1./GsE1_avg.Mean.fe(2:end),abs(GsE1_avg.Mean.Z(2:end,1)),'b','LineWidth',2);
        hold on;grid on;
        semilogx(1./GsE1_avg.Mean.fe(2:end),abs(GsE1_avg.Mean.Z(2:end,2)),'r','LineWidth',2);
        semilogx(1./GsE2_avg.Mean.fe(2:end),abs(GsE2_avg.Mean.Z(2:end,1)),'b');
        semilogx(1./GsE2_avg.Mean.fe(2:end),abs(GsE2_avg.Mean.Z(2:end,2)),'r');
        legend('a - E1 input','b E1 input','a - E2 input','b - E2 input','Location','Best');
end


