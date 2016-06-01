clear
regen = 0;
base  = 'SPUD_bundle_2016-03-23T17.38.28';

addpath('../../xml');
addpath('../../plot');

load([base,'.mat']);

leftLon   = -123;
rightLon  = -115;
topLat    = 47;
bottomLat = 43;

k = 1;
for i = 1:length(Info)
    Lat = Info{i}.Latitude;
    Lon = Info{i}.Longitude;

    if Lat < topLat && Lat > bottomLat && Lon > leftLon && Lon < rightLon
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
end

C = getIRISCatalog();
units = 'counts';
for k = 41:length(SitesBox)
    % Note: getIRISCatalog() does not work for stations with multiple
    % instruments such as MBB05.
    sta = SitesBox{k};
    for i = 1:length(C)
	if strmatch(sta,C{i},'exact')
	    start = C{i}{2}(1:10);
	    stop = C{i}{3}(1:10);
	    chas = C{i}(4:end);
	    break
	end
    end
    chas = unique(chas);
    if (length(chas) > 5)
	error('Too many channels')
    end

    getIRIS(sta,start,stop,chas,units);
    prepIRIS(sta,start,stop,chas,units);
    plotIRIS(sta,start,stop,chas,units,'original');
    %cleanIRIS(sta,start,stop,chas,units);
    %plotIRIS(sta,start,stop,chas,units,'cleaned');
end

