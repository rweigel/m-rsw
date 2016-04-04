function [B,dB,E,dn] = prepareData(short, agency)

s = dbstack;
n = s(1).name;

if strmatch('IRIS', agency)
  if length(strmatch('MBB05', short)) == 0
    fname = sprintf('data/iris/%s/data/%s-counts-cleaned.mat',short,short);
  else
    % First month with data on all days.
    start = '2008-08-05';
    stop  = '2008-09-06';
    fname = sprintf('data/iris/MBB05_%s_%s.mat',start,stop);
    if ~exist(fname)
      sta   = 'MBB05';
      chas  = {'LFE','LFN','LFZ','LQE','LQN'};
      mainPrepareIRIS(sta,start,stop,chas);
    end
  end
  load(fname);
  B = D(:,1:3); % in counts
  E = D(:,4:5); % in counts
  dB = diff(B);
  dB = [dB;dB(end,:)];
  
  t   = [0:size(B,1)-1]'/86400;
  dn  = datenum(start) + t;
end

if strcmp('obibmt',short) ||  strcmp('obibdm',short)
  if ~exist('data/Pierre','dir')
    fprintf('%s: Directory data/Pierre required.\n',n);
    fprintf('See Google Drive/Presentations/2015-SANSA.\n');
    return;
  end
end

if strcmp('obibmt',short)
  load('data/Pierre/Data/MT/Obib/Obib_MT_20130706141500.mat')
end
if strcmp('obibdm',short)
    load('data/Pierre/Data/MT/Obib/Obib_DM_20130706110300.mat')
end
if strcmp('obibdm',short) || strcmp('obibmt',short)
    for i = 1:3
        B(:,i) = B(:,i) - mean(B(:,i));
    end
    Nd = ceil(size(B,1)/86400)*86400;
    Np = Nd - size(B,1);
    if (Np > 0) && (Np < 0.2*86400)
        fprintf('%s: Padding time series by %d points (to get full day).\n',...
		n,Np);
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
