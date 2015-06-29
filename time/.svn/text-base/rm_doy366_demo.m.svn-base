Npd = 24;
T   = [1:Npd*364]';
Tn  = rm_doy366(T,1980,Npd);
length(Tn)
length(T)

Npd = 24;
T   = [1:Npd*366,1:Npd*365,1:Npd*365,1:Npd*365,1:Npd*366]';
Tn  = rm_doy366(T,1980,Npd);
length(Tn)
length(T)
I = find(Tn==365*Npd+1)

T  = [1:366,1:365,1:365,1:365,1:366]';
Tn = rm_doy366(T,1980);
length(Tn)
length(T)
I = find(Tn==366)

T  = [1:365,1:365,1:365,1:366]';
Tn = rm_doy366(T,1981);
length(Tn)
length(T)
I = find(Tn==366)

Npd = 24;
T   = [1:Npd*365,1:Npd*365,1:Npd*365,1:Npd*366]';
Tn  = rm_doy366(T,1981,Npd);
length(Tn)
length(T)
I = find(Tn==365*Npd+1)


