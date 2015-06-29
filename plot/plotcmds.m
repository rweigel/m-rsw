function plotcmds(tmp)
%PLOTCMDS

set(0,'defaultaxesfontsize',16); 
set(0,'defaulttextfontsize',16);

fprintf('plotcmds: plotting %s.png and .eps\n',tmp);
eval(sprintf('print -depsc %s.eps',tmp))
system(sprintf('convert -quality 100 -density 100 %s.eps %s.png',tmp,tmp));
