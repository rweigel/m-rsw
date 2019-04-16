% Result is not compelling - Result using mean when 3 segments are used
% has PE of about 0.1 when mean of three segments is used to predict three
% segments. Out-of-sample will probably be closer to zero.

clear;

site = 'mmb';
opts = main_options(1);

for interval = 10:10
    
    [t,E,B,datakey] = main_data(interval,site);

    fname = sprintf('./mat/%s_%s.mat',upper(site),datakey); % Save file name

    [E,B] = removemean(E,B);
    
    [tw,D] = weather();
    D = removemean(D);
    
end

Di = interp1(tw,D,t);
I = find(~isnan(Di(:,1)));
Di = Di(I,:);
E = E(I,:);
B = B(I,:);
t = t(I);

opts = main_options(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
desc = 'Robust + Parzen Full';
opts.td.window.width = size(B,1);
opts.td.window.shift = size(B,1);
opts.fd.regression.method = 3;
opts.description = desc;
opts.fd.window.function = @parzenwin; 
opts.fd.window.functionstr = 'parzen';

Sc{1} = transferfnFD(B(:,1:2,1),E,opts);
fe{1} = Sc{1}.fe;
Z{1} = Sc{1}.Z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Er = Sc{1}.Out-Sc{1}.Predicted;

opts.td.window.width = size(Er,1);
opts.td.window.shift = size(Er,1);
Sc{2} = transferfnFD(Di(:,1:2),Er,opts);
fe{2} = Sc{2}.fe;
Z{2} = Sc{2}.Z;

%Sc{3} = transferfnFD(Di(:,3:4),Er,opts);
%fe{3} = Sc{3}.fe;
%Z{3} = Sc{3}.Z;

desc = 'OLS Stack';
opts.td.window.width = 86400*4*2;
opts.td.window.shift = 86400*4*2;
opts.fd.regression.method = 1;
Sc{4} = transferfnFD(Di(:,[1,3]),Er,opts);
    Sa{4} = transferfnAverage(Sc{4},opts);
    transferfnSummary(Sc{4},Sa{4},desc);

figprep(1,1200,600);

figure(1);clf;
subplot(2,1,1)
    plot(t,Di(:,1:3));
    title('Mean-subtracted Measurements at Okadama Airport, Japan');
    legend('Temperature [C$^{o}$]','Dew Point [C$^{o}$]','Humidity [\%]');
    datetick('x','dd');
    xlabel('February, 2006');
subplot(2,1,2)
    plot(t,Er(:,1),'r');
    hold on;
    plot(t,Sc{2}.Predicted(:,1),'b');
    legend('MMB $E_x$ Prediction Error','Prediction of MMB $E_x$ Prediction Error');
    datetick('x','dd');
    xlabel('February, 2006');
    ylabel('[mV/m]');
drawnow;


