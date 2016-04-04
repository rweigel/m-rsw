function S = xml2structure(root,S,l)
%XML2STRUCTURE
%
%   XML2STRUCTURE(filename) Returns a structure representation of XML file
%   filename.
%

debug = 0;

if nargin < 2
    xDoc = xmlread(root);
    root = xDoc.getChildNodes.item(0).getChildNodes;
    S = struct();
    l = 0;
end
b = repmat(' ',l,1);

first = 1;
for z = 1:2:root.getLength-1
    fieldname = char(root.item(z).getNodeName);
    fieldname = strrep(fieldname,'.','_');
    if debug,fprintf('%sNode: %s\n',b,fieldname);end

    clear attributes
    if root.item(z).hasAttributes
        attributes = struct();
        if debug,fprintf('%sNode: %s has attributes.\n',b,fieldname);end
        for a = 0:root.item(z).getAttributes.getLength-1
            if length(root.item(z).getAttributes.item(a)) > 0
	      item = root.item(z).getAttributes.item(a);
	      attribname = char(item.getName);
	      attribdata = char(item.getNodeValue);
	      if debug
		fprintf('%sname = value: %s=%s\n',...
			repmat('  ',l+1,1),attribname,attribdata);
	      end
	      attributes = setfield(attributes,[attribname,'_'],attribdata);
            end
        end
    end
    
    if (root.item(z).getLength == 1)
        if length(root.item(z).getFirstChild) == 0
            data = '';
        else
            data = deblank(char(root.item(z).getFirstChild.getData));
        end
    else
        tmp = xml2structure(root.item(z),struct(),1);
        if isempty(fieldnames(tmp))
            data = '';
        else
            data = tmp;
        end
    end
    if exist('attributes')
        data = {struct('attributes_',attributes),data};
    end
    if isfield(S,fieldname)
        if debug
	  fprintf('%sAnother Node %s found at this level.\n',b,fieldname);
	end
        tmpo = getfield(S,fieldname);
        if (first == 1)
            tmpo = {tmpo};
        end
        if ~iscell(tmpo)
            data = {tmpo,data};
        else
            tmpo{end+1} = data;
            data = tmpo;
        end
        first = 0;
    end
    S = setfield(S,fieldname,data);
end