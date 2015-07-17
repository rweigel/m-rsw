function plotcmds(fname,writeimgs)
%PLOTCMDS

% Prefix filenames with name of script that generated.
s = dbstack;
base = ['./figures/',s(end).name,'_',fname];

if ~exist('./figures')
	mkdir('./figures')
end


a = get(gcf,'Children');
for i = 1:length(a)
	b = get(a(i));
	if isfield(b,'Location') % The legend object.
		set(a(i),'Color','none'); % Set legend background to transparent.
	else
		set(get(a(i),'Title'),'FontSize',14)
		set(get(a(i),'XLabel'),'FontSize',14)
		set(get(a(i),'YLabel'),'FontSize',14)
	end
end

if (nargin == 2 && ~writeimgs)
	return
end

fprintf('plotcmds: Writing %s.{png,eps}\n',base);
print('-depsc',sprintf('%s.eps',base))
fprintf('plotcmds: Wrote %s.eps (using print)\n',base);

if exist('/usr/local/bin/convert')
	% MATLAB does not allow quality parameter for png.
	% Use convert if available to create a better image.
	com = sprintf('convert -quality 100 -density 150 %s.eps %s.png',base,base);
	system(com);
	fprintf('plotcmds: Wrote %s.png (using convert on eps)\n',base);
else
	print('-dpng',sprintf('%s.png',base))
	fprintf('plotcmds: Wrote %s.png (using print)\n',base);
end
