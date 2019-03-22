function [fe,Ic,Ne] = evalfreq2(N,Npd)

    f = [0:N/2]'/N;

    Nd = log10(1/4)-log10(2/N); % Number of decades

    % Nominal evaluation frequencies. Could allow fl and fu to be given
    % as opposed to assumed.
    fen = logspace(log10(2/N),log10(1/4),round(Nd*Npd))';
    %fen = logspace(log10(2/L),log10(1/4),3)';

    % fea will be array of evaluation frequencies that are also actual
    % frequencies. (Needed so that when windowing is used, the same
    % number to left and right of eval freq are used).
    fea = [f(2);fen;f(end)];
    for i = 1:length(fea)
        [~,Ic(i,1)] = min(abs(f-fea(i)));
    end
    fea = f(Ic);
    % Actual evaluation frequencies fea are now equal to an actual
    % frequency.

    % Compute number of points to left and right to use for window.
    % Window will be symmetric in linear space (if asymmetric window is
    % used, one would need to change location of evaluation frequencies
    % to be at center of window).
    for i = 2:length(fea)-1
        Il = find(f >= fea(i-1),1); % Find frequency nearest above or equal to previous eval freq.
        Iu = Ic(i)+(Ic(i)-Il); % Upper frequency is determined by how many frequencies below were used.
        fe(i-1,1) = fea(i);
        flims(i-1,:) = [f(Il),f(Iu)];
        N(i-1,1) = (Iu(1)-Il(end))/2;
    end
    Ic = Ic(2:end-1);

    fe = [0;fe];
    Ic = [1;Ic];
    Ne  = [0;N];
    [fe,Iu] = unique(fe);
    Ic = Ic(Iu);
    Ne = Ne(Iu);
    return;

    %[fe,flims,N]

    %[feo,No,Ico] = evalfreq(L);

    %[fe,feo]
    %[N,No]
    %[Ic,Ico]
