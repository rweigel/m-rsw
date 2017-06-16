function negloglogabs(x,n,xlabel,xlabelfactors,c)
    
    Ip = find(abs(x)>0);    
  loglog(-x(In),n(In),'.','Color',c,'MarkerSize',20);
  grid on;
  grid minor;
  hold on;
  set(gca,'XDir','reverse');  
  ylabel('# in bin');
  x1 = get(gca,'XLim');
  y1 = get(gca,'YLim');

xmx = max(abs(x));   
xlm = [0.1,xmx];
ylm = [1,max(n)];

subplot(1,2,1)
  set(gca,'XLim',xlm);
  set(gca,'YLim',ylm);
  xl = get(gca,'XTickLabel');
  xl = cellstr(xl);
  for i = 1:length(xl)
      if ~strcmp(xl{i}(1),'-')
	  xl{i} = ['-',xl{i}];
      end
  end
  %set(gca,'XTickLabel',xl);
  % Need to guess factors
  text(xlabelfactors(1)*xlm(1),xlabelfactors(2)*ylm(1),xlabel);
subplot(1,2,2)
  grid on;
  grid minor;
  set(gca,'XLim',xlm);
  set(gca,'YLim',ylm);
