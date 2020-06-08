ymin = -0.013909750618040562;
ymax = 0.043766051530838013;
D = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place ticks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ystep  = (ymax-ymin)/D;

fprintf('1.\n')
[ymin,ymax,ystep]

M  = 10.^[-308:308];
Mi = find(ystep*M > 1); % Use ystep to determine most significant digit 
Mi = 10^(-floor(log10(ystep)));
%Mi = M(Mi(1))

ymin = floor(ymin*Mi)/Mi;
ymax = ceil(ymax*Mi)/Mi;

fprintf('2.\n')
[ymin,ymax,ystep]

ystep = (ymax-ymin)/D; 
M  = 10.^[-308:308];

if (ystep == 0)
  Mi = find(ymin*M > 1);
  ystep = round(ymin*M(Mi(1)))/M(Mi(1));
else
  Mi = find(ystep*M > 1) ;  
  ystep = round(ystep*M(Mi(1)))/M(Mi(1));
end

fprintf('3.\n')
[ymin,ymax,ystep]

if (ystep*M(Mi(1)) > 1) & (ystep*M(Mi(1)) <=3)
  ystep = 2/M(Mi(1));
elseif (ystep*M(Mi(1)) > 3) & (ystep*M(Mi(1)) < 4)
  ystep = 4/M(Mi(1));
elseif (ystep*M(Mi(1)) > 4) & (ystep*M(Mi(1)) <= 7)
  ystep = 5/M(Mi(1));
elseif (ystep*M(Mi(1)) > 7) & (ystep*M(Mi(1)) <= 10)
  ystep = 10/M(Mi(1));
end

fprintf('4.\n')
[ymin,ymax,ystep]

ymin = floor(ymin/ystep)*ystep;
ymax = ceil(ymax/ystep)*ystep;

fprintf('5.\n')
[ymin,ymax,ystep]

if (ymin < 0) % Want 0 to have a tick
  ymino = ymin;
  ymin = [0:-ystep:ymin];
  if (ymin(end) < ymino)
    ymin = ymin(end);
  else
    ymin = ymin(end)-ystep;  
  end
end

fprintf('6.\n')
[ymin,ymax,ystep]

ticks = [ymin:ystep:ymax];

if length(ticks) > round(1.3*D);
  ystep = round(ystep*2);
end
ticks = [ymin:ystep:ymax];

fprintf('7.\n')
[ymin,ymax,ystep]

if (~isempty(ticks))
  if (ticks(end) < ymax) % Want top to have tick
    ymax = ticks(end)+ystep;
  end
else
  ticks=[-eps:eps:eps];
end

fprintf('8.\n')
ticks