addpath([fileparts(mfilename('fullpath')),'/m']);
addpath([fileparts(mfilename('fullpath')),'/m/plot']);
addpath([fileparts(mfilename('fullpath')),'/m/tf']);
addpath([fileparts(mfilename('fullpath')),'/m/data']);
addpath([fileparts(mfilename('fullpath')),'/m/stat']);
addpath([fileparts(mfilename('fullpath')),'/m/misc']);
addpath([fileparts(mfilename('fullpath')),'/m/plot/export_fig']);
addpath([fileparts(mfilename('fullpath')),'/m/stat/LIBRA']); % For mlochuber().
addpath([fileparts(mfilename('fullpath')),'/m/misc/spunt-printstruct'])

%addpath([fileparts(mfilename('fullpath')),'/../../time']); % TODO: Used?
addpath([fileparts(mfilename('fullpath')),'/../../stats']);
addpath([fileparts(mfilename('fullpath')),'/../transferfn']);

addpath([fileparts(mfilename('fullpath')),'/fujii']);    % For transferfnFujii()
addpath([fileparts(mfilename('fullpath')),'/../iris']);   % For readEDIXML() used by transferfnFujii()
addpath([fileparts(mfilename('fullpath')),'/../../xml']); % For xml2struct() used by readEDIXML()