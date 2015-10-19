opts = struct('T',1,'dt',2,'signal',2);
%[zp,tp,zn,tn] = stocks('^VIX','VXX',opts);
%[zp,tp,zn,tn] = stocks('VXX','TVIX',opts);
% VXX is iPath
% TVIX is VelocityShares 2x VIX
% XIV is VelocityShares inverse VIX
% UVXY is ProShares Ultra VIX
%[zp,tp,zn,tn] = stocks('VXX','TVIX',opts);
%[zp,tp,zn,tn] = stocks('UVXY','TVIX',opts);
%[zp,tp,zn,tn] = stocks('XIV','TVIX',opts);
%[zp,tp,zn,tn] = stocks('XIV','UVXY',opts);
%[zp,tp,zn,tn] = stocks('XIV','VXX',opts);
[zp,tp,zn,tn] = stocks('SPY','QQQ',opts);