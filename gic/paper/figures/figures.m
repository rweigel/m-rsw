% Authors should size based on layout and readability. The following are standard sizing options in AGU journals:
% 1/4 page figure = 95 mm x 115 mm
% 1/2 page figure  = 190 mm x 115 mm (horizontal); 95 mm x 230 mm (vertical)
% Full page = 190 mm x 230 mm
set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultAxesFontName','TimesNewRoman','defaultTextFontName','TimesNewRoman');

figure(1)
  plot(1,1,'r.','MarkerSize',30);
  title('190 x 230');
  xlabel('x');
  ylabel('y');
  grid on;
  pbaspect([1,230/190,1])
  print -depsc figure1.eps

figure(2)
  plot(1,1,'r.','MarkerSize',30);
  title('230 x 85');
  xlabel('x');
  ylabel('y');
  grid on;
  pbaspect([230/95,1,1])
  print -depsc figure2.eps

figure(3)
  plot(1,1,'r.','MarkerSize',30);
  title('115 x 190');
  xlabel('x');
  ylabel('y');
  grid on;
  pbaspect([1,190/115,1])
  print -depsc figure3.eps
