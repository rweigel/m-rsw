

dateo = '20060403';
datef = '20060418';
IbE = [882227:882233,1323746:1324585,1402202:1403151];
IbB = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts = main_options(1);
prepdirs(dateo,opts.filestr);

regen = 1;
site = 'mmb';
remote = 'kak';

if strcmp(site,'mmb')
    [tE,E,tB,B] = prep_EB(dateo,datef,'mmb',regen);
    [tEr,Er,tBr,Br] = prep_EB(dateo,datef,'kak',regen);
else
    [tE,E,tB,B] = prep_EB(dateo,datef,'kak',regen);
    %[tEr,Er,tBr,Br] = prep_EB(dateo,datef,'mmb',regen);
end

if ~isempty(IbB)
    B(IbB,:) = NaN;
    Ig = setdiff([1:size(B,1)],IbB);
    for i = 1:size(B,2)
        B(:,i) = interp1(tB(Ig),B(Ig,i),tB);
    end
end

if ~isempty(IbE)
    E(IbE,:) = NaN;
    Ig = setdiff([1:size(E,1)],IbE);
    for i = 1:size(E,2)
        E(:,i) = interp1(tE(Ig),E(Ig,i),tE);
    end
end

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
    loglog(1./fe(2:end),SE(2:end,1),'r');
    hold on;grid on
    loglog(1./fe(2:end),SEr(2:end,1),'r--');
    loglog(1./fe(2:end),SE(2:end,2),'b');
    loglog(1./fe(2:end),SEr(2:end,2),'b--');
    %loglog(1./fe(2:end),10*SB(2:end,1),'g');
    %loglog(1./fe(2:end),10*SBr(2:end,1),'g--');
    loglog(1./fe(2:end),abs(SE(2:end,1)-SEr(2:end,1))./SE(2:end,1),'b','LineWidth',2);
    loglog(1./fe(2:end),abs(SE(2:end,2)-SEr(2:end,2))./SE(2:end,2),'r','LineWidth',2);
    %loglog(1./fe(2:end),abs(SBr(2:end,1)-SB(2:end,1))./SB(2:end,1),'r','LineWidth',2);
    legend('Ex MMB','Ex KAK','Ey KAK','Ey KAK','(Ex MMB-Ex KAK)/(Ex MMB)','(Ey MMB-Ey KAK)/(Ey MMB)','Location','Best');
    

cc(E,Er)
ao = 1;
bo = -1;
f = 0.2;
Gs(:,1) = ao*((1-f)*E(:,1) + f*Er(:,1)) + bo*((1-f)*E(:,2) + f*Er(:,2));
Gs(:,2) = ao*((1-f)*E(:,1) + f*Er(:,1)) + bo*((1-f)*E(:,2) + f*Er(:,2));

GsE = transferfnFD(E,Gs,opts);
GsE_avg = transferfnAverage(GsE,opts);

figure(2);clf;
    loglog(1./GsE_avg.Mean.fe(2:end),abs(GsE_avg.Mean.Z(2:end,1)),'b');
    hold on;grid on;
    loglog(1./GsE_avg.Mean.fe(2:end),abs(GsE_avg.Mean.Z(2:end,2)),'r');
    legend('a','b','Location','Best');
    grid on;set(gca,'YLim',[0.5,10])
