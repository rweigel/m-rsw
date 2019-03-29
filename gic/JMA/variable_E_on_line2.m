clear
D1 = load('../data/iris/NEK28/data/NEK28-counts-cleaned.mat');
D2 = load('../data/iris/NEK27/data/NEK27-counts-cleaned.mat');
D2 = load('../data/iris/NEK25/data/NEK25-counts-cleaned.mat');
D2 = load('../data/iris/NEK29/data/NEK29-counts-cleaned.mat');

sta1 = 'VAQ58';
sta2 = 'VAQ59';
D1 = load(['../data/iris/',sta1,'/data/',sta1,'-counts-original.mat']);
D2 = load(['../data/iris/',sta2,'/data/',sta2,'-counts-original.mat']);

sta1 = 'NEK28';
sta2 = 'NEK29';
D1 = load(['../data/iris/',sta1,'/data/',sta1,'-counts-cleaned.mat']);
D2 = load(['../data/iris/',sta2,'/data/',sta2,'-counts-cleaned.mat']);


t1dn = datenum(D1.start) + [0:size(D1.D,1)-1]'/86400;
t2dn = datenum(D2.start) + [0:size(D2.D,1)-1]'/86400;

figure(1);clf;hold on;grid on;
    subplot(4,1,1)
        plot(t1dn,D1.D(:,1));
        hold on;
        plot(t2dn,D2.D(:,1));
        legend(sta1,sta2);
        ylabel('$B_x$');
        datetick('x')
    subplot(4,1,2)
        plot(t1dn,D1.D(:,2));
        hold on;
        plot(t2dn,D2.D(:,2));
        legend(sta1,sta2);
        ylabel('$B_y$');
        datetick('x')
    subplot(4,1,3)
        plot(t1dn,D1.D(:,4));
        hold on;
        plot(t2dn,D2.D(:,4));
        legend(sta1,sta2);
        ylabel('$E_x$');
        datetick('x')
    subplot(4,1,4)
        plot(t1dn,D1.D(:,5));
        hold on;
        plot(t2dn,D2.D(:,5));
        legend(sta1,sta2);
        ylabel('$E_y$');
        datetick('x')

t1o = datenum(D1.start);
t2o = datenum(D2.start);
if t1o < t2o
    dt = t2o-t1o;    
    t1 = [0:size(D1.D,1)-1];
    t2 = [0:size(D2.D,1)-1] + dt*86400;
else
    dt = t1o-t2o;    
    t1 = [0:size(D1.D,1)-1] + dt*86400;
    t2 = [0:size(D2.D,1)-1];
end

[~,I1,I2] = intersect(t1,t2);

t1 = t1dn(I1);
E1 = D1.D(I1,4:5);
E2 = D2.D(I2,4:5);

I1o = find(~isnan(sum(E1,2)),1,'first');
I2o = find(~isnan(sum(E2,2)),1,'first');
I1f = find(~isnan(sum(E1,2)),1,'last');
I2f = find(~isnan(sum(E2,2)),1,'last');

E1 = E1(max([I1o,I2o]):min([I1f,I2f]),:);
E2 = E2(max([I1o,I2o]):min([I1f,I2f]),:);

t = [1:size(E1,1)];
for i = 1:2
    Ig1 = ~isnan(E1(:,i));
    E1(:,i) = interp1(t(Ig1),E1(Ig1,i),t);
    Ig2 = ~isnan(E2(:,i));
    E2(:,i) = interp1(t(Ig2),E2(Ig2,i),t);
end
Nd = floor(size(E2,1)/86400);
E1 = E1(1:Nd*86400,:);
E2 = E2(1:Nd*86400,:);

%E1 = E1(86400*6+1:end,:);
%E2 = E2(86400*6+1:end,:);

cc(E1,E2)

ao = 1;
bo = -1;
f = 0.5;
Gs(:,1) = ao*((1-f)*E1(:,1) + f*E2(:,1)) + bo*((1-f)*E1(:,2) + f*E2(:,2));
Gs(:,2) = ao*((1-f)*E1(:,1) + f*E2(:,1)) + bo*((1-f)*E1(:,2) + f*E2(:,2));

opts = main_options(1);
GsEo = transferfnConst(E1,Gs,opts);
GsE = transferfnFD(E1,Gs,opts);
GsE_avg = transferfnAverage(GsE,opts);

[SE1,fe] = smoothSpectra(E1);
[SE2,fe] = smoothSpectra(E2);

figure(2);clf;
    loglog(1./fe(2:end),SE1(2:end,1),'r');
    hold on;grid on
    loglog(1./fe(2:end),SE2(2:end,1),'r--');
    loglog(1./fe(2:end),SE1(2:end,2),'b');
    loglog(1./fe(2:end),SE2(2:end,2),'b--');
    loglog(1./fe(2:end),abs(SE1(2:end,1)-SE2(2:end,1))./SE1(2:end,1),'b','LineWidth',2);
    loglog(1./fe(2:end),abs(SE1(2:end,2)-SE2(2:end,2))./SE1(2:end,2),'r','LineWidth',2);
    %loglog(1./fe(2:end),abs(SBr(2:end,1)-SB(2:end,1))./SB(2:end,1),'r','LineWidth',2);
    legend('Ex MMB','Ex KAK','Ey KAK','Ey KAK','(Ex MMB-Ex KAK)/(Ex MMB)','(Ey MMB-Ey KAK)/(Ey MMB)','Location','Best');

figure(3);clf;
    loglog(1./GsE_avg.Mean.fe(2:end),abs(GsE_avg.Mean.Z(2:end,1)),'b');
    hold on;grid on;
    loglog(1./GsE_avg.Mean.fe(2:end),abs(GsE_avg.Mean.Z(2:end,2)),'r');
    legend('a','b','Location','Best');
    %grid on;set(gca,'YLim',[0.5,10])