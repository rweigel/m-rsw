function [f,pX,fA,pA,p] = mainCompute(B,dB,E,ppd);

fprintf('mainCompute: Computing periodograms\n');

X = [B,dB,E];

% Make number of elements even
if (mod(size(X,1),2) ~= 0)
  X = X(1:end-1,:);
end

% Raw periodograms
ftX = fft(X);
pX  = abs(ftX);
N   = size(X,1);
f   = [0:N/2]'/N;
pX  = 2*pX(2:N/2+1,:)/N;
f   = f(2:end);

% Averaged periodograms
for i = 1:size(X,2)
  tmp = X(1:ppd*floor(size(X,1)/ppd),i);
  tmp = reshape(tmp,ppd,size(tmp,1)/ppd);
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
