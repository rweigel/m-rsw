function [B,dB,E,dn] = prepareData(short, agency)

s = dbstack;
n = s(1).name;

if strcmp('JMA', agency)
    base   = 'data/jma';
    bname2 = sprintf('%s/%s/Bfile2.mat',base,short);
    ename2 = sprintf('%s/%s/Efile2.mat',base,short);
    load(bname2)
    load(ename2)
    start = '2006-12-01 00:00:00';
    dno = datenum(start);
    dn = dno + [0:size(B,1)-1]'/86400;
end    

if strcmp('IRIS', agency)
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
  if ~exist('data-private/Pierre','dir')
    fprintf('%s: Directory data/Pierre required.\n',n);
    return;
  end
end

if strcmp('SANSA', agency)
    if strcmp('obibmt',short)
	load('data-private/Pierre/Data/MT/Obib/Obib_MT_20130706141500.mat')
    end
    if strcmp('obibdm',short)
	load('data-private/Pierre/Data/MT/Obib/Obib_DM_20130706110300.mat')
    end

    if strcmp('grassridge',short)
	B = [];
	base = 'data-private/Pierre/Data/Geomagnetic/';
	for i = 1:3
	    sprintf('%s/HER200310%d.dat',base,28+i);
	    fid = fopen(sprintf('%s/HER200310%d.dat',base,28+i),'r');
	    s = fscanf(fid,'%c');
	    I = strfind(s,'2003');
	    s = s(I(2):end);
	    B = [B;str2num(s)];
	end
	%B = load('data/supermag/HER-2003-10-29_2003-11-01.txt');
	tB = datenum(B(:,1:5));
	B = B(:,7:9);

	E = [];
	tE = [];
	base = 'data-private/Pierre/Data/GIC data/2003-10-29-Grassridge';
	for i = 1:3
	    fid = fopen(sprintf('%s/grass_200310%d_neutral.csv',base,28+i),'r');
	    s = fscanf(fid,'%c');
	    I = strfind(s,'2003');
	    s = s(I(1):end);
	    s = regexprep(s,'/|:',',');
	    E = [E;str2num(s)];
	end
	tE = datenum(E(:,1:6));
	E = E(:,end);
	E = mean(reshape(E,30,length(E)/30),1)';
	E = [E,E];
	tE = mean(reshape(tE,30,length(tE)/30),1)';	
    	for i = 1:3
	    B(:,i) = B(:,i) - nanmean(B(:,i));
	end
	for i = 1:2
	    E(:,i) = E(:,i) - nanmean(E(:,i));
	end
	dB = diff(B);
	dB = [dB;dB(end,:)];
	dn = tB;
    end

    if strcmp('obibdm',short) || strcmp('obibmt',short)
	for i = 1:3
	    B(:,i) = B(:,i) - nanmean(B(:,i));
	end
	for i = 1:2
	    E(:,i) = E(:,i) - nanmean(E(:,i));
	end
	Nd = ceil(size(B,1)/86400)*86400;
	Np = Nd - size(B,1);
	if (Np > 0) && (Np < 0.2*86400)
	    fprintf('%s: Padding time series by %d pts (to get full day).\n',...
		    n,Np);
	end
	Bp = repmat(B(end,:),Np,1);
	Ep = repmat(E(end,:),Np,1);
	%B  = [B;Bp];
	%E  = [E;Ep];
	dB = diff(B);
	dB = [dB;dB(end,:)];
	dn = time;
	return
    end
end