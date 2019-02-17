function opts = main_options(rn)

opts = struct();

opts.filestr = sprintf('options-%d',rn);

% # of points at start and end to trim before computing pe/cc/mse
opts.td.Ntrim = 600;

opts.td.transform = 'none'; % pca

opts.td.window.function = @rectwin;
opts.td.window.functionstr = 'rectangular';
opts.td.window.options = struct();

opts.td.prewhiten = struct();
opts.td.prewhiten.method = 'none';
opts.td.prewhiten.methodstr = 'none';
opts.td.prewhiten.options = [];

opts.fd.evalfreq = struct();
opts.fd.evalfreq.method = 'logarithmic';
opts.fd.evalfreq.methodstr = 'logarithmic';
opts.fd.evalfreq.options = [];

% Very poor results (as expected)
%opts.fd.evalfreq.method = 'linear';
%opts.fd.evalfreq.methodstr = 'linear';
%opts.fd.evalfreq.options = 100;

opts.fd.window = struct();

opts.fd.window.function = @rectwin; 
opts.fd.window.functionstr = 'rectangular';

opts.fd.regression = struct();
opts.fd.regression.method = 2; % 1-6
opts.fd.regression.methodstr = 'ols_on_Z';

opts.td.window.width = 3600*24;
opts.td.window.shift = 3600*24;

if rn == 1
    opts.description = 'Default';
elseif rn == 2
    opts.description = 'yulewalker(10) prewhiten';
    opts.td.prewhiten.method = 'yulewalker';
    opts.td.prewhiten.methodstr = 'yulewalker10';
    opts.td.prewhiten.options = 10;
elseif rn == 3
    opts.description = 'Parzen window in FD';
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';
elseif rn == 4
    opts.description = 'Robust regression';
    opts.fd.regression.method = 3; 
    opts.fd.regression.methodstr = 'robust_on_Z';
else
    error('Invalid option set number');
end

