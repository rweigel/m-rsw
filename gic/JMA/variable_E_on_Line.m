
if 0
[~,Et,Bt] = computeTrend([],E,B,site,{dateo},{datef});
[~,Ert,Brt] = computeTrend([],Er,Br,site,{dateo},{datef});

E = removeTrend(E,Et);
Er = removeTrend(Er,Ert);
B = removeTrend(B,Bt);
Br = removeTrend(Br,Brt);

[SE,fe] = smoothSpectra(E);
[SEr,fe] = smoothSpectra(Er);
[SB,fe] = smoothSpectra(B);
[SBr,fe] = smoothSpectra(Br);

    figure(1);clf;
    loglog(1./fe(2:end),SE(2:end,1));
        hold on;
        loglog(1./fe(2:end),SEr(2:end,1));
        loglog(1./fe(2:end),10*SB(2:end,1));
        loglog(1./fe(2:end),10*SBr(2:end,1));
        loglog(1./fe(2:end),abs(SEr(2:end,1)-SE(2:end,1))/SE(2:end,1),'k','LineWidth',2);
        loglog(1./fe(2:end),abs(SBr(2:end,1)-SB(2:end,1))/SB(2:end,1),'b','LineWidth',2);
        legend('Ex MMB','Ex KAK','Bx MMB','Bx KAK','Ex MMB/Ex KAK','Bx MMB/By MMB');
        grid on

    cc(E,Er)
    ao = 1;
    bo = 1;
    f = 0.2;
    Gs(:,1) = ao*(E(:,1)+f*Er(:,1)) + bo*(E(:,2)+f*Er(:,2));
    Gs(:,2) = ao*(E(:,1)+f*Er(:,1)) + bo*(E(:,2)+f*Er(:,2));

    GsE = transferfnFD(E,Gs,opts);
    GsE_avg = transferfnAverage(GsE,opts);
    figure(1)
        loglog(1./GsE_avg.Mean.fe(2:end),abs(GsE_avg.Mean.Z(2:end,1:2)));
        legend('a','b');grid on;set(gca,'YLim',[0.5,10])
end