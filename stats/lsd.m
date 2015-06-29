function m = lsd(x,y,win)
%LSD Log spectral distance
%
%  m = LSD(A,P), where A is actual and P is predicted

if (size(x,2) == 2)  
  if (nargin < 3)
    win = size(x,1);
  end
  xr1 = reshape(x(:,1),win,size(x,1)/win);
  xr2 = reshape(x(:,2),win,size(x,1)/win);
  yr1 = reshape(y(:,1),win,size(y,1)/win);
  yr2 = reshape(y(:,2),win,size(y,1)/win);

  xr1f = fft(xr1);
  xr2f = fft(xr2);
  yr1f = fft(yr1);
  yr2f = fft(yr2);
  
  num = (xr1f.*conj(xr1f)) + sqrt(xr2f.*conj(xr2f));
  den = (yr1f.*conj(yr1f)) + sqrt(yr2f.*conj(yr2f));
else
  if (nargin < 3)
    win = length(x);
  end
  xr = reshape(x,win,length(x)/win);
  yr = reshape(y,win,length(y)/win);
  xrf = fft(xr);
  yrf = fft(yr);
  num = (xrf.*conj(xrf));
  den = (yrf.*conj(yrf));
end

m = sqrt(sum( (log(num./den)).^2 ,1)/win);
m = mean(m);



  
  