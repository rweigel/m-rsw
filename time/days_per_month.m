function N = days_per_month(i,Y)
%DAYS_PER_MONTH Returns no. of days per month given month number and year.
%
%   N = days_per_month(M,Y), where M and Y can be scalars or vectors.
%       If M is a vector and Y is a scalar, all values of M are assumed
%       to fall in year Y.
% 
%   See also NUMBER_DAYS.

  
if (min(size(Y))>1 | min(size(i))>1)
  error('i and Y must be row or column vectors')
end

if (length(i) > 1) & (length(Y) == 1)
  Y = repmat(Y,size(i));
end

if (max(i) > 12)
  error('Month values greater than 12 are not allowed');
end

Flip = 0;
if (size(Y,2)>1 | size(i,2)>1)
  Y    = Y';
  i    = i';
  Flip = 1;
end

N_days      = [31,28,31,30,31,30,31,31,30,31,30,31]';
N_days      = repmat(N_days,1,length(Y));
SHIFT       = is_leap_year(Y);
N_days(2,:) = N_days(2,:) + SHIFT';
J           = sub2ind(size(N_days),i,[1:length(Y)]');
N           = N_days(J);

if (Flip)
  N = N';
end
