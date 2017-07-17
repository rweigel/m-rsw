set(0,'DefaultFigureWindowStyle','normal')
sname = 'main_plot'; % Script name
opts.figureSnapMethod = 'print';
opts.maxWidth = 800;
nodock = 1;
fname = publish(sname,opts); % Create html page
web(fname); % View html page
% Create and modify Markdown page for viewing on GitHub
[s,r] = system(sprintf('cd html;pandoc -s -r html -t markdown_github %s.html -o %s.md',sname,sname));
[s,r] = system(sprintf('sed "s/%s_/html\\/%s_/g" html/%s.md > %s.md',sname,sname,sname,sname));
[s,r] = system(sprintf('sed -i "s/\\.png)/.png)\\n/" %s.md',sname));
