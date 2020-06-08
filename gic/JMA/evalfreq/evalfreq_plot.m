function evalfreq_plot(N,varargin)
%EVALFREQ_PLOT
%
%   [fe,Ic,Ne] = evalfreq_plot(...) takes the same inputs as EVALFREQ(),
%   returns the same outputs, and creates a plot showing the frequencies.
%
%   See also EVALFREQ, EVALFREQ_LOG.

if nargin > 1
    [fe,Ic,Ne] = evalfreq(N,varargin{:});
else
    %[fe,Ic,Ne] = evalfreq_new(N);
    %[fe,Ic,Ne] = evalfreq([0:N/2]'/N);
    [fe,Ic,Ne] = evalfreq(N);
end

[~,f] = fftfreq(N);

[fe,Ne,Ic] = evalfreq(N);

f = [0:N/2]'/N; % Assumes N is even.

if 1
    fprintf(' i     N    fl      fe       fh\n');
    for i = 2:length(fe)
        fprintf('%2d %5d %6.2e %6.2e %6.2e\n',i,2*Ne(i)+1,f(Ic(i)-Ne(i)),fe(i),f(Ic(i)+Ne(i)));
    end
end

logscale = 0;
if isempty(varargin) | (length(varargin) > 1 & strcmp('logarithmic',varargin{2}))
    logscale = 1;
end

figure(1);clf;grid on;box on;hold on;
for i = 2:length(fe)
    Np = 2*Ne(i)+1;
    fprintf('%2d %5d %6.2e %6.2e %6.2e\n',i,2*Ne(i)+1,f(Ic(i)-Ne(i)),fe(i),f(Ic(i)+Ne(i)));    
    fs = f(Ic(i)-Ne(i):Ic(i)+Ne(i));
    fa{i} = fs;
    if logscale
        % Shift duplicates a small amount vertically.
        if i > 1 && Ne(i) == Ne(i-1)
            Np = Np + i/20;
        end
        y = Np*ones(size(fs));
        plot(fs,y,'go');
        plot(fs,y,'k-');
        plot(fe(i),Np,'k.','MarkerSize',20);
    else
        y = i*ones(size(fs));        
        plot(fs,y,'go');
        plot(fs,y,'k-');        
        plot(fe(i),i,'k.','MarkerSize',20);
    end
end
d = setdiff(f,cat(2,fa{:}));
plot(d,length(d)*ones(size(d)),'g.');
legend('DFT frequencies','Window','Center Frequency','Location','SouthEast');
if logscale
    set(gca,'XScale','log');
    set(gca,'YScale','log');
    title('(overlapping windows shifted vertically)');
    ylabel('\# of DFT points associated with Window');
else
    set(gca,'YTickLabel',[])
    set(gca,'YTick',[])
end