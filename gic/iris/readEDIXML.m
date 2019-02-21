function D = readEDIXML(fname,base,regen,verbose)
% READEDIXML Read EDI XML file
%
%   D = READEDIXML() - reads the test file readEDIXML.xml
%
%   D = READEDIXML(fname) - Reads ./fname
%
%   D = READEDIXML(fname,base) - Looks for fname in directory base
%  

% Find URL using table at http://ds.iris.edu/spud/emtf

% along with station id.
if (nargin == 0)
    % Sample file downloaded on 10-1-2015 from
    % http://ds.iris.edu/spudservice/data/1418020
    % which is linked to from
    % http://ds.iris.edu/spud/emtf/1418021
    fname = 'readEDIXML.xml';
end

if nargin < 2
    base = '';
end
if nargin < 3
  regen = 0;
end
if nargin < 4
    verbose = 0;
end

% If siteid given
if length(strfind(fname,'.xml')) == 0
    if verbose
    	fprintf('readEDIXML: Looking for file associated with %s under directory %s\n',fname,base);
    end
    list = dir(base); % List of all files in all directory
    for i = 3:length(list)
        el = list(i);
        dirn = strsplit(list(i).name,'.');
        if strcmp(dirn{2},fname)
            fname = [list(i).name,'/',strrep(list(i).name,'MT_TF_',''),'.xml'];
            if verbose
                fprintf('readEDIXML: Found file associated with %s: %s\n',...
                    fname,list(i).name);
            end
            D = readEDIXML(fname,base,regen,verbose);
            return;
        end
    end
end

if length(base) > 0
    fname = sprintf('%s/%s',base,fname);
end

fnamemat = strrep(fname,'.xml','.mat');
if exist(fnamemat,'file') && regen == 0
  if verbose
      fprintf('readEDIXML: Found existing .mat version of .xml. Reading.\n',fname);
  end
  load(fnamemat);
  return;
end

if verbose
    fprintf('readEDIXML: Reading %s\n',fname);
end

So = xml2structure(fname);

if iscell(So.Site.Location)
    Latitude = str2num(So.Site.Location{2}.Latitude);
    Longitude = str2num(So.Site.Location{2}.Longitude);
else
    Latitude = str2num(So.Site.Location.Latitude);
    Longitude = str2num(So.Site.Location.Longitude);
end

Start = So.Site.Start;
Stop = So.Site.End;
DataQualityRating = str2num(So.Site.DataQualityNotes.Rating);

if isfield(So.Site.DataQualityNotes,'Comments')
    DataQualityComments = So.Site.DataQualityNotes.Comments;
else
    DataQualityComments = '';
end

if isfield(So.Site.DataQualityNotes,'GoodFromPeriod')
  DataQualityGoodPeriodRange = ...
      [str2num(So.Site.DataQualityNotes.GoodFromPeriod),
       str2num(So.Site.DataQualityNotes.GoodToPeriod)];
else
  DataQualityGoodPeriodRange = [];
end

xDoc = xmlread(fname);
root = xDoc.getChildNodes.item(0).getChildNodes;

for z = 1:2:root.getLength-1
    if strmatch(root.item(z).getNodeName,'Description')
        Description = root.item(z).getFirstChild.getData;
    end
    if strmatch(root.item(z).getNodeName,'ProductId')
        ProductId = root.item(z).getFirstChild.getData;
    end
    if strmatch(root.item(z).getNodeName,'Attachment')
        % Assumes FileName is first node.
        FileName = root.item(z).item(1).getFirstChild.getData;
    end
end

if ~exist('FileName')
    if verbose
      fprintf('readEDIXML: No filename found in xml. Using input filename.\n');
    end
    FileName = fname;
end
fname0 = fname;

dnam  = fileparts(fname);
fname = char(FileName);
fname = regexprep(fname,'\..*','.mat');

if (length(dnam) > 0) % If not local directory.
    % Add path information
    fname = [dnam,filesep(),fname];
end

allListitems = xDoc.getElementsByTagName('Period');

j = sqrt(-1);
for k = 0:allListitems.getLength-1
   
   thisListitem = allListitems.item(k);
   % <Period value=""
   t = thisListitem.getAttribute('value');
   T(k+1) = str2num(char(t));
   
   %fprintf('readEDIXML: Reading data for T [sec] = %f\n',T(k+1));
   
   % Iterate over children of Period, e.g., Z, Z.VAR, ...
   for c = 1:2:thisListitem.getChildNodes.getLength-1
        el = thisListitem.getChildNodes.item(c);
        nm = lower(el.getNodeName);
        
        % Iterate over children
        for i = 1:2:el.getChildNodes.getLength-1
            nm2 = upper(char(el.getChildNodes.item(i).getAttribute('name')));
            dat = el.getChildNodes.item(i).getFirstChild.getData;

            out = upper(char(el.getChildNodes.item(i).getAttribute('output')));
            in  = upper(char(el.getChildNodes.item(i).getAttribute('input')));

            if strmatch(nm,'Z','exact') % Impedance node
                if strmatch(nm2,'ZXX','exact')
                    tmp = str2num(char(dat));
                    Zxx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(nm2,'ZXY','exact')
                    tmp = str2num(char(dat));
                    Zxy(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(nm2,'ZYX','exact')
                    tmp = str2num(char(dat));
                    Zyx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(nm2,'ZYY','exact')
                    tmp = str2num(char(dat));
                    Zyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end
            
            if strmatch(nm,'Z.VAR','exact')
                if strmatch(nm2,'ZXX','exact')
                    ZVARxx(k+1) = str2num(char(dat));
                end
                if strmatch(nm2,'ZXY','exact')
                    ZVARxy(k+1) = str2num(char(dat));
                end
                if strmatch(nm2,'ZYX','exact')
                    ZVARyx(k+1) = str2num(char(dat));
                end
                if strmatch(nm2,'ZYY','exact')
                    ZVARyy(k+1) = str2num(char(dat));
                end        
            end
            
            if strmatch(nm,'Z.INVSIGCOV','exact')
                if ~isempty(strmatch(out,'HX','exact')) && ~isempty(strmatch(in,'HX','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HX','exact')) && ~isempty(strmatch(in,'HY','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HY','exact')) && ~isempty(strmatch(in,'HX','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HY','exact')) && ~isempty(strmatch(in,'HY','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end

            if strmatch(nm,'Z.RESIDCOV','exact')
                if ~isempty(strmatch(out,'EX','exact')) && ~isempty(strmatch(in,'EX','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'EX','exact')) && ~isempty(strmatch(in,'EY','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'EY','exact')) && ~isempty(strmatch(in,'EX','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'EY','exact')) && ~isempty(strmatch(in,'EY','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end

            if strmatch(nm,'T','exact')
                if strmatch(nm2,'TX','exact')
                    tmp = str2num(char(dat));
                    Tx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(nm2,'TY','exact')
                    tmp = str2num(char(dat));
                    Ty(k+1) = tmp(1)+j*tmp(2);
                end
            else
                Tx(k+1) = NaN;
                Ty(k+1) = NaN;
            end
            
            if strmatch(nm,'T.VAR','exact')
                if strmatch(nm2,'TX','exact')
                    TVARx(k+1) = str2num(char(dat));
                end
                if strmatch(nm2,'TY','exact')
                    TVARy(k+1) = str2num(char(dat));
                end
            else
                TVARx(k+1) = NaN;
                TVARy(k+1) = NaN;
            end            

            if strmatch(nm,'T.INVSIGCOV','exact')
                if ~isempty(strmatch(out,'HX','exact')) && ~isempty(strmatch(in,'HX','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HX','exact')) && ~isempty(strmatch(in,'HY','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HY','exact')) && ~isempty(strmatch(in,'HX','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(out,'HY','exact')) && ~isempty(strmatch(in,'HY','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVyy(k+1) = tmp(1)+j*tmp(2);
                end
            else
                TINVSIGCOVxx(k+1) = NaN;
                TINVSIGCOVxy(k+1) = NaN;
                TINVSIGCOVyx(k+1) = NaN;                
                TINVSIGCOVyy(k+1) = NaN;                
            end

            if strmatch(nm,'T.RESIDCOV','exact')
                if ~isempty(strmatch(out,'HZ','exact')) && ~isempty(strmatch(in,'HZ','exact'))
                    tmp = str2num(char(dat));
                    TRESIDCOVzz(k+1) = tmp(1)+j*tmp(2);
                end
            else
                    TRESIDCOVzz(k+1) = NaN;
            end
            
        end
   end
   
end

if exist('ZINVSIGCOVxx')
    ZINVSIGCOV = [ZINVSIGCOVxx;ZINVSIGCOVxy;ZINVSIGCOVyx;ZINVSIGCOVyy];
else
     ZINVSIGCOV = [];
end

if exist('ZRESIDCOVxx')
    ZRESIDCOV = [ZRESIDCOVxx;ZRESIDCOVxy;ZRESIDCOVyx;ZRESIDCOVyy];
else
    ZRESIDCOV = [];
end
if exist('TINVSIGCOVxx')
    TINVSIGCOV = [TINVSIGCOVxx;TINVSIGCOVxy;TINVSIGCOVyx;TINVSIGCOVyy];
else
    TINVSIGCOV = [];
end

if exist('TINVSIGCOVxx')
    TRESIDCOVzz = [TRESIDCOVzz];
else
    TRESIDCOVzz = [];
end

D = struct();
D.DataQualityRating =DataQualityRating;
D.DataQualityNotes = DataQualityComments;
D.DataQualityGoodPeriodRange = DataQualityGoodPeriodRange;
D.Latitude = Latitude;
D.Longitude = Longitude;
D.Start = Start;
D.Stop = Stop;
D.Description =char(Description);
D.ProductId =char(ProductId);
D.FileName = char(FileName);
D.PERIOD =T;
D.Z = [Zxx;Zxy;Zyx;Zyy];
D.ZVAR = [ZVARxx;ZVARxy;ZVARyx;ZVARyy]
D.ZINVSIGCOV = ZINVSIGCOV;
D.ZRESIDCOV = ZRESIDCOV;
D.T = [Tx;Ty];
D.TVAR =[TVARx;TVARy];
D.TINVSIGCOV = TINVSIGCOV;
D.TRESIDCOVzz = [TRESIDCOVzz];

if verbose
  fprintf('readEDIXML: Saving %s\n',fnamemat);
end
save(fnamemat,'D','So');