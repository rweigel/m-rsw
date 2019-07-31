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

if exist('angle_correlations.log')
    delete('angle_correlations.log');
end
diary('angle_correlations.log');

Ns = [864,86400];
for j = 1:length(Ns)
    N = Ns(j);
    Np = 35*86400/N;
    
    Exr = reshape(Ex,N,length(Ex)/N);
    Eyr = reshape(Ey,N,length(Ey)/N);
    Gr  = reshape(G,N,length(G)/N);

    clear ang aobo sG sEx sEy aE mE
    for i = 1:size(Exr,2)
        Exr(:,i) = Exr(:,i) - mean(Exr(:,i));
        Eyr(:,i) = Eyr(:,i) - mean(Eyr(:,i));    
        Gr(:,i) = Gr(:,i) - mean(Gr(:,i));
        %[aobo(1:2,i),~,~,~,stats] = regress(Gr(:,i),[Exr(:,i),Eyr(:,i)]);
        %r2(1,i) = stats(1);
        [aobo(1:2,i)] = regress(Gr(:,i),[Exr(:,i),Eyr(:,i)]);
        ang(1,i) = sf*atan2(aobo(1,i),aobo(2,i));
        sG(1,i) = std(Gr(:,i));
        sEx(1,i) = std(Exr(:,i));
        sEy(1,i) = std(Eyr(:,i));
        mE(1,i) = mean(Exr(:,i).^2 + Eyr(:,i).^2);
        aE(1,i) = mean(sf*atan2(Exr(:,i),Eyr(:,i)));
    end
    fprintf('Number of ao, bo pairs = %d\n',Np);
    fprintf('  cc(ang,std(G)) = %.2f\n',cc(ang',sG'));
    fprintf('  cc(ang,std(Ex)) = %.2f\n',cc(ang',sEx'));
    fprintf('  cc(ang,std(Ey)) = %.2f\n',cc(ang',sEy'));
    fprintf('  cc(ang,|E|) = %.2f\n',cc(ang',mE'));
    fprintf('  cc(ang,angle E) = %.2f\n',cc(ang',aE'));
    fprintf('--\n');

end
diary off
