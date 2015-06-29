YEARS       = [1990:1994]';
[XLabels,I] = month_labels(YEARS);


K        = [1:6:length(I)];
I        = I(K); % Keep every 4th month
XLabels  = XLabels(K,:);
break
eglobpar2;
einit2;
eopen2('./month_labels_demo.eps'); % open eps-file and write eps-head

eaxes2(I,XLabels,[0:10],[]); 
eplot2([1:I(end)],10*[1:I(end)]/I(end),'a',0,[1 0 0]);
eplot2;
eclose2;
