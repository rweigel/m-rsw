function mainPrepareIRIS(sta,start,stop,chas)

startdn = datenum(start);
stopdn  = datenum(stop);

D = [];
for i = startdn:stopdn
    for j = 1:length(chas)
        ds = datestr(i,29);
        fname = sprintf('data/iris/%s/%s_%s_%s.mat',sta,sta,chas{j},ds);

        % TODO: If ~exist(fname), create fill day.

        fprintf('Reading %s. ',fname);
        load(fname);

        % Second of day + 1
        t = 1 + X(:,4)*60*60+X(:,5)*60+X(:,6);
        % Data
        d = X(:,7);
        % Fill array
        di = repmat(NaN,86400,1);
        ti = [0:86400-1]';
        % Replace fill with valid points.
        di(t) = d;
        fprintf('%d values.\n',length(t));
        tmp(:,j) = di;

        if (0)
        if (i <= startdn + 1)
            url0 = 'http://service.iris.edu/irisws/timeseries/1/query?net=EM&';
            url1 = 'sta=%s&loc=--&cha=%s&correct=true&starttime=%sT00:00:00&endtime=%sT23:59:59&output=plot';
            url = sprintf([url0,url1],sta,chas{j},ds,ds);

            % Plot first two days for checking with source.
            plot(tmp(:,j));
            legend(chas{j});
            xlabel(sprintf('Seconds since %s',datestr(startdn,30)));
            grid on;
            fname = sprintf('data/iris/%s/%s_%s_%s.png',sta,sta,chas{j},ds);
            print('-dpng',fname);
            fprintf('  Wrote %s.\n  Compare with %s\n',fname,url)
        end
        end
    end
    D = [D;tmp];
end
fname = sprintf('data/iris/MBB05_%s_%s.mat',start,stop);
save(fname,'D');
fprintf('Wrote %s.\n',fname);

return

dD = diff(D);
dD = [dD;dD(end,:)];

figure(1)
    subplot(2,1,1)
        plot(D(:,1));
        title(chas{1});
    subplot(2,1,2)
        plot(dD(:,1));

