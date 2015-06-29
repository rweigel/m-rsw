function bandpassplot(x,keep,Year_o)

[xbpc,aibc] = bandpass(x,keep);

Ts  = 24;
Npr = 26;
%Ts  = 1;
%Npr = 16;
N     = length(xbpc);
dlef  = 0.10;
drig  = 0.177;
w     = 1-dlef-drig;
gap   = 0.01;
dtop  = 0.02; % Space on bottom
dbot  = 0.06; % Space on bottom
He    = 1 - ( gap*(N-1)+dtop+dbot);
h     = He/N;

orient landscape;
t = 1-dtop-h;
l = dlef;
labstr{1} = '13-day bandpass amp [km/s]';
labstr{2} = '26-day bandpass amp [km/s]';

for i = 1:N
  subplot(N,1,i)
  xbp = xbpc{i};
  xbpr = reshape2(xbp,Npr*Ts);
  pcolor2([1:size(xbpr,2)],[1:size(xbpr,1)]'/Ts,xbpr);
  colorbar();
%  set(get(h,'Title'),'String',sprintf(labstr{i}));
%  set(get(h,'Title'),'Rotation',-90)

  [XLabels,XTick] = year_labels([1:length(xbp)/Ts],[Year_o,1,1]);
  tlast = t;
  p = [l t w h];
  t = tlast - (h + gap);
  set(gca(),'Position',p);
  yt = cellstr(get(gca(),'YTickLabel'));
  if (i > 1)
%    yt{end} = blanks(length(yt{end}));
  end
  if (i < N)
%    yt{1} = blanks(length(yt{1}));
    set(gca(),'XTickLabel','');
    set(gca(),'XTick',XTick/Npr);
  else
    set(gca(),'XTick',XTick/Npr);
    set(gca(),'XTickLabel',XLabels(:,3:end));
  end
%  yt{end} = sprintf('(%c)',round(96+i));
  yv = get(gca(),'YTick');
%  yv(end) = yv(end)-0.05*(yv(end)-yv(end-1));
  set(gca(),'YTick',yv);
  set(gca(),'YTickLabel',yt);
  grid on;
  set(gca,'Layer','top')
  ylabel('Days');
end
