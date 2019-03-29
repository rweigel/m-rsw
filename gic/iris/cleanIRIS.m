function cleanIRIS(sta,start,stop,chas,units)

fname1 = sprintf('../data/iris/%s/data/%s-%s-original.mat',sta,sta,units);
fname2 = sprintf('../data/iris/%s/data/%s-%s-cleaned.mat',sta,sta,units);

fprintf('Reading %s.\n',fname1);
load(fname1);

if strmatch(sta,'WAB05','exact')
  D(1:95000,:) = NaN;
end

if strmatch(sta,'CON21','exact')
  D(1:63000,:) = NaN;
  D(1276912:1276916,2) = NaN;
  D(1276912:1276916,3) = NaN;
  delta1 = nanmean(D(1275000:end,3)) - nanmean(D(1:140000,3));
  D(1276000:end,3) = D(1276000:end,3) - delta1;
end

if strmatch(sta,'CON20','exact')
  D(1:86400,:) = NaN;
end

if strmatch(sta,'UTN19','exact')
  D(1:86400,:) = NaN;
  D([1349808:1351450],1:3) = NaN;
end

if strmatch(sta,'ORF03','exact')
  t = [1:size(D,1)]/1000;
  delta1 = nanmean(D(850000:end,3))-nanmean(D(11000:848000,3));
  D(848000:end,3) = D(848000:end,3)-delta1;
  D(1:10400,3) = NaN;
  D(852455,5) = NaN;
  D(852480,5) = NaN;
  D(852486,5) = NaN;
  D(861374:861380,5) = NaN;  
end

if strmatch(sta,'ORF09','exact')
    %D(1:86400*3/2,:) = NaN;
    D(927000:950000,4:5) = NaN;
    D(1970000:end,4:5) = NaN;    
    %D(2041000:end,:) = NaN;
    %D(1101000:1109000,:) = NaN;
    %D(618000:1101000,4) = NaN;
end

if strmatch(sta,'ORF10','exact')
    D(1:86400*3/2,:) = NaN;
    D(866800:866880,1:3) = NaN;
    D(2041000:end,:) = NaN;
    D(1101000:1109000,:) = NaN;
    D(618000:1101000,4) = NaN;
    D(330645,4) = NaN;
    D(381192,4) = NaN;    
    D(382076,4) = NaN;    
end

if strmatch(sta,'GAA54','exact')
    D(243980:243984,:) = NaN;
end

if strmatch(sta,'COO20','exact')
    D(518223,:) = NaN;
end

if strmatch(sta,'MNG35','exact')
    D(1:86400*2,:) = NaN;
    D(168631:168632,4) = NaN;
    D(168638:168639,4) = NaN;
    D(191201:191202,4) = NaN;
    D(191221:191222,4) = NaN;    
    D(191260:191262,4) = NaN;    
    D(191666:191668,4) = NaN;    
    D(203625:203640,4) = NaN;    
    D(203678:203680,4) = NaN;    
    D(203734:203744,4) = NaN;    
    D(203683:203689,4) = NaN;        
end

if strmatch(sta,'WII41','exact')
    D(749700:749000,:) = NaN;        
end

if strmatch(sta,'NEK32','exact')
    %D(749700:749000,:) = NaN;
    D([234041:234115],1:3) = NaN;

end

if strmatch(sta,'NEK29','exact')
    D([965331:970507],1:3) = NaN;
    D([640974:669541],4) = NaN;
    D([109262:109281],4) = NaN;
    D([111373:111390],4) = NaN;
    D([213449:213756],5) = NaN;
    D(:,4:5) = despikeE(D(:,4:5),1e4,[-2,6]);
end

if strmatch(sta,'NEK28','exact')
    D([152083:152395],1:3) = NaN;
    D(:,4:5) = despikeE(D(:,4:5),1e4,[-2,6]);
end

if strmatch(sta,'NEK27','exact')
    % TODO: Calibration factor for By and Bz probably different from
    % Bx.
    D(844459:end,2) = D(844459:end,2) - (1881000-1849000);
    D(844459:end,3) = D(844459:end,3) - (5027000-4753000);
    D(:,2) = D(:,2) - 1.8e6;
    D(:,3) = D(:,3) - 5.e6;
    D(:,4:5) = despikeE(D(:,4:5),1e4,[-2,6]);
    D([1651038:1658275],4:5) = NaN;
end

t = [1:size(D,1)];
for i = 1:size(D,2)
    figure(i);clf
    plot(t,D(:,i));
    drawnow;
    title(sprintf('%s %s [counts/1e6] %s-%s',sta,chas{i},start,stop));
    xlabel('(measurement #)/1000')
    grid on;
    grid minor;
    zoom off;
    hB = zoom(gca);
    hB.ActionPreCallback = @(obj,evd) fprintf('');
    hB.ActionPostCallback = @(obj,evd) fprintf('Showing D([%d:%d],%d)\n',round(evd.Axes.XLim),i);
end

fprintf('Zoom in on bad areas, record index range and place in cleanIRIS.m\n');
s = input('Write output file y/[n]?','s');
if isempty(s) | s(1) == 'n'
    keyboard
end

fprintf('Removing mean.\n');
for i = 1:size(D,2)
  D(:,i) = D(:,i) - nanmean(D(:,i));
end

fprintf('Writing %s.\n',fname2);
save(fname2,'D','sta','start','stop','chas');


