function [Bi,dBi,Ei,dn] = mainInterpolate(B,dB,E,dn)

fprintf('mainInterpolate: Interpolating\n');
for i = 1:3
    ifB(i) = find(~isnan(B(:,i)),1,'first'); % First non-NaN
    ilB(i) = find(~isnan(B(:,i)),1,'last');  % Last non-NaN
end
for i = 1:2
    ifE(i) = find(~isnan(E(:,i)),1,'first'); % First non-NaN
    ilE(i) = find(~isnan(E(:,i)),1,'last');  % Last non-NaN
end

% Need to not interpolate over large gaps.
io = max([ifB,ifE]);
il = min([ilB,ilE]); 

fprintf('  First point kept: %d\n',io);
fprintf('  Last point kept: %d of %d\n',il,size(B,1));

B  = B([io:il-1],:); % -1 to account for dB
dB = dB([io:il-1],:);
E  = E([io:il-1],:);
dn = dn([io:il-1]);

% Interpolate over bad points
for i = 1:size(B,2)
  ti = [1:size(B,1)]';
  yi = B(:,i);
  Ig = find(isnan(yi) == 0);
  Nnan = size(B,1)-length(Ig);
  Bnaninfo(1,i) = Nnan;
  Bnaninfo(2,i) = max(diff(Ig));
  fprintf('  Found %d NaNs in component %d of B. ',Nnan,i);
  fprintf('  Max gap = %d\n',Bnaninfo(2,i));
  Bi(:,i) = interp1(ti(Ig),yi(Ig),ti);
end
for i = 1:size(dB,2)
  ti = [1:size(dB,1)]';
  yi = dB(:,i);
  Ig = find(isnan(yi) == 0);
  Nnan = size(dB,1)-length(Ig);
  dBnaninfo(1,i) = Nnan;
  dBnaninfo(2,i) = max(diff(Ig));
  fprintf('  Found %d NaNs in component %d of dB. ',Nnan,i);
  fprintf('  Max gap = %d\n',dBnaninfo(2,i));
  dBi(:,i) = interp1(ti(Ig),yi(Ig),ti);
end
for i = 1:size(E,2)
  ti = [1:size(E,1)]';
  yi = E(:,i);
  Ig = find(isnan(yi) == 0);
  Nnan = size(E,1)-length(Ig);
  Enaninfo(1,i) = length(Ig);
  Enaninfo(2,i) = max(diff(Ig));
  Nnan = size(B,1)-length(Ig);
  Enaninfo(1,i) = Nnan;
  Enaninfo(2,i) = max(diff(Ig));
  fprintf('  Found %d NaNs in component %d of E. ',Nnan,i);
  fprintf('  Max gap = %d\n',Enaninfo(2,i));
  Ei(:,i) = interp1(ti(Ig),yi(Ig),ti);
end

