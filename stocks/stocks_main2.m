opts = struct('T',1,'dt',2,'signal',2);
%[zp,tp,zn,tn] = stocks('^VIX','VXX',opts);
%[zp,tp,zn,tn] = stocks('VXX','TVIX',opts);
% http://blogs.barrons.com/focusonfunds/2015/10/12/what-volatility-plunging-vix-on-pace-for-10th-straight-slide/?mod=yahoobarrons&ru=yahoo
% http://www.bloomberg.com/news/articles/2015-10-09/one-of-wall-street-s-most-popular-post-crisis-trades-may-be-coming-to-an-end
% http://www.bloomberg.com/news/articles/2015-09-08/market-volatility-has-changed-immensely
% http://www.bloomberg.com/news/articles/2015-09-04/the-best-vix-etfs-are-also-the-most-dangerous
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