function [eAxesScale,UTo,UTf,eAxesPadLeft,eAxesPadRight] = autotick(Yc,type,D)
%AUTOTICK Place major ticks
%
%   [eAxesScale,UTo,UTf,eAxesPadLeft,eAxesPadRight] = autotick(Yc,type,D)
%

if (nargin < 2)
  type = 'y';
end

if (nargin < 3)
  if (type == 'y')
    D = 5;
  end
  if (type == 'x')
    D = 10;
  end
  if (type == 't')
    D = 10;
  end
end

if (all(Yc(~isnan(Yc(:))) == 0))
  eAxesScale = [0 0 0];
  return;
end

if (~iscell(Yc) & length(Yc(:)) == 1) % Just one number given
  tmp = Yc/10;
  Nz = 1;
  while floor(tmp) > 1
    tmp = tmp/10;  
    Nz = Nz+1;
  end
  if (type == 'x')
    if (Yc == 1)
      eAxesScale = [1 0.25 2];
      return;
    end
    eAxesScale = autotick([1:Yc],'x');
    return;
    if floor(Yc)==Yc & (Yc < 10)
      eAxesScale = [1 Nz*1 Yc];
      return;
    elseif mod(Yc,2)==0
      eAxesScale = [1 Nz*2 Yc];
      return;
    elseif mod(Yc,3)==0
      eAxesScale = [1 Nz*3 Yc];
      return;
    elseif mod(Yc,4)==0
      eAxesScale = [1 Nz*4 Yc]
      return;
    else
      Yc = [1:Yc];
    end
  end
  if (type == 'y')
    eAxesScale = autotick([0:Yc],'x');
    return;
    if floor(Yc)==Yc & (Yc < 9)
      eAxesScale = [0 1 (Yc-1)];
      return;
    elseif mod(Yc,2)==0
      eAxesScale = [0 2 (Yc-1)];
      return;
    elseif mod(Yc,3)==0
      eAxesScale = [0 3 (Yc-1)];
      return;
    elseif mod(Yc,4)==0
      eAxesScale = [0 4 (Yc-1)];
      return;
    else
      Yc = [0:Yc-1];
    end
  end
end

if (type == 't')
  UTo = Yc(1,:);
  UTf = Yc(2,:);
  eAxesPadRight = [];
  eAxesPadLeft = [];
  if (length(UTo) == 1) % UTo,UTf = Year

    % Put check that UTo is integer
    if floor(UTo)~=UTo
      error(sprintf('autotick: Input UTo (= %.f) is not an integer.',UTo));
    end
    if floor(UTf)~=UTf
      error(sprintf('autotick: Input UTf (= %.f) is not an integer.',UTf));
    end
    
    if (UTf-UTo) > 500  
      Yco = Yc;
      Yc = [floor(Yc(1)/10) ; ceil(Yc(2)/10)]
      [eAxesScale,UTf,UTo,eAxesPadLeft,eAxesPadRight] = autotick(Yc,'t');
      eAxesScale = 10*eAxesScale;
      UTf = 10*UTf;
      UTo = 10*UTo;
      eAxesPadLeft  = [repmat(NaN,Yco(1)-10*Yc(1));repmat(eAxesPadLeft,10,1)];
      eAxesPadRight = [repmat(NaN,10*Yc(2)-Yco(2));repmat(eAxesPadRight,10,1)];
      return;
    end
    if (UTf-UTo) > 200 % -> 25 year spacing
      if (rem(UTo,25) ~= 0)
	eAxesPadLeft = repmat(NaN,[UTo-25*floor(UTo/25)],1);
	UTo = 10*floor(UTo/10);
      end
      if (rem(UTf,25) ~= 0)
	eAxesPadRight = repmat(NaN,[25*ceil(UTf/25)-UTf],1);
	UTf = 25*ceil(UTf/25);
      end
      eAxesScale = [UTo 25 UTf];
      return;
    end
    if (UTf-UTo) > 50 % -> 10 year spacing
      if (rem(UTo,10) ~= 0)
	eAxesPadLeft = repmat(NaN,[UTo-10*floor(UTo/10)],1);
	UTo = 10*floor(UTo/10);
      end
      if (rem(UTf,10) ~= 0)
	eAxesPadRight = repmat(NaN,[10*ceil(UTf/10)-UTf],1);
	UTf = 10*ceil(UTf/10);
      end
      eAxesScale = [UTo 10 UTf];
      return;
    end
    if (UTf-UTo) > 25 % -> 5 year spacing
      if (rem(UTo,5) ~= 0)
	eAxesPadLeft = repmat(NaN,[UTo-5*floor(UTo/5)],1);
	UTo = 5*floor(UTo/5);
      end
      if (rem(UTf,5) ~= 0)
	eAxesPadRight = repmat(NaN,[5*ceil(UTf/5)-UTf],1);
	UTf = 5*ceil(UTf/5);
      end
      eAxesScale = [UTo 5 UTf];
      return;
    end
    if (UTf-UTo) > 10 % -> 2 year spacing
      if isodd(UTf-UTo)
	UTf = UTf+1;
	eAxesPadRight = NaN;
      end
      eAxesScale = [UTo 2 UTf];
      eAxesPadLeft = [];
      return;
    end
    if (UTf-UTo) > 10 % -> 2 year spacing
      if isodd(UTf-UTo)
	UTf = UTf+1;
      end
      eAxesScale = [UTo 2 UTf];
      eAxesPadLeft = [];
      eAxesPadRight = NaN;
      return;
    end
    if (UTf-UTo) >= 0
      eAxesScale = [UTo 1 UTf];
      eAxesPadLeft = [];
      eAxesPadRight = [];
      return;
    end
  end
end
  
if (type == 'x') | (type == 'y')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~iscell(Yc),L=size(Yc,2);else,L=length(Yc);,end

if (iscell(Yc))

  for i = 1:L
    ymin(i) = min_nonflag(Yc{i});
    ymax(i) = max_nonflag(Yc{i});
  end

  ymin = min_nonflag(ymin);
  ymax = max_nonflag(ymax);

else

  ymin = min_nonflag(Yc(:));
  ymax = max_nonflag(Yc(:));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place ticks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ystep  = (ymax-ymin)/D;

M  = 10.^[-308:308];
Mi = find(ystep*M > 1); % Use ystep to determine most significant digit 

if (~isempty(Mi))
  Mi = Mi(1);
  ymin = floor(ymin.*M(Mi))/M(Mi);
  ymax = ceil(ymax.*M(Mi))/M(Mi);
end

ystep = (ymax-ymin)/D; 
M  = 10.^[-308:308];

if (ystep == 0)
  Mi = find(ymin*M > 1);
  ystep = round(ymin*M(Mi(1)))/M(Mi(1));
else
  Mi = find(ystep*M > 1) ;  
  ystep = round(ystep*M(Mi(1)))/M(Mi(1));
end

if (ystep*M(Mi(1)) > 1) & (ystep*M(Mi(1)) <=3)
  ystep = 2/M(Mi(1));
elseif (ystep*M(Mi(1)) > 3) & (ystep*M(Mi(1)) < 4)
  ystep = 4/M(Mi(1));
elseif (ystep*M(Mi(1)) > 4) & (ystep*M(Mi(1)) <= 7)
  ystep = 5/M(Mi(1));
elseif (ystep*M(Mi(1)) > 7) & (ystep*M(Mi(1)) <= 10)
  ystep = 10/M(Mi(1));
end

if (0)
M  = 10.^[-3:3];
Mi = find(abs(ymin)*M > 1);
if (~isempty(Mi))
  ymin = floor(ymin*M(Mi(1)))/M(Mi(1));
  if (ymin*M(Mi(1)) < 5) & (ymin > 0)
    ymin = 0/M(Mi(1));
  elseif (ymin*M(Mi(1)) < 10) & (ymin > 0)
    ymin = 5/M(Mi(1));
  end
  if (ymin*M(Mi(1)) < -5) & (ymin < 0)
    ymin = -10/M(Mi(1));
  elseif (ymin*M(Mi(1)) < 0) & (ymin < 0)
    ymin = -5/M(Mi(1));
  end
end
end

ymin = floor(ymin/ystep)*ystep;

if (ymin < 0) % Want 0 to have a tick
  ymino = ymin;
  ymin = [0:-ystep:ymin];
  if (ymin(end) < ymino)
    ymin = ymin(end);
  else
    ymin = ymin(end)-ystep;  
  end
end

ticks = [ymin:ystep:ymax];
if length(ticks) > round(1.3*D);
  ystep = round(ystep*2);
end
ticks = [ymin:ystep:ymax];

if (~isempty(ticks))
  if (ticks(end) < ymax) % Want top to have tick
    ymax = ticks(end)+ystep;
  end
else
  ticks=[-eps:eps:eps];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eAxesScale = [ymin ystep ymax];

end

