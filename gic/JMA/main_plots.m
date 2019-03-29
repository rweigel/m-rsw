setpaths;
if ~exist('filestr','var')
    filestr  = 'options-1';
    writepng = 0;
    fname = sprintf('mat/main_%s.mat',filestr);
    fprintf('main.m: Loading %s\n',fname);
    load(fname);
    fprintf('main.m: Loaded %s\n',fname);    
end

writepng = 0;

f.compareZplots(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,EB_avg.Mean,filestr,writepng);
f.comparePhiplots(GE_avg.Mean,GB_avg.Mean,EB_avg.Mean,filestr,writepng);

break

parameterhistograms(GEo,GEo_avg,filestr,writepng);

f = summaryPlots();

f.compareHplots(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,filestr,writepng);
f.compareZplots(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,GBa_avg.Mean,filestr,writepng);
f.comparePhiplots(GE_avg.Mean,GB_avg.Mean,filestr,writepng);
f.compareSN2(GEo_avg.Mean,GE_avg.Mean,GB_avg.Mean,GBa_avg.Mean,'',filestr,writepng);


%plot_summary(GEo_avg,GE_avg,GBo_avg,GB_avg,GBa_avg,EB_avg,filestr,writepng);

if 0
angle2 = atan2(squeeze(GE.In(:,2,:)),squeeze(GE.In(:,1,:)));
angle = atan(squeeze(GE.In(:,2,:))./squeeze(GE.In(:,1,:)));

figure(1);clf;
plot(angle2(:,1))
hold on;
plot(unwrap(angle2(:,1),pi));
[S,fe] = smoothSpectra(angle2,opts);

angle2r = reshape(angle2(:,1),3600,24);
angle2r = abs(fft(angle2r));

figure(2);clf;
loglog(1./fe(2:end),S(2:end,:));
end


