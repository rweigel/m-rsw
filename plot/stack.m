N     = 4;
dlef  = 0.05;
drig  = 0.03;
w     = 1-dlef-drig;
gap   = 0.002;
dtop  = 0.02; % Space on bottom
dbot  = 0.06; % Space on bottom
He    = 1 - ( gap*(N-1)+dtop+dbot)
h     = He/N

orient tall;
t = 1-dtop-h;
l = dlef;
for i = 1:N
  subplot(N,1,i)
  plot(1:10,1:10)
  tlast = t;
  p = [l t w h]
  t = tlast - (h + gap);
  set(gca(),'Position',p);
  yt = cellstr(get(gca(),'YTickLabel'));
  if (i > 1)
    yt{end} = blanks(length(yt{end}));
  end
  if (i < N)
    yt{1} = blanks(length(yt{1}));
    set(gca(),'XTickLabel','');
  end
  yt{end} = sprintf('(%c)',96+i);
  yv = get(gca(),'YTick');
  yv(end) = yv(end)-0.1*(yv(end)-yv(end-1))
  set(gca(),'YTick',yv);
  set(gca(),'YTickLabel',yt);
end

