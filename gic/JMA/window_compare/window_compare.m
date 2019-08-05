clear

interval = 8;
site = 'mmb';
regen = 0;
codever = 1;

% When using a new interval, use showplot = 1 and uncomment break. Then
% use zoom to find indices of data values to set to NaN and update
% window_compare_data.m.
showplot = 0;
[t,E,B,datakey] = window_compare_data(interval,site,regen,showplot,codever);
% break

dateo = datestr(t(1),'yyyy-mm-dd');
datef = datestr(t(end),'yyyy-mm-dd');

diary(sprintf('log/window_compare_%s-%s-v%d.log',dateo,datef,codever));

if size(B,1)/86400 > 27
    B = B(1:27*86400,:);
    E = E(1:27*86400,:);
    t = t(1:27*86400);
end

[E,B] = removemean(E,B);

opts = main_options(1);
a = opts.td.Ntrim;
b = size(B,1)-a; 

[Nf,fef] = smoothSpectra(E(a:b,:));
comp = ['x','y'];

d = 0;
for v = [1,9,27]
    d = d+1;
    W(d) = v;
    opts.td.window.width = 86400*v;
    opts.td.window.shift = 86400*v;
    opts.fd.regression.method = 3;
    opts.td.pad = 0;
    opts.fd.window.function = @parzenwin; 
    opts.fd.window.functionstr = 'parzen';

    m = 1;
        methods{m} = 'Robust';
        Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
        if size(Sc{d,m}.In,3) > 1
            Sa{d,m} = transferfnAverage(Sc{d,m},opts);
            transferfnSummary(Sc{d,m},Sa{d,m},methods{m});
            Z{d,m} = Sa{d,m}.Mean.Z;
            fe{d,m} = Sa{d,m}.Mean.fe;
        else
            Z{d,m} = Sc{d,m}.Z;
            fe{d,m} = Sc{d,m}.fe;
        end

    if 1
        m = 2;
            methods{m} = 'Robust No Stack';
            Sc{d,m} = transferfnFD2(Sc{d,1},opts);
                Z{d,m} = Sc{d,m}.Robust1.Z;
                fe{d,m} = Sc{d,m}.Robust1.fe;

        m = 3;
            methods{m} = 'Robust Pad';
            opts.td.pad = 86400*v;
            Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
            if size(Sc{d,m}.In,3) > 1
                Sa{d,m} = transferfnAverage(Sc{d,m},opts);
                transferfnSummary(Sc{d,m},Sa{d,m},methods{m});
                Z{d,m} = Sa{d,m}.Mean.Z;
                fe{d,m} = Sa{d,m}.Mean.fe;
            else
                Z{d,3} = Sc{d,3}.Z;
                fe{d,3} = Sc{d,3}.fe;
            end

        m = 4;
            methods{m} = 'Robust 10/decade';
            opts.td.pad = 0;
            opts.fd.evalfreqN = 10;
            Sc{d,m} = transferfnFD(B(:,1:2,1),E,opts);
            if size(Sc{d,m}.In,3) > 1
                Sa{d,m} = transferfnAverage(Sc{d,m},opts);
                transferfnSummary(Sc{d,m},Sa{d,m},methods{1});
                Z{d,m} = Sa{d,m}.Mean.Z;
                fe{d,m} = Sa{d,m}.Mean.fe;
            else
                Z{d,m} = Sc{d,m}.Z;
                fe{d,m} = Sc{d,m}.fe;
            end
    end

    % Get padding for fprintf.
    for m = 1:length(methods)
        L(m) = length(methods{m});
    end
    mL = max(L);
    for m = 1:length(methods)
        pad{m} = repmat(' ',1, mL - length(methods{m}));
    end

    In = Sc{1,1}.In;
    Out = Sc{1,1}.Out;
    as = 600;
    bs = size(In,1)-as;
    %Z{1,1}(19,:) = Z{4,1}(29,:);
    for i = 1:size(Z,2) % Loop over methods
        for s = 1:size(Sc{1,1}.In,3) % Loop over segments
            [Ns,fes] = smoothSpectra(Out(as:bs,:,s));
            Eps{d,i} = Zpredict(fe{d,i},Z{d,i},In(:,:,s));
            sns(:,:,s) = Ns./smoothSpectra(Out(as:bs,:,s)-Eps{d,i}(as:bs,:));
        end
        SNs{d,i} = mean(sns, 3);
    end 

    for i = 1:size(Z,2) % Loop over methods
        Ep{d,i} = Zpredict(fe{d,i},Z{d,i},B(:,1:2));
        SNf{d,i} = Nf./smoothSpectra(E(a:b,:)-Ep{d,i}(a:b,:));
        M{d,i}(1,:) = pe(E(a:b,:),Ep{d,i}(a:b,:));
        M{d,i}(2,:) = cc(E(a:b,:),Ep{d,i}(a:b,:));
        M{d,i}(3,:) = mse(E(a:b,:),Ep{d,i}(a:b,:));
        for j = 1:2
            LL{d,i,j} = sprintf('%s %sw = %d; PE/CC/MSE = %.2f/%.2f/%.2f',...
                methods{i},pad{m},W(d),M{d,i}(:,j)'); 
            fprintf('%s %s\n',comp(j),LL{d,i,j});
        end
    end
end


if 0
    % Use optimization to adjust parameter value
    for d = 1:1
        z = Z{1,1};
        z(19,:) = Z{4,1}(31,:);
        for i = 1:size(Z,2) % Loop over methods
            for s = 1:size(Sc{1,1}.In,3) % Loop over segments
                [Ns,fes] = smoothSpectra(Out(as:bs,:,s));
                Eps{d,i} = Zpredict(fe{d,i},z,In(:,:,s));
                sns(:,:,s) = Ns./smoothSpectra(Out(as:bs,:,s)-Eps{d,i}(as:bs,:));
            end
            SNs{d,i} = mean(sns, 3);
            SNs{d,i}(19,:)
        end 
    end

    po = fminsearch(@(p) sncalc(p,Z{1,1},fe{1,1},In,Out),[1,1,1,1]);

    Z{1,1}(19,3) = po(1)*real(Z{1,1}(19,3)) + po(2)*sqrt(-1)*imag(Z{1,1}(19,3));
    Z{1,1}(19,4) = po(3)*real(Z{1,1}(19,4)) + po(4)*sqrt(-1)*imag(Z{1,1}(19,4));
end

fprintf('________________________________\n');
for j = 1:2
    for i = 1:size(Z,2) % Loop over methods
        for d = 1:size(SNf,1)
            fprintf('%s %s%s\n',comp(j),pad{i},LL{d,i,j});
        end
    end
end

diary off;
window_compare_plot