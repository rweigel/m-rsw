function [ah,ch] = spectrogram_plot(x,T,P,aib,d_o,left,T1,P1,StartDay,ppd,dt)
%SPECTROGRAM_PLOT
%
%   Horizontal green lines mark the periods. When w is small, they won't be
%   centered on the colored patches because of how computation for patch
%   boundary is performed.  Need to address this by
%   (1) For Nw = 1, explicitly compute boundaries
%   (2) For Nw > 1, deal with overlapping boundaries   

a = 1;
b = length(x);

if (size(P,1) ~= size(T,1)) || (size(P,2) ~= size(d_o,2))
  whos P T d_o
  error('P, T, and d_o must have consistent dimensions');
end

orient tall;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('ppd')
  ppd = 1;
end
if ~exist('dt')
  dt = 1;
end
xl = [a-0.5,b+0.5];
if exist('StartDay')
  if (length(StartDay) == 1)
    StartDay = [StartDay,1,1];
  end
  Ndays = dt*round(length(x)/ppd);
  if (Ndays > 366)
    [XLabels,I] = year_labels(Ndays,StartDay,3);
    XTick = I-doy(StartDay)+1;
    if (XTick(1) < 1)
      XTick = XTick(2:end);
      XLabels = XLabels(2:end,:);
    end
    if length(XTick) > 10
      XLabels = XLabels(:,3:4);
      for i = 2:2:size(XLabels,1)
        XLabels(i,:) = blanks(2);
      end
    end
    if (ppd > 1)
      XTick = (XTick-1)*ppd;
    end
  else
    [XLabels,I] = month_labels(StartDay(1),[1,1+number_days(StartDay(1))],3);
    XTick = I;
    for i = 2:size(XLabels,1)-1
      tmpXLabels(i,:) = [' ',XLabels(i,:)];
    end
    tmpXLabels(1,:)     = num2str(StartDay(1));
    tmpXLabels(end+1,:) = num2str(StartDay(1)+1);
    XLabels = tmpXLabels;
    xl = [1,1+number_days(StartDay(1))];
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,1)

  if (length(d_o) == length(x))
    plot(d_o,x);
  else
    plot(x);
  end
  hold on;grid on;
  if (length(d_o) < 20)
    plot(d_o,x,'.','MarkerSize',5)
  end
  if exist('StartDay')
    set(gca(),'XTick',XTick);
  end
  set(gca(),'XTickLabel','');
  xlim(xl);

  grid on;set(gca(),'XTickLabel','');
  p1 = [0.10 0.68 0.84 0.280];
  set(gca(),'Position',p1);

  ah(1) = gca();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,2)
  thresh = 3;
  for i = 1:size(P,1)
    % Ilow = find(P(i,:) < thresh);
    % P(i,Ilow) = NaN;
  end
  
  for j = 1:size(P,2)
      P(:,j) = P(:,j)/max(P(:,j));
  end
  
  pcolor2(d_o,T,P);hold on;

  p2 = [0.10 0.38 0.84 0.280];
  set(gca(),'Position',p2);

  colormap(gca(),jet(10));
  ch(1) = colorbar;

  if (length(d_o) > 20) || length(T) > 10
    set(get(gca(),'Children'),'EdgeColor','none');
  end

  if exist('StartDay')
    set(gca(),'XTick',XTick);
  end

  ylabel('T');
  xlim(xl);
  set(gca(),'XTickLabel','');

  if (length(T) < 10)
    for z = 1:length(T)
      plot([xl(1),xl(end)],[T(z),T(z)],'LineWidth',0.5,'Color','g');hold on;
    end
  end
  grid on;
  set(gca,'Layer','top');
  
%  set(get(ch(1),'Title'),'String',sprintf('I/I_o'));
%  set(get(ch(1),'Title'),'Rotation',-90)
  ylabel(ch(1),'I/I_o')
  %set(get(ch(1),'Title'),'String','I/Io')
  set(ch(1),'YTick',[0:0.1:1.0])
  tmp = get(ch(1),'YLim');

  % Plot PSD computed using full time series
  if (nargin > 6)
    plot((d_o(end)-d_o(1))*0.25*scale(P1,1),T1);
  end

  ah(2) = gca();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if (0)
subplot(3,1,3)

  dphase = phaseogram(T,aib,left);
  for i = 1:size(dphase,1)
    %  Ilow = find(P(i,:) < thresh);
    %  dphase(i,Ilow) = NaN;
  end

  pcolor2(d_o,T,dphase);hold on;

  p3 = [0.10 0.08 0.84 0.280];
  set(gca(),'Position',p3);

  %freezeColors; % Does not work for painters
  colormap(gca(),jet(10));
  ch(2) = colorbar;

  if (length(d_o) > 20) || length(T) > 10
    set(get(gca(),'Children'),'EdgeColor','none');
  end

  ylabel('T');
  xlim(xl);
  
  if (length(T) < 10)
    for z = 1:length(T)
      plot([xl(1),xl(end)],[T(z),T(z)],'k','LineWidth',0.5,'Color','g');
      hold on;
    end
  end

  if exist('StartDay')
    set(gca(),'XTick',XTick);
    set(gca(),'XTickLabel',XLabels);
  end
  grid on;

  %set(gca,'Layer','top')
  %set(get(ch(2),'Title'),'String','\phi [deg]')
  ylabel(ch(2),'\phi [deg]')
  %set(get(ch(2),'Title'),'Rotation',-90)
  %set(get(ch(2),'Title'),'Position',[5.5 (tmp(end)-tmp(1))/2 1])
  set(ch(2),'YLim',[0,360])
  set(ch(2),'YTick',[0:40:360])
  %set(ch(2),'YTick',[0:60:360])
  tmp = get(ch(2),'YLim');

  ah(3) = gca();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%end

% Move right boundary of plots without a colorbar to match those
% with a colorbar
for i = 1:length(ah)
  p(i,:) = get(ah(i),'Position');
end
mw = min(p(:,3));
for i = 1:length(ah)
  pnew = p(i,:);
  pnew(1,3) = mw;
  set(ah(i),'Position',pnew);
end
