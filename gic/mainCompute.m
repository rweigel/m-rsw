function [f,pX,fA,pA,p] = mainCompute(B,dB,E);

fprintf('mainCompute: Computing periodograms\n');

X = [B,dB,E];

% Make number of elements even
if (mod(size(X,1),2) ~= 0)
  X = X(1:end-1,:);
end

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(pX,1);
f   = [0:N/2]'/N;

% Averaged periodograms
for i = 1:size(X,2)
  tmp = X(1:86400*floor(size(X,1)/86400),i);
  tmp = reshape(tmp,86400,size(tmp,1)/86400);
  % Remove any days with one or more NaNs.
  I = find(sum(isnan(tmp)) == 0); 
  fprintf('  Removed %d/%d days in column %d because of NaNs.\n',...
	  size(tmp,2)-length(I),size(tmp,2),i);
  % Each cell element in p contains abs(FT) for one day.
  p{i}     = fft(tmp(:,I));  
  nA{i}    = length(I);         % Number that are averaged.
  pA(:,i)  = mean(abs(p{i}),2); % Average of each cell element.
  pA2(:,i) = abs(mean(p{i},2)); % Alternative method of averaging.
end
NA = size(pA,1);
fA = [1:NA/2]'/NA;
pA = pA(2:NA/2+1,:);
pX = pX(2:N/2+1,:);
f  = f(2:N/2+1);