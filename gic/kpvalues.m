% Enter the following commands at the MATLAB/Octave command line prompt.
% Data will be placed in matrix named D and column labels in cell array L.
% 

SVR = 'http://tsds.org/get/';
QS  = 'catalog=CDAWeb&dataset=OMNI2_H0_MRG1HR&parameters=KP1800&start=2015-12-09&stop=2015-12-13&return=data&format=ascii-2';
tmp = [SVR,'?',QS];
fprintf('tsdsfe.m: Downloading %s\n',tmp);
[Ds,s]  = urlread(tmp); 
if (s == 0)
    fprintf('tsdsfe.m: Error when downloading.  Check server status at http://tsds.org/get/?catalog=CDAWeb\n');
end
D   = str2num(Ds);
L   = {'Year','Month','Day','Hour','Minute','Second','KP1800 []'};

fprintf('tsdsfe.m: Data matrix D [%d,%d] has column labels: ',size(D,1),size(D,2));
tmp = sprintf('%s, ',L{:});fprintf('%s\n',tmp(1:end-2));
fprintf('tsdsfe.m: First timestamp: %s\n',datestr(D(1,1:6),31));
fprintf('tsdsfe.m: Last timestamp:  %s\n',datestr(D(end,1:6),31));

mean(D(:,end))