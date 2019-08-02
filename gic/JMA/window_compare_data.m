function [tE,E,B,datakey] = window_compare_data(interval,site,regen,showplot,codever)

% To add a new interval, add new cell array element with start and stop
% dates. Then set showplot = 0 and use zoom to find intervals which should
% be interpolated over.
%
% Example: main_data(15,'mmb',1,1);

remote = 'kak';

if nargin < 3
    regen = 0;
end
if nargin < 4
    showplot = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S{1} = struct();
S{1}.dateo = '20031030';
S{1}.datef = '20031101';

S{2} = struct();
S{2}.dateo = '20031029';
S{2}.datef = '20031031';
% Note that the differences between Kelbert 2017 and what is found here for CC
% in Ex for 2003-10-29 through 2003-10-31 is probably due to the fact that
% Ex is clipped in the data from JMA. She must have used different data.
% Her PE table is definitely wrong. PEs should be lower than CC.

S{3} = struct();
S{3}.dateo = '20031030';
S{3}.datef = '20031031';

S{4} = struct();
S{4}.dateo = '20031108';
S{4}.datef = '20031113';

S{5} = struct();
S{5}.dateo = '20031110';
S{5}.datef = '20031118';

% Matches Fujii
S{6} = struct();
S{6}.dateo = '20031202';
S{6}.datef = '20031222';
S{6}.IbE = [1.487153e+06:1.488627e+06];

S{7} = struct();
S{7}.dateo = '20041202';
S{7}.datef = '20041231';
S{7}.IbE = [1.668208e+06:1.670850e+06];

% Matches Fujii
S{8} = struct();
S{8}.dateo = '20051202';
S{8}.datef = '20051227';
S{8}.IbE = [1051358:1052475,1570893:1571885];
S{8}.IbB = [1389888:1390322];

% Does not match Fujii
S{9} = struct();
S{9}.dateo = '20060106';
S{9}.datef = '20060131';
S{9}.IbE = [457658:457682,871643:872792,1159462:1167084,458258:458280];
S{9}.IbB = [957879:958349,881469:888762,881177:889435];
%,1157529:1171710
% Does not match Fujii
% Consider this interval leaving spike in. Here robust full fails, but
% stack is better.
S{10} = struct();
S{10}.dateo = '20060203';
S{10}.datef = '20060228';
S{10}.IbE = [9.64944e+05:9.66299e+05];

S{11} = struct();
S{11}.dateo = '20060302';
S{11}.datef = '20060331';
S{11}.IbE = [1.663546e+06:1.664708e+06];

S{12} = struct();
S{12}.dateo = '20060403';
S{12}.datef = '20060430';
S{12}.IbE = [882227:882233,1323746:1324585,1402202:1403151];

S{13} = struct();
S{13}.dateo = '20060502';
S{13}.datef = '20060530';

S{14} = struct();
S{14}.dateo = '20091212';
S{14}.datef = '20091231';
S{14}.IbB = [1.398600e+06:1.413476e+06,1.400477e+06:1.402522e+06];
S{14}.IbE = [626661:627765,634832:641330];

S{15} = struct();
S{15}.dateo = '20121102';
S{15}.datef = '20121129';
S{15}.IbB = [102703:103857];
S{15}.IbE = [782268:782287,783491:783495];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dateo = S{interval}.dateo;
datef = S{interval}.datef;

[tE,E,tB,B] = prep_EB(dateo,datef,site,regen,codever);
%[tEr,Er,tBr,Br] = prep_EB(dateo,datef,remote,regen);

if isfield(S{interval},'IbB')
    IbB = S{interval}.IbB;
    B(IbB,:) = NaN;
    Ig = setdiff([1:size(B,1)],IbB);
    for i = 1:size(B,2)
        B(:,i) = interp1(tB(Ig),B(Ig,i),tB);
    end
end

if isfield(S{interval},'IbE')
    IbE = S{interval}.IbE;
    E(IbE,:) = NaN;
    Ig = setdiff([1:size(E,1)],IbE);
    for i = 1:size(E,2)
        E(:,i) = interp1(tE(Ig),E(Ig,i),tE);
    end
end

if showplot
    figure(1);clf;
        plot(tB,B);
        datetick('x','dd');
        legend('Bx','By','Bz');
        zoom off;
        hB = zoom(gca);
        hB.ActionPreCallback = @(obj,evd) fprintf('');
        hB.ActionPostCallback = @(obj,evd) fprintf('Showing B([%d:%d],:)\n',...
            round((evd.Axes.XLim-tB(1))*86400));
    figure(2);clf;
        plot(tE,E);
        datetick('x','dd');
        legend('Ex','Ey');
        zoom off;
        hB = zoom(gca);
        hB.ActionPreCallback = @(obj,evd) fprintf('');
        hB.ActionPostCallback = @(obj,evd) fprintf('Showing E([%d:%d],:)\n',...
            round((evd.Axes.XLim-tE(1))*86400));
end

datakey = [S{interval}.dateo,'-',S{interval}.datef];

