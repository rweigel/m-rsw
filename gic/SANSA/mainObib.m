clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
longu  = 'Obib Under Wire';
shortu = 'obibdm';
start  = '06-Jul-2013 11:03:00';
iu = 3600*3+12*60;

longo  = 'Obib 100m Over from Wire';
shorto = 'obibmt';

start  = '06-Jul-2013 14:15:00';
%tit   = sprintf('%s MT (%s)',long,upper(short));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels  = {'B_x','B_y','B_z','dB_x/dt','dB_y/dt','dB_z/dt','E_x','E_y'};
labels2 = {'B_x','B_y','B_z','dBxdt','dBydt','Bzdt','E_x','E_y'};
xlab    = ['Days since ',start];
cs      = ['r','g','b','r','g','b','m','k'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Under wire
[Bu,dBu,Eu,Tu] = mainPrepare(shortu);
Bu = Bu(iu:end,:);

% Over from wire
[Bo,dBo,Eo,To] = mainPrepare(shorto);

Bu = Bu(1:size(Bo,1),:);

figure(1);clf
	plot(Bo(:,1),'r');hold on;grid on;
	plot(To(:,1))
	plot(Bu(:,1),'b');
	plot(Tu(:,1))
	plot(Bu(:,1)-Bo(:,1),'k')
	legend('Bx 100m over','Bx under','\Delta B_x')

figure(2);clf
	plot(Bo(:,2),'r');hold on;grid on;
	plot(Bu(:,2),'b');
	plot(Bu(:,2)-Bo(:,2),'k')
	legend('By 100m over','By under','\Delta B_y')

figure(3);clf
	plot(-Bu(:,1)+Bo(:,1),'m');
	hold on;grid on;
	plot(Bu(:,2)-Bo(:,2),'g')
	legend('\Delta B_x','\Delta B_y')

figure(4);
	plot(Tu,'r');
	hold on;grid on;
	plot(To,'g');

