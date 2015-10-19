clear;

opts = struct('T',3,'dt',2,'signal',1);

ref = 'DJI';
[Symbols,Starts] = stocks_info(ref);

Zp = [];
Zn = [];
Tp = [];
Tn = [];
for i = 1:1%length(Symbols)
    [zp,tp,zn,tn] = stocks(Symbols{i},ref,opts);
    fprintf('%5s Mean pos: %+.2f (%5d)\tMean neg: %+.2f (%5d)\t %+.2f\n',...
        Symbols{i},mean(zp),length(zp),mean(zn),length(zn),mean(zn)-mean(zp));
    if ~isnan(zp(1))
        Tp = [Tp,tp];
        Zp = [Zp,zp];
    end
    if ~isnan(zn(1))
        Tn = [Tn,tn];
        Zn = [Zn,zn];
    end
end
Ip = find(Tp > datenum([2010,1,1]) & ~isnan(Zp));
Zp = Zp(Ip);
In = find(Tn > datenum([2010,1,1])& ~isnan(Zn));
Zn = Zn(In);

fprintf('Mean pos: %.2f (%5d) std/sqrt(N) = %.2f\n',mean(Zp),length(Zp),std(Zp)/sqrt(length(Zp)));
fprintf('Mean neg: %.2f (%5d) std/sqrt(N) = %.2f\n',mean(Zn),length(Zn),std(Zn)/sqrt(length(Zn)));
