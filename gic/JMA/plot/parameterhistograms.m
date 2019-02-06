function parameterhistograms(GEo,GEoavg,filestr,png)

    fn = 0;
    figprep(png,1000,500);

    fn=fn+1;figure(fn);clf;box on;grid on;hold on;

        edgesao = [0:20:180]';
        edgesbo = [-300:50:100]';

        [nao,xao] = histc(1e3*squeeze(GEo.ao(1,2,:)),edgesao);
        [nbo,xbo] = histc(1e3*squeeze(GEo.bo(1,2,:)),edgesbo);

        edgesao = [edgesao(1);edgesao];
        nao = [0;nao];
        edgesbo = [edgesbo(1);edgesbo];
        nbo = [0;nbo];

        stairs(edgesao,nao,'k','LineWidth',2)
        stairs(edgesbo,nbo,'k--','LineWidth',2)

        plot(1e3*GEoavg.ao(2),0,'k.','MarkerSize',30);
        plot(1e3*GEoavg.bo(2),0,'ko','MarkerSize',7);

        set(gca,'XLim',[-320,200])
        set(gca,'XTick',[-300:50:200]);
        set(gca,'YTick',[0:9]);
        ylabel('Count');
        xlabel('A/(V/km)');
        [lh,lo] = legend({'$a_o$','$b_o$','$\overline{a}_o$','$\overline{b}_o$'},'Interpreter','latex');

        if png
            figsave(sprintf('figures/combined/plot_model_summary_aobo_histograms-%s.pdf',filestr));
        end
end