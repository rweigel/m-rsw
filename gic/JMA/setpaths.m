addpath([fileparts(mfilename('fullpath')),'/m']);
addpath([fileparts(mfilename('fullpath')),'/plot']);
addpath([fileparts(mfilename('fullpath')),'/m/export_fig']);
addpath([fileparts(mfilename('fullpath')),'/m/LIBRA']); % For mlochuber().
addpath([fileparts(mfilename('fullpath')),'/m/spunt-printstruct'])

addpath([fileparts(mfilename('fullpath')),'/../../time']); % TODO: Used?
addpath([fileparts(mfilename('fullpath')),'/../../stats']);
addpath([fileparts(mfilename('fullpath')),'/../transferfn']);

addpath([fileparts(mfilename('fullpath')),'/fuji']);    % For transferfnFuji()
addpath([fileparts(mfilename('fullpath')),'/../iris']);   % For readEDIXML() used by transferfnFuji()
addpath([fileparts(mfilename('fullpath')),'/../../xml']); % For xml2struct() used by readEDIXML()