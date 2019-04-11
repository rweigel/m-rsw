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

fdir = [fileparts(mfilename('fullpath')),'/figures/combined'];

% Test difference in Z when top 50% vs. lowest 50% PEs are used.
if 0
    for i = 1:size(GE.In_FT,1)
        CIn(i)  = cc(squeeze(GE.In_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));
        COut(i) = cc(squeeze(GE.Out_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));    
        CErr(i) = cc(squeeze(GE.Error_PSD(i,2,:)),squeeze(abs(GE.Z(i,3,:))));    
        CPE(i)  = cc(squeeze(GE.PE(1,2,:)),squeeze(abs(GE.Z(i,3,:))));    

        %[~,I] = sort(squeeze(GE.In_PSD(i,2,:)));
        [~,I] = sort(squeeze(GE.PE(1,2,:)));    
        Zmin(i,3) = mean(abs(GE.Z(i,3,I(1:end/2))),3);
        Zave(i,3) = mean(abs(GE.Z(i,3,:)),3);
        Zmax(i,3) = mean(abs(GE.Z(i,3,I(end/2:end))),3);    

        T = 1./GE.fe;

        figure(2);clf;
            loglog(T,Zmax(:,3),'r');
            hold on;
            loglog(T,Zmin(:,3),'g');    
            loglog(T,Zave(:,3),'b');

        figure(1);clf;
            semilogx(T,CIn,'r');
            hold on;grid on;
            semilogx(T,COut,'g');
            semilogx(T,CErr,'b');
            semilogx(T,CPE,'k');    
    end
end


png = 0;

figprep(png,600,600)

fn = 0;

c = ['k','r','g','b','m','c'];

for i = 1:length(Opts)
    if isfield(Opts{i},'description')
        leglabels1{i} = Opts{i}.description;
    else
        leglabels1{i} = sprintf('Options %d',i);
    end
end

T = 1./Opts{1}.GE_avg.Mean.fe(2:end);

for m = 1:3 % Model #

    if m == 1
        titles = {'$|a(\omega)| (non-despiked G)$','$|b(\omega)| (non-despiked G)$','$|a(\omega)|$','$|b(\omega)|$'};
        files = {'a_notdespiked','b_notdespiked','a','b'};
        units = ' [A/(V/km)]';
        sf = 1e3; % A/(mV/km) -> A/(V/km)
        for j = 1:length(Opts)
            V{j} = Opts{j}.GE_avg;
        end
        cols = [3,4];
    end
    if m == 2
        titles = {'$|z_{x}| (non-despiked G)$','$|z_{y}| (non-despiked G)$','$|z_{x}|$','$|z_{y}|$'};
        files = {'zx_notdespiked','zy_notdespiked','zx','zy'};
        units = ' [A/nT]';
        sf = 1;
        for j = 1:length(Opts)
            V{j} = Opts{j}.GB_avg;
        end
        cols = [3,4];    
    end
    if m == 3
        titles = {'$|Z_{xx}|$','$|Z_{xy}|$','$|Z_{yx}|$','$|Z_{yy}|$'};
        files = {'Zxx','Zxy','Zyx','Zyy'};
        units = ' [(mV/km)/nT]';
        sf = 1;
        for j = 1:length(Opts)
            V{j} = Opts{j}.EB_avg;
        end
        cols = [1:4];        
    end

    for i = cols
        fn=fn+1;figure(fn);clf;

        % Plot Z using Mean method for all options
        for j = 1:length(Opts)
            loglog(T,sf*V{j}.Mean.Zabs(2:end,i),'LineStyle','-','LineWidth',1);
            hold on;grid on;axis tight;
        end

        fns = fieldnames(V{1});
        for f = 1:length(fns)
            T = 1./V{1}.(fns{f}).fe(2:end);
            loglog(T,sf*abs(V{1}.(fns{f}).Z(2:end,i)),'LineStyle','--','LineWidth',1);
            leglabels2{f} = fns{f};
        end

        legend(cat(2,leglabels1,leglabels2),'Location','Best');
          
        % Error bars only shown for first options set.
        errorbars(T,...
                  sf*V{1}.Mean.Zabs(2:end,i),...
                  2*sf*V{1}.Mean.Zabs_StdErr(2:end,i),...
                  2*sf*V{1}.Mean.Zabs_StdErr(2:end,i),'y',c(1));
              
        vlines(1./V{1}.Mean.fe(2));
        
        title([titles{i},units],'FontWeight','normal');
        set(gca,'XLim',[3,7e4]);
        exponent_relabel(gca,'x');
        xlabel('Period [s]');

        
        if png
            figsave(sprintf('%s/plot_options_comparison_%s.pdf',fdir,files{i}));
        end
    end
end       