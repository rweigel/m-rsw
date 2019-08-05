function evalfreq_table()
    N = 86400;

    [fe,Ne,Ic] = evalfreq(N);

    f = [0:N/2]'/N; % Assumes N is even.

    ss = '\\';
    caption = '';
    
    if 1
        fprintf(' i     N    fl      fe       fh\n');
        for i = 2:length(fe)
            fprintf('%2d %5d %6.2e %6.2e %6.2e\n',i,2*Ne(i)+1,f(Ic(i)-Ne(i)),fe(i),f(Ic(i)+Ne(i)));
        end
        return
    end
    
    fprintf('\\begin{table}\n');
    fprintf('\\caption{%s}\n',caption);
    fprintf('\\centering\n');
    fprintf('\\begin{tabular}{l l l l l}\n');
    fprintf('\\hline %s\n',ss);
    fprintf('\\# & $N$ & $T_e$ [s] & $T_l$ [s] & $T_h$ [s] %s\n',ss);
    fprintf('\\hline %s\n',ss);
    for i = 2:length(fe)
        Th = 1/f(Ic(i)-Ne(i));
        Thfmt = fmtstr(Th);

        Tl = 1/f(Ic(i)+Ne(i));
        Tlfmt = fmtstr(Tl);

        Te = 1/fe(i);
        Tefmt = fmtstr(Te);

        fprintf(['%d & %d & ',Tefmt,' & ',Tlfmt,' & ',Thfmt,' %s\n'],i-1,2*Ne(i)+1,Te,Tl,Th,ss);
    end
    fprintf('\\hline %s\n',ss);
    fprintf('\\end{tabular}\n');
    fprintf('\\label{evaluationperiods}\n');
    fprintf('\\end{table}\n');
end

function fmt = fmtstr(x)
    if round(x) == x
        fmt = '%d';
    else
        fmt = '%.1f';
    end
end
