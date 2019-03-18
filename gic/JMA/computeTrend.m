function [GICt,Et,Bt,GICa,Ea,Ba] = computeTrend(GIC,E,B,station,dateos,datefs)

    GICall = [];
    Ball = [];
    Eall = [];

    regenfiles = 0;
    
    for i = 1:length(dateos)
        dateo = dateos{i};
        datef = datefs{i};

        % Read 1s E and B data from Kyoto
        [tE,E,tB,B] = prep_EB(dateo,datef,station,regenfiles); 

        % Read GIC data from Watari
        % First column is raw, second is 1 Hz filtered.
        if ~isempty(GIC)
            [tGIC,GIC]  = prep_GIC(dateo,datef,regenfiles);        
        end

        E    = despikeE(E);

        if ~isempty(GIC)
            GICd = despikeGIC(GIC(:,2)); % Despike 1 Hz filtered column
            GIC  = [GIC(:,2),GICd];      % Keep 1 Hz filtered column and despiked column
            GICall = [GICall;GIC];
        end

        Eall = [Eall;E];
        Ball = [Ball;B];
    end

    if ~isempty(GIC)
        [GICt,GICa] = dailyTrend(GICall);
    else
        GICt = [];
        GICa = [];
    end
    [Et,Ea] = dailyTrend(Eall);
    [Bt,Ba] = dailyTrend(Ball);

end

function [Xt,Xa] = dailyTrend(X,ppd)
    %DAILYTREND - Quiet day baseline trend in multi-day time series

    if nargin < 2
        ppd = 86400;
    end

    for i = 1:size(X,2)

        % Reshape multi-day time series into matrix with columns of days
        Xr = reshape(X(:,i),ppd,size(X,1)/ppd);

        % Keep (days) columns with low standard deviations.
        [s,I] = sort(std(Xr,0,1));
        Xr = Xr(:,I(1:floor(end/4)));

        % Average across days
        Xa(:,i) = mean(Xr,2);

        fftXa = fft(Xa(:,i));
        fftXa(8:end-6) = 0; % Remove high frequency components

        % Trend time series
        Xt(:,i) = real(ifft(fftXa));
    end

end