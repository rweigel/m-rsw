function [T,Xin] = time_delayT(T,Xin,Nc,Ts,Na,padstr)
%TIME_DELAY Create time delay vectors
%
%   Same as TIME_DELAY, except Nc and Na are vectors.
%
%   [T,X] = time_delayT([1:50]',[1:50]',[1,2,3:2:8],0,[1,2,3:3:9]) ; [T,X]
%   [T,X] = time_delayT([1:50]',[1:50]',8,0,8) ; [T,X]
%   
%   See also TIME_DELAY_DEMO, BASIC_LINEAR.
  
if (nargin < 4)  
  Ts = 0;
end
if (nargin < 5)  
  Na = 0;
end

if (size(T,1) ~= size(Xin,1)) & (~isempty(Xin))
  error('T and Xin must have the same number of rows');
end

sT = size(T,1);


if (length(Na) > 1)
  Ta = Na;
  Na = Na(end);
else
  Ta = [1:Na];
end
if isempty(Ta)
  Na = 0;
  Ta = 0;
end
if (length(Nc) > 1)
  Tc = sort(-Nc+1+Nc(end));
  Nc = Tc(end);
else
  Tc = [1:Nc];
end

if (nargin == 6) % If padstr is given
  if ~isempty(padstr)
    T   = [repmat(NaN,Nc+Ts,size(T,2)) ; T ; repmat(NaN,Na,size(T,2))];
    Xin = [repmat(NaN,Nc+Ts,size(Xin,2)) ; Xin ; repmat(NaN,Na,size(Xin,2))];
  end
end

temp = [];

if (nargout > 1)
  if ~isempty(Xin)

    Xina = repmat(Xin,1,length(Ta));
    Xinc = repmat(Xin,1,length(Tc));

    if (Na > 0)
      for i = 1:length(Ta)
	Xina(1:end-Ta(i)+1,i) = Xin(Ta(i):end,1);
      end
      Xina = Xina(Tc(end)+1:end-Ta(end),:);
    else
      Xina = [];
    end
    tic
    if (Nc > 0)
      for i = 1:length(Tc)
	Xinc(1:end-Tc(i)+1,i) = Xin(Tc(i):end,1);
      end
      Xinc = Xinc(1:end-Tc(end)-Ta(end),:);
    else
      Xinc = [];
    end
    toc
    
    tic
    Xin = [fliplr(Xina),fliplr(Xinc)];
    toc
    
  end
end

T = T(Tc(end)+1+Ts:end-Ta(end),:);

