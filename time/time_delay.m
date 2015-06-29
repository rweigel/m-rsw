function [T,Xin] = time_delay(T,Xin,Nc,Ts,Na,padstr)
%TIME_DELAY Create time delay vectors
%
%   [T,X] = TIME_DELAY(T,X,Nc)
%   Example: [T,X] = time_delay([1:10]',[1:10]',4) ; [T,X]
%   returns
%   X = [ [4:9]', [3:8]', [2:7]', [1:6]' ]
%   T = [5:10]' 
% 
%   [T,X] = TIME_DELAY(T,X,Nc,Ts) Shifts all columns of output X by Ts
%   Example: [T,X] = time_delay([1:10]',[1:10]',1,1) ; [T,X]
%   Example: [T,X] = time_delay([1:10]',[1:10]',1,-1) ; [T,X]
%
%   [T,X] = TIME_DELAY(T,X,Nc,Ts,Na) Puts in Na acausal terms
%   Example: [T,X] = time_delay([1:10]',[1:10]',5,0,2) ; [T,X]
%   
%   Set X to [] if it is not needed as an output.
%   Example: T = time_delay([1:10]',[],5,0,2) ; T
%
%   TIME_DELAY(T,X,Nc,Ts,Na,'pad') Adds rows of NaNs to X and T so outputs
%   have same size as inputs and Tout(1,1)=Tin(1,1).  
%   Example: [T,X] = time_delay([1:10]',[1:10]',5,0,2,'pad') ; [T,X]
%   
%   See also TIME_DELAY_DEMO, BASIC_LINEAR.
  
if (nargin < 4)  
  Ts = 0;
end
if (nargin < 5)  
  Na = 0;
end

if ((Nc+Na) == 0)
  % error('Nc+Na must be > 0');
end

if (size(T,1) ~= size(Xin,1)) & (~isempty(Xin))
  error('T and Xin must have the same number of rows');
end

sT = size(T,1);

if (nargin == 6) % If padstr is given
  if (Ts >= 0)
    T   = [repmat(NaN,Nc+Ts,size(T,2)) ; T ; repmat(NaN,Na-1,size(T,2))];
    Xin = [repmat(NaN,Nc+Ts,size(Xin,2)) ; Xin ; repmat(NaN,Na-1,size(Xin,2))];
  end
  if (Ts < 0)
    T   = [repmat(NaN,Nc-1,size(T,2)) ; T ; repmat(NaN,Na-Ts,size(T,2))];
    Xin = [repmat(NaN,Nc-1,size(Xin,2)) ; Xin ; repmat(NaN,Na-Ts,size(Xin,2))];
  end
end
  
temp = [];

if (nargout > 1)
  if ~isempty(Xin)

    if (Nc+Na > 0)
      Xin = repmat(Xin,1,Nc+Na);
    end

    k = 0;
    L = size(Xin,1);
    for i = (Nc+Na):-1:1
      k = k+1;
      Xin(1:end-i+1,k) = Xin(i:end,k);
    end    
    
  end
end

if (Na>0)
  T = T(Nc+1:length(T)-(Na-1));
else
  T = T(Nc+1:length(T));
end  
Xin = Xin(1:length(T),:);

if (Ts > 0)
  T   = T(Ts+1:end);
  Xin = Xin(1:end-Ts,:);
end
if (Ts < 0)
  T   = T(1:end+Ts);
  Xin = Xin(-Ts+1:end,:);
end
