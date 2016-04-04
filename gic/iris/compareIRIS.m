clear
MBB03 = load('../data/iris/MBB03/data/MBB03-counts-cleaned.mat');
NVN08 = load('../data/iris/NVN08/data/NVN08-counts-cleaned.mat');
CON21 = load('../data/iris/CON21/data/CON21-counts-cleaned.mat');

start = '2010-10-25';
stop  = '2010-11-16';
dno = datenum(start);
dnf = datenum(stop);
Nd  = dnf-dno+1;
t   = [0:86400*Nd-1]/86400;
ti  = [1:length(t)];

%Bx1 = MBB03.D(86401:end-86400,1);
%Bx2 = NVN08.D(86401:end-86400,1);

Bx1 = MBB03.D(86401:end-86400,1);
Bx2 = CON21.D(86401:end-86400,1);
s1  = nanstd(Bx1);
s2  = nanstd(Bx2);

Bx1 = (Bx1-nanmean(Bx1))/s1;
Bx2 = (Bx2-nanmean(Bx2))/s2;

figure(6);clf;hold on;
  [n1,x1] = hist(Bx1,[-4:0.01:4]);
  [n2,x2] = hist(Bx2,[-4:0.01:4]);

  plot(x1,log10(n1),'r','MarkerSize',20);
  plot(x2,log10(n2),'b','MarkerSize',20);
  
%tx1  = find(~isnan(Bx1));
%Bx1i = interp1(tx1,Bx1(tx1),ti);

%tx2  = find(~isnan(Bx2));
%Bx2i = interp1(tx2,Bx2(tx2),ti);

% Raw periodograms
ftX1 = fft(Bx1);
ftX2 = fft(Bx2);
pX1  = abs(ftX1);
pX2  = abs(ftX2);
N   = length(pX1);
f   = [0:N/2]'/N;

figure(7);clf
  loglog(f(2:end),pX1(2:N/2+1),'r','LineWidth',1);
  hold on;grid on;
  loglog(f(2:end),pX2(2:N/2+1),'b','LineWidth',1);

% Averaged periodograms
tmp1 = reshape(Bx1,86400,length(Bx1)/86400);
tmp2 = reshape(Bx2,86400,length(Bx2)/86400);

pA1 = mean(abs(fft(tmp1)),2);
pA2 = mean(abs(fft(tmp2)),2);
NA = length(pA1);
fA = [0:NA/2]'/NA;

figure(8);clf;
  loglog(fA(2:end),pA1(2:NA/2+1),'r','LineWidth',1);
  hold on;grid on;
  loglog(fA(2:end),pA2(2:NA/2+1),'b','LineWidth',1);

break

for i = 1:5
  figure(i);clf;hold on;
    plot(t,MBB03.D(:,i),'r');
    plot(t,NVN08.D(:,i),'b');
    xlabel('Days');
    title(sprintf('Start Date: %s',start));
    legend('MBB03','NVN08');
end
  