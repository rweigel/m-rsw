function [B,dB,E,start] = prepareData(short, agency)

s = dbstack;
n = s(1).name;

if strmatch('IRIS', agency)
    if length(strmatch('MBB05', short)) == 0
        fname = sprintf('data/iris/%s/%s-cleaned.mat',short,short);
    else
        % First month with data on all days.
        start = '2008-08-05';
        stop  = '2008-09-06';
        fname = sprintf('data/iris/MBB05_%s_%s.mat',start,stop);
        if ~exist(fname)
            % Instrument information: http://www.iris.washington.edu/mda/EM/MBB05
            sta   = 'MBB05';
            chas  = {'LFE','LFN','LFZ','LQE','LQN'};
            mainPrepareIRIS(sta,start,stop,chas);
        end
    end
    load(fname);
    B = D(:,1:3); % in T
    E = D(:,4:5); % in V/m - see, e.g., header of data/iris/MBB05/MBB05_LQE_2009-05-24.txt
    dB = diff(B);
    dB = [dB;dB(end,:)];
end

if strcmp('obibmt',short)
    if ~exist('data/Pierre','dir')
        fprintf('%s: Directory data/Pierre required. See Google Drive/Presentations/2015-SANSA.\n',n);
    end
    load('data/Pierre/Data/MT/Obib/Obib_MT_20130706141500.mat')

end
if strcmp('obibdm',short)
    if ~exist('data/Pierre','dir')
        fprintf('%s: Directory data/Pierre required. See Google Drive/Presentation/2015-SANSA.\n',n);
    end
    load('data/Pierre/Data/MT/Obib/Obib_DM_20130706110300.mat')

end
if strcmp('obibdm',short) || strcmp('obibmt',short)
    for i = 1:3
        B(:,i) = B(:,i) - mean(B(:,i));
    end
    Nd = ceil(size(B,1)/86400)*86400;
    Np = Nd - size(B,1);
    if (Np > 0) && (Np < 0.2*86400)
        fprintf('%s: Padding time series by %d points (to get full day).\n',n,Np);
    end
    Bp = repmat(B(end,:),Np,1);
    Ep = repmat(E(end,:),Np,1);
    B = [B;Bp];
    E = [E;Ep];

    dBi = diff(B);
    dBi = [dBi;dBi(end,:)];
    Bi = B;
    Ei = E;
    return
end
