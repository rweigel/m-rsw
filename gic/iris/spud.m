regen = 1;
base  = 'SPUD_bundle_2016-03-23T17.38.28';

list = dir(base);

addpath('../../xml');

%load([base,'/',base,'.mat']);

for i = 3:length(list)
    el = list(i);
    dirn = strsplit(list(i).name,'.');
    list2 = dir(sprintf('%s/%s',base,list(i).name));
    for j = 3:length(list2)
        if strcmp(list2(j).name(end-2:end),'xml')
            sitefile{i} = list2(j).name;
        end
    end
    fname = sprintf('%s/%s',list(i).name,sitefile{i});
    SiteId{i-2}   = dirn{2};
    info          = readEDIXML(fname,base,regen);
    Info{i-2}     = info;
    Project{i-2}  = strrep(dirn{1},'MT_TF_','');
    LatLon(i-2,:) = [info.Latitude,info.Longitude];
    Rating(i-2)   = info.DataQualityRating;
    StartDN(i)    = datenum(info.Start,'YYYY-mm-ddTHH:MM:SS');
    StopDN(i)     = datenum(info.Stop,'YYYY-mm-ddTHH:MM:SS');
    fprintf('%4d/%4d %+0.2f %+0.2f %s %s %d %6s %s\n',...
	    i-2,length(list)-2,...
	    info.Latitude,info.Longitude,...
	    info.Start,info.Stop,...
	    info.DataQualityRating,...
	    SiteId{i-2},Project{i-2});
end

save([base,'/',base,'.mat'],'Info','Project','SiteId','LatLon','Rating','StartDN','StopDN');