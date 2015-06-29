function Cs = zplanewave(s,h,f)
%ZPLANEWAVE 1-D surface impedance for plane wave incidenct on half space.
%
%   C = ZPLANEWAVE(s,h,f)
%   
%   Surface impedence at positive frequencies f above layered
%   conductors with conductivities s, thicknesses h, and geometry
%
%   Conductivity    Thickness
%
%   0               Inf
%   --------------------------  Surface
%   s(1)            h(1)
%   --------------------------
%   s(2)            h(2)
%   --------------------------
%   .
%   .
%   .
%   --------------------------
%   s(end-1)        h(end)
%   --------------------------  Top of bottom layer
%   s(end)          Inf
%
%   Computed using Eqns. 2.33 and 2.34 of Simpson and Bahr,
%   Practical Magnetotellurics, 2005 (Eqn. 2.33 is recursion
%   formula from Wait 1954).  All layers have vaccum permeability.
%
%   For an infinite half-layer with s(1) = s0, h = [], and f(1) = f0,
%       C = zplanewave(s,h,f)
%   returns
%       C = 1/q, where
%       q = sqrt(mu_0*s0*2*pi*f0)*(1+i)/sqrt(2)
%
%   See also
%       ZPLANEWAVE_TEST - Verify calculations
%       ZPLANEWAVE_DEMO1 - Plot transfer fn, phase, and impulse response
%       ZPLANEWAVE_DEMO2 - Compare IRFs computed in time and frequency domain

% R.S. Weigel, 04/09/2015

% Code assumes f is vector with columns
if size(f,1) > size(f,2)
    f = f';
end

if size(f,1) > 1 && size(f,2) > 1
    error('frequency must me an array');
end
if length(s) ~= (length(h) + 1)
  error('length(s) should be equal to length(h) + 1');
end
if any(f < 0)
  error('Frequencies must be positive');
end;

nl        = length(s);      % Number of layers  
mu_0      = 4*pi*1e-7;      % Vacuum permeability

% Columns of C are frequencies.  Compute C at top of bottom layer.
    
% Eqn. 2.34 of Simpson and Bahr
q(nl,:) = sqrt(j*mu_0*s(nl)*2*pi*f);
C(nl,:) = 1./q(nl,:);

% Compute C(nl-1) given C(nl), C(nl-2) given C(nl-1), etc.
% (Eqn. 2.33 of Simpson and Bahr)
for l = nl-1:-1:1
    q(l,:) = sqrt(j*mu_0*s(l)*2*pi*f);  % Eqn. 2.28
    C(l,:) = (1./q(l,:)).*( q(l,:).*C(l+1,:) + tanh(q(l,:)*h(l)) ) ...
                        ./ (1 + q(l,:).*C(l+1,:).*tanh(q(l,:)*h(l)));
end

% Surface impedance.
Cs = C(1,:);

% Return Z having same shape as f.
if (size(f,1) > size(f,2))
    Cs = Cs';
end
