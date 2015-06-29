To(1,:) = [2004,1,1];
Tf(1,:) = [2007,12,31];

STA{1,1} = 'ABK X (Abisko) lat,long = 68.358,18.823  (WDC Edinburgh 1-minute)';
STA{1,2} = 'ABK Y (Abisko) lat,long = 68.358,18.823  (WDC Edinburgh 1-minute)';
STA{1,3} = 'ABK Z (Abisko) lat,long = 68.358,18.823  (WDC Edinburgh 1-minute)';
STA{2,1}='CMO X (College) lat,long = 64.867,212.167  (WDC Edinburgh 1-minute)';
STA{2,2}='CMO Y (College) lat,long = 64.867,212.167  (WDC Edinburgh 1-minute)';
STA{2,3}='CMO Z (College) lat,long = 64.867,212.167  (WDC Edinburgh 1-minute)';

for sta = 1:2;

X(:,1) = ts_get(STA{sta,1},To,Tf,1440);
X(:,2) = ts_get(STA{sta,2},To,Tf,1440);
X(:,3) = ts_get(STA{sta,3},To,Tf,1440);
X1     = block_detrend_nonflag(X,1440*365);
X2     = block_mean_nonflag(X1,60);
F      = (X2(:,1));

[D{sta},UT,DOY] = ut_doy_ave(F,[To(1,1):Tf(1,1)],24,[],[],NaN);
D{sta}(1)   = -140;
D{sta}(end) = 140;

figure(sta);
subplot(2,1,1)
 title(STA{sta,1}(1:3))
 plot(F);hold on;
 plot(X2);
subplot(2,1,2)
pcolor2(UT(:,1),DOY(1,:),D{sta}');
 xlabel('UT');
 ylabel('DOY');
 h = colorbar;
end 

figure();
pcolor2(UT(:,1),DOY(1,:),(D{2}-D{1})');
xlabel('UT');
ylabel('DOY');
h = colorbar;


 