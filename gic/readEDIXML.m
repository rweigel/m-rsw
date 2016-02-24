function D = readEDIXML(fname)
% READEDIXML Read EDI XML file
%
%   D = READEDIXML() - reads the test file readEDIXML.xml
%
%   D = READEDIXML(fname) - reads file fname
%
%   D is a structure with fields of matrices for PERIOD, Z, ZVAR, etc.
%   Columns of matrices correspond to period.
%   Rows of 4-row matrices correspond to subscripts xx, xy, yx, yy
%   Rows of 2-row matrices correspond to subscripts x, y

% Find URL using table at http://ds.iris.edu/spud/emtf
% along with station id.
if (nargin == 0)
    % Sample file downloaded on 10-1-2015 from
    % http://ds.iris.edu/spudservice/data/1418020
    % which is linked to from
    % http://ds.iris.edu/spud/emtf/1418021
    fname = 'readEDIXML.xml';
end

xDoc = xmlread(fname);
% TODO: Use parseXML code
% at http://www.mathworks.com/help/matlab/ref/xmlread.html
% to simplify.

root = xDoc.getChildNodes.item(0).getChildNodes;

for z = 1:2:root.getLength-1
    if strmatch(root.item(z).getNodeName,'Description')
        Description = root.item(z).getFirstChild.getData;
    end
    if strmatch(root.item(z).getNodeName,'ProductId')
        ProductId = root.item(z).getFirstChild.getData;
    end
    if strmatch(root.item(z).getNodeName,'Attachment')
        % Assumes Filename is first node.
        Filename = root.item(z).item(1).getFirstChild.getData;
    end    
end

fname0 = fname;

dnam  = fileparts(fname);
fname = char(Filename);
fname = regexprep(fname,'\..*','.mat');

if (length(dnam) > 0) % If not local directory.
    % Add path information
    fname = [dnam,filesep(),fname];
end

if (exist(fname))
    fprintf('readEDIXML: Reading %s\n',fname);
    load(fname);
    return;
end

fprintf('readEDIXML: Reading %s\n',fname0);

allListitems = xDoc.getElementsByTagName('Period');

for k = 0:allListitems.getLength-1
   
   thisListitem = allListitems.item(k);
   % <Period value=""
   t = thisListitem.getAttribute('value');
   T(k+1) = str2num(char(t));
   
   fprintf('readEDIXML: Reading data for T [sec] = %f\n',T(k+1));
   
   % Iterate over children of Period, e.g., Z, Z.VAR, ...
   for c = 1:2:thisListitem.getChildNodes.getLength-1
        el = thisListitem.getChildNodes.item(c);
        nm = el.getNodeName;
        
        % Iterate over children
        for i = 1:2:el.getChildNodes.getLength-1
            nm2 = el.getChildNodes.item(i).getAttribute('name');
            dat = el.getChildNodes.item(i).getFirstChild.getData;

            out = el.getChildNodes.item(i).getAttribute('output');
            in  = el.getChildNodes.item(i).getAttribute('input');

            if strmatch(char(nm),'Z','exact') % Impedance node
                if strmatch(char(nm2),'Zxx','exact')
                    tmp = str2num(char(dat));
                    Zxx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(char(nm2),'Zxy','exact')
                    tmp = str2num(char(dat));
                    Zxy(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(char(nm2),'Zyx','exact')
                    tmp = str2num(char(dat));
                    Zyx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(char(nm2),'Zyy','exact')
                    tmp = str2num(char(dat));
                    Zyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end
            
            if strmatch(char(nm),'Z.VAR','exact')
                if strmatch(char(nm2),'Zxx','exact')
                    ZVARxx(k+1) = str2num(char(dat));
                end
                if strmatch(char(nm2),'Zxy','exact')
                    ZVARxy(k+1) = str2num(char(dat));
                end
                if strmatch(char(nm2),'Zyx','exact')
                    ZVARyx(k+1) = str2num(char(dat));
                end
                if strmatch(char(nm2),'Zyy','exact')
                    ZVARyy(k+1) = str2num(char(dat));
                end        
            end

            if strmatch(char(nm),'Z.INVSIGCOV','exact')
                if ~isempty(strmatch(char(out),'Hx','exact')) && ~isempty(strmatch(char(in),'Hx','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hx','exact')) && ~isempty(strmatch(char(in),'Hy','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hy','exact')) && ~isempty(strmatch(char(in),'Hx','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hy','exact')) && ~isempty(strmatch(char(in),'Hy','exact'))
                    tmp = str2num(char(dat));
                    ZINVSIGCOVyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end

            if strmatch(char(nm),'Z.RESIDCOV','exact')
                if ~isempty(strmatch(char(out),'Ex','exact')) && ~isempty(strmatch(char(in),'Ex','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Ex','exact')) && ~isempty(strmatch(char(in),'Ey','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Ey','exact')) && ~isempty(strmatch(char(in),'Ex','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Ey','exact')) && ~isempty(strmatch(char(in),'Ey','exact'))
                    tmp = str2num(char(dat));                    
                    ZRESIDCOVyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end

            if strmatch(char(nm),'T','exact')
                if strmatch(char(nm2),'Tx','exact')
                    tmp = str2num(char(dat));
                    Tx(k+1) = tmp(1)+j*tmp(2);
                end
                if strmatch(char(nm2),'Ty','exact')
                    tmp = str2num(char(dat));
                    Ty(k+1) = tmp(1)+j*tmp(2);
                end
            end
            
            if strmatch(char(nm),'T.VAR','exact')
                if strmatch(char(nm2),'Tx','exact')
                    TVARx(k+1) = str2num(char(dat));
                end
                if strmatch(char(nm2),'Ty','exact')
                    TVARy(k+1) = str2num(char(dat));
                end
            end            

            if strmatch(char(nm),'T.INVSIGCOV','exact')
                if ~isempty(strmatch(char(out),'Hx','exact')) && ~isempty(strmatch(char(in),'Hx','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVxx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hx','exact')) && ~isempty(strmatch(char(in),'Hy','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVxy(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hy','exact')) && ~isempty(strmatch(char(in),'Hx','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVyx(k+1) = tmp(1)+j*tmp(2);
                end
                if ~isempty(strmatch(char(out),'Hy','exact')) && ~isempty(strmatch(char(in),'Hy','exact'))
                    tmp = str2num(char(dat));
                    TINVSIGCOVyy(k+1) = tmp(1)+j*tmp(2);
                end        
            end

            if strmatch(char(nm),'T.RESIDCOV','exact')
                if ~isempty(strmatch(char(out),'Hz','exact')) && ~isempty(strmatch(char(in),'Hz','exact'))
                    tmp = str2num(char(dat));
                    TRESIDCOVzz(k+1) = tmp(1)+j*tmp(2);
                end
            end
            
        end
   end
   
end
D = struct(...
    'Description',char(Description),...
    'ProductId',char(ProductId),...
    'Filename',char(Filename),...
    'PERIOD',T,...
    'Z',[Zxx;Zxy;Zyx;Zyy],...
    'ZVAR',[ZVARxx;ZVARxy;ZVARyx;ZVARyy],...
    'ZINVSIGCOV',[ZINVSIGCOVxx;ZINVSIGCOVxy;ZINVSIGCOVyx;ZINVSIGCOVyy],...
    'ZRESIDCOV',[ZRESIDCOVxx;ZRESIDCOVxy;ZRESIDCOVyx;ZRESIDCOVyy],...
    'T',[Tx;Ty],...
    'TVAR',[TVARx;TVARy],...
    'TINVSIGCOV',[TINVSIGCOVxx;TINVSIGCOVxy;TINVSIGCOVyx;TINVSIGCOVyy],...
    'TRESIDCOVzz',[TRESIDCOVzz]...
);

fprintf('readEDIXML: Saving %s\n',fname2);
save(fname2,'D');
