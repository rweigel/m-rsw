clear;
load('../mat/main_options-1-v1-o0.mat','GE','GE_avg','GEo');

d = 3; % Day
sf = (180/pi);

Ex = [];
Ey = [];
G  = [];
for d = 1:size(GE.In,3)
    Ex = [Ex;GE.In(:,1,d)];
    Ey = [Ey;GE.In(:,2,d)];
    G  = [G;GE.Out(:,2,d)];
end

N = 86400; % Values used in paper. Gives approximately ao = 72, bo = -72.
N = 864;
Ns = [864,86400];
for j = 1:length(Ns)
    clear aobo ang
    N = Ns(j);
    
    % Reshape to seach column is interval to be used to compute ao and bo.
    Exr = reshape(Ex,N,length(Ex)/N);
    Eyr = reshape(Ey,N,length(Ey)/N);
    Gr  = reshape(G,N,length(G)/N);

    for i = 1:size(Exr,2)
        Exr(:,i) = Exr(:,i) - mean(Exr(:,i));
        Eyr(:,i) = Eyr(:,i) - mean(Eyr(:,i));    
        Gr(:,i) = Gr(:,i) - mean(Gr(:,i));
        aobo(1:2,i) = regress(Gr(:,i),[Exr(:,i),Eyr(:,i)]);
    end
    aos = aobo(1,:);
    bos = aobo(2,:);
    angs = sf*atan2(aos,bos);
    mao = mean(aos);
    mbo = mean(bos);
    ma1  = mean(angs);
    ma2  = sf*atan2(mao,mbo);
    Nb = 10;
    if N == 86400
        Nb = 100;
    end
    Np = 35*86400/N; % Number of ao,bo pairs computed
    figure(j);clf;
    
        subplot(3,1,1);
            hist(aos,Nb);
            ts = sprintf('Number of ao, bo pairs = %d',Np);
            title(ts,'FontWeight','normal');
            ylabel('\# in bin');
            xlabel('$a_o$');
            ts = sprintf('N = %d; $\\overline{a}_o$ = %.2f',...
                N, mao);
        subplot(3,1,2);
            hist(bos,Nb);
            ylabel('\# in bin');
            xlabel('$b_o$');
            ts = sprintf('N = %d; $\\overline{b}_o$ = %.2f',...
                N, mao, mbo);
        subplot(3,1,3)
            hist(angs,Nb);
            ylabel('\# in bin');            
            xlabel('$\alpha$')
            legend('$\alpha$ = $\mbox{atan2}(a_o, b_o)$');
            ts = sprintf('$\\overline{\\alpha}$ = %.2f and %.2f',...
                ma1, ma2);
            title(ts,'FontWeight','normal');
        fname = sprintf('aobo_angle_sensitivity_Npairs_%d.pdf',Np);
        print('-dpdf',fname);

end



