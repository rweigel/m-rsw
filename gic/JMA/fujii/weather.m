function [t,D] = weather()

fid = fopen('weather-2006-02.txt','r');

k = 1;
while 1
    line = fgetl(fid);
    if line == -1
        break;
    end
    if length(line) > 0 && ~strcmp('#',line(1))
        L = strsplit(line);
        D(k,1) = str2double(L{3});
        D(k,2) = str2double(L{5});
        D(k,3) = str2double(L{7});
        D(k,4) = str2double(L{10});
        D(k,5) = str2double(L{12});
        D(k,6) = str2double(L{14});
        D(k,7) = str2double(L{16});
        D(k,8) = str2double(L{18});
        k = k+1;
    end
end

t = datenum('2006-02-01');
t = t + [0:size(D,1)-1]'/8;
fclose(fid);