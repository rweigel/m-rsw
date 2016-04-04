function [Z,f,Hi,tg] = H2Z(te,H,tg,verbose)

if nargin < 4
  verbose = 0;
end

if (size(te,1) ~= size(H,1))
  te = te';
end
if (size(te,1) ~= size(tg,1))
  tg = tg';
end

dointerp = true;
if nargin == 3 && (length(te) == length(tg))
  if all(te == tg)
    warning('all(te == tg) returned true.  No interpolation will be performed.');
    dointerp = false;
  end
end

if verbose
  fprintf('First time value : %.4f\n',tg(2));
  fprintf('First grid time  : %.4f\n',te(2));
  fprintf('Last time value  : %.4f\n',te(end));
  fprintf('Last grid time   : %.4f\n',tg(end));
end

if dointerp
  for k = 1:size(H,2)
    % Interpolate onto time grid
    Hio(:,k) = interp1(te,H(:,k),tg);
    Hi(:,k) = Hio(:,k);
    % Set NaN values to zero
    I = find(isnan(Hi(:,k)));
    if (length(I) > 0)
      fprintf('Setting %d value(s) to zero in H(:,%d)\n',length(I),k);
    end
    Z(:,k) = fft(H(:,k));
  end
else
  Iz  = [];
  Hi  = H;
  Hio = H;
end

N = size(H,1);
Z = Z(1:floor(N/2)+1,:);
f = [0:N/2]'/N;
