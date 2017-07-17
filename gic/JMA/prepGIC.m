function [tGIC,GIC] = prepGIC()

if exist('prepGIC.mat','file')
    load prepGIC
    return;
end

GIC = [];
for i = 14:15
    fid=fopen(sprintf('data/jma/mmb/GIC/200612%02d.txt',i));
    tmp = fscanf(fid,'%f,%f\n');
    fclose(fid);
    tmp = reshape(tmp,2,86400)';
    GIC = [GIC;tmp];
end

% GIC files do not have time.  Rows are seconds since 2006-12-13 JST.
% JST is UT + 9 hours. 
tGIC = 3600*(24-9) + [0:size(GIC,1)-1]'; % Seconds since 2006-12-13:00:00:00Z
tGIC = tGIC + 66; % IRFs have peaks at t = -66 s.  Clearly a clock shift issue.
tGIC = tGIC/86400;

save prepGIC.mat tGIC GIC