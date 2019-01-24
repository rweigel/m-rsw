L = 64;
f = [0:L/2]'/L;

[fe,Ne,Ic] = evalfreq(f,'logarithmic',0,1);

f
[fe,Ne,f(Ic)]

figure();
clf;
    plot(log2(fe),0*fe,'ko');hold on;
    plot(log2(f),0*f,'g.');
    xlabel('Frequency');
    title(sprintf('L = %d',L))

    for i = 1:length(fe)
        plot(log2(f(Ic(i)-Ne(i):Ic(i)+Ne(i))),parzenwin(2*Ne(i)+1),'k-','Marker','.','MarkerSize',5);
    end
    legend('Evaluation Frequencies','Actual Frequencies','Weight');
    plot(log2(fe),ones(length(fe),1),'ko');hold on;

break

figure();
clf;
    plot(fe,0*fe,'ko');hold on;
    plot(f,0*f,'g.');
    xlabel('Frequency');
    title(sprintf('L = %d',L))

    for i = 1:length(fe)
        plot(f(Ic(i)-Ne(i):Ic(i)+Ne(i)),parzenwin(2*Ne(i)+1),'k-','Marker','.','MarkerSize',5);
    end
    legend('Evaluation Frequencies','Actual Frequencies','Weight');
    plot(fe,ones(length(fe),1),'ko');hold on;

figure();clf;
    semilogx(fe,0*fe,'ko');hold on;
    plot(fe,ones(length(fe),1),'ko');hold on;
    semilogx(f,0*f,'g.');
    xlabel('Frequency');
    title(sprintf('L = %d',L))

    for i = 1:length(fe)
        semilogx(f(Ic(i)-Ne(i):Ic(i)+Ne(i)),parzenwin(2*Ne(i)+1),'k-','Marker','.','MarkerSize',5);
    end
    legend('Evaluation Frequencies','Actual Frequencies','Weight');
    
figure();
clf;
    semilogx(1./fe,0*fe,'ko');hold on;
    semilogx(1./f,0*f,'g.');
    semilogx(1./fe,ones(length(fe),1),'ko');hold on;
    legend('Evaluation Periods','Actual Periods');
    xlabel('Period');
    title(sprintf('L = %d',L))

    for i = 1:length(fe)
        semilogx(1./f(Ic(i)-Ne(i):Ic(i)+Ne(i)),parzenwin(2*Ne(i)+1),'k-','Marker','.','MarkerSize',5);
    end
    legend('Evaluation Periods','Actual Periods','Weight');

figure();clf;
    plot(1./fe,0*fe,'ko');hold on;
    plot(1./f,0*f,'g.');
    xlabel('Period');
    title(sprintf('L = %d',L))
    legend('Evaluation Periods','Actual Periods');

    for i = 1:length(fe)
        plot(1./f(Ic(i)-Ne(i):Ic(i)+Ne(i)),parzenwin(2*Ne(i)+1),'k-','Marker','.','MarkerSize',5);
    end
    legend('Evaluation Frequencies','Actual Frequencies','Weight');
