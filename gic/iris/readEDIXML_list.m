clear;
base  = 'SPUD_bundle_2016-03-23T17.38.28';
load([base,'.mat']);

k = 1;
for i = 1:length(Info)
    Lat = Info{i}.Latitude;
    Lon = Info{i}.Longitude;

    fprintf('%6s %+0.2f %+0.2f %s %s %d\n',...
	    SiteId{i},...
	    Info{i}.Latitude,...
	    Info{i}.Longitude,...
	    Info{i}.Start,...
	    Info{i}.Stop,...
	    Info{i}.DataQualityRating);
    SitesBox{k} = SiteId{i};
    k = k + 1;

end


