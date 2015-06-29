function unscale_demo(OPT)
%UNSCALE_DEMO Demo of scaling and unscaling operations.
%
%  UNSCALE_DEMO(OPT) Where OPT = 1,2,3,4,5, or 6 corresponding to options in
%  SCALE and UNSCALE.
%

if (nargin < 1)  
  OPT = 1;
end  

disp('Inital Matrix')
A      = rand(3,3)

if (OPT == 1)
disp('Scale to [-1 1]')
disp('[As,S] = scale(A)')
[As,S] = scale(A)
disp('Unscale')
disp('A = unscale(As,S)')
A      = unscale(As,S)
disp('Scale again using pre-defined scale factor')
disp('As     = scale(A,1,S)')
As     = scale(A,1,S)
end

if (OPT == 2)
disp('Scale to zero mean, unit std')
disp('[As,S] = scale(A,2)')
[As,S] = scale(A,2)
disp('Unscale')
disp('A = unscale(As,S,2)')
A      = unscale(As,S,2)
disp('Scale again using pre-defined scale factor')
As = scale(A,2,S)
end

if (OPT == 3)
disp('Scale by log10')
disp('[As,S] = scale(A,3)')
A      = abs(A) + eps;
[As,S] = scale(A,3)
disp('Unscale')
disp('A = unscale(As,S,3)')
A      = unscale(As,S,3)
disp('Scale again using pre-defined scale factor')
As     = scale(A,3,S)
end

if (OPT == 4)
disp('Scale to [0,1]')
[As,S] = scale(A,4)
disp('Unscale')
disp('A = unscale(As,S,4)')
A      = unscale(As,S,4)
disp('Scale again using pre-defined scale factor')
As     = scale(A,4,S)
end

if (OPT == 5)
disp('Scale to [0,1] with zero min, 1 max')
[As,S] = scale(A,5)
disp('Unscale')
disp('A = unscale(As,S,5)')
A      = unscale(As,S,5)
disp('Scale again using pre-defined scale factor')
As     = scale(A,5,S)
end

if (OPT == 6)
disp('Subtract off min and scale by standard dev.')
[As,S] = scale(A,6)
disp('Unscale')
disp('A = unscale(As,S,6)')
A      = unscale(As,S,6)
disp('Scale again using pre-defined scale factor')
As     = scale(A,6,S)
end

if (0)
disp('Scale to zero mean, unit std and then scale to [-1,1]')
[A1,S1] = scale(A,2)
[A2,S2] = scale(A1,1)
disp('Unscale')
disp('A1 = unscale(A2,S2,1)')
A1      = unscale(A2,S2,1)
disp('A  = unscale(A1,S1,2)')
A       = unscale(A1,S1,2)
end

