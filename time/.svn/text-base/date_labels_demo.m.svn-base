
%[XLabels,I] = date_labels([1:11],[10:-2:1],[2004,1,1])
%[XLabels,I] = date_labels([1:11],[1:1:11],[2004,1,1])
[XLabels,I] = date_labels([1:11],[1:2:11],[2004,1,1])
[XLabels,I] = date_labels([1:3:11],[1:2:11],[2004,1,1])

eglobpar2;
einit2;
eopen2('./date_labels_demo.eps'); % open eps-file and write eps-head

eaxes2(I,XLabels,[1:10],[]); 
eplot2([1:11],[1:11]','a',0,[1 0 0]);
eplot2;
eclose2;

