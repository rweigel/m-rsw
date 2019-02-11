if ~exist('Opts','var')
    for i = 1:4
        file = sprintf('mat/main_%s.mat',sprintf('options-%d',i));
        fprintf('plot_options_comparison: Loading from %s\n',file);
        Opts{i} = load(file,'*_avg');
        % TODO: Can remove following after re-running main()
        opts = main_options(i);
        Opts{i}.description = opts.description;
    end
end

figprep(png,1000,500)

fn = 0;
sf = 1e3;

c = ['k','r','g','b','m','c'];

for i = 1:length(Opts)
    if isfield(Opts{i},'description')
        leglabels{i} = Opts{i}.description;
    else
        leglabels{i} = sprintf('Options %d',i);
    end
end

% Error bars only shown for first options set.

if 0
    %F = load(file,'GE');
    f = size(F.GE.Z,1);
    [n,x] = hist(squeeze(abs(sf*F.GE.Z(f,3,:))));
    %x = [x(1),x,x(end)];
    %n = [0,n,0];
    bar(x,n);
    title(sprintf('T = %.1f',1./F.GE.fe(f)));
    xlabel('$A(\omega)$');
    ylabel('\#');
end

T = 1./Opts{1}.GE_avg.Mean.fe(2:end);

% Compare options using Mean model
titles = {'$A(\omega)$','$B(\omega)$'};
for i = 3:4
    fn=fn+1;figure(fn);clf;
    for j = 1:length(Opts)
        loglog(T,sf*Opts{j}.GE_avg.Mean.Zabs(2:end,i),c(j),...
            'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
        hold on;grid on;axis tight;
    end
    errorbars(T,...
              sf*Opts{1}.GE_avg.Mean.Zabs(2:end,i),...
              2*sf*Opts{1}.GE_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.GE_avg.Mean.Zabs_StdErr(2:end,i),'y',c(1));
    title(titles{i-2});
    legend(leglabels{:},'Location','Best');
end

% Compare Mean, Median, and Huber averaged model for options set j.
j = 1;
for i = 3:4
    fn=fn+1;figure(fn);clf;
    loglog(T,sf*Opts{j}.GE_avg.Mean.Zabs(2:end,i),c(1),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    hold on;grid on;axis tight;
    loglog(T,sf*Opts{j}.GE_avg.Mean.Zabs2(2:end,i),c(2),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GE_avg.Median.Zabs(2:end,i),c(3),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GE_avg.Median.Zabs2(2:end,i),c(4),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GE_avg.Huber.Zabs2(2:end,i),c(5),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    errorbars(T,...
              sf*Opts{1}.GE_avg.Mean.Zabs(2:end,i),...
              2*sf*Opts{1}.GE_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.GE_avg.Mean.Zabs_StdErr(2:end,i),'y',c(j));
    title(sprintf('%s: %s',Opts{j}.description,titles{i-2}));
    legend('Mean','Mean2','Median','Median2','Huber2','Location','Best');
end

titles = {'$Z_{x}$','$Z_{y}$'};
for i = 3:4
    fn=fn+1;figure(fn);clf;
    for j = 1:length(Opts)
        loglog(T,sf*Opts{j}.GB_avg.Mean.Zabs(2:end,i),c(j),...
            'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
        hold on;grid on;axis tight;
    end
    errorbars(T,...
              sf*Opts{1}.GB_avg.Mean.Zabs(2:end,i),....
              2*sf*Opts{1}.GB_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.GB_avg.Mean.Zabs_StdErr(2:end,i),'y',c(1));
    title(titles{i-2});
    legend(leglabels{:},'Location','Best');
end

% Compare Mean, Median, and Huber averaged model for options set j.
j = 1;
for i = 3:4
    fn=fn+1;figure(fn);clf;
    loglog(T,sf*Opts{j}.GB_avg.Mean.Zabs(2:end,i),c(1),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    hold on;grid on;axis tight;
    loglog(T,sf*Opts{j}.GB_avg.Mean.Zabs2(2:end,i),c(2),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GB_avg.Median.Zabs(2:end,i),c(3),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GB_avg.Median.Zabs2(2:end,i),c(4),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.GB_avg.Huber.Zabs2(2:end,i),c(5),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    errorbars(T,...
              sf*Opts{1}.GB_avg.Mean.Zabs(2:end,i),...
              2*sf*Opts{1}.GB_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.GB_avg.Mean.Zabs_StdErr(2:end,i),'y',c(j));
    title(sprintf('%s: %s',Opts{j}.description,titles{i-2}));
    legend('Mean','Mean2','Median','Median2','Huber2','Location','Best');
end

titles = {'$Z_{xx}$','$Z_{xy}$','$Z_{yy}$','$Z_{yx}$'};
for i = 1:4       
    fn=fn+1;figure(fn);clf;
    for j = 1:length(Opts)
        loglog(T,sf*Opts{j}.EB_avg.Mean.Zabs(2:end,i),c(j),...
            'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
        hold on;grid on;axis tight;
    end
    errorbars(T,...
              sf*Opts{1}.EB_avg.Mean.Zabs(2:end,i),...
              2*sf*Opts{1}.EB_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.EB_avg.Mean.Zabs_StdErr(2:end,i),'y',c(1));
    title(titles{i});
    legend(leglabels{:},'Location','Best');
end

% Compare Mean, Median, and Huber averaged model for options set j.
j = 1;
for i = 1:4
    fn=fn+1;figure(fn);clf;
    loglog(T,sf*Opts{j}.EB_avg.Mean.Zabs(2:end,i),c(1),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    hold on;grid on;axis tight;
    loglog(T,sf*Opts{j}.EB_avg.Mean.Zabs2(2:end,i),c(2),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.EB_avg.Median.Zabs(2:end,i),c(3),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.EB_avg.Median.Zabs2(2:end,i),c(4),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    loglog(T,sf*Opts{j}.EB_avg.Huber.Zabs2(2:end,i),c(5),...
          'LineStyle','-','LineWidth',1);%'Marker','.','MarkerSize',20);
    errorbars(T,...
              sf*Opts{1}.EB_avg.Mean.Zabs(2:end,i),...
              2*sf*Opts{1}.EB_avg.Mean.Zabs_StdErr(2:end,i),...
              2*sf*Opts{1}.EB_avg.Mean.Zabs_StdErr(2:end,i),'y',c(j));
    title(sprintf('%s: %s',Opts{j}.description,titles{i}));
    legend('Mean','Mean2','Median','Median2','Huber2','Location','Best');
end

       