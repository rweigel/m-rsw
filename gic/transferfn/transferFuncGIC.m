function [Z,w] = transferFuncGIC(GIC,X,Y,a,b,winLen,dt,nFreq,varargin)
%TRANSFERFUNCGIC	Estimate the transfer function between GIC and the magnetic field using a robust scheme.
%
%	[Z,W] = TRANSFERFUNCGIC(GIC,X,Y,A,B,WINLEN,DT,NFREQ) ...
%
%	References:
%
%	Eisel and Egbert, On the stability of magnetotelluric transfer function estimates and on the reliability
%	of their variances, Geophys. J. Int., 144, 65-82, 2001.

%	Antti Pulkkinen, November 2006.

%% SETTINGS OF THE COMPUTATIONS ----- For notation, see Eisel and Egbert (2001).

% Tolerance.
tol = 1;
% Number of "hard" cut-off iterations.
hardIter = 1;
% The n0 used in the loss function.
n0 = 1.5;
% The n1 used in the hard cut-off iterations.
n1 = 2.8;

%% END SETTINGS ------------------

% Default values.
silentPlot = 0;
% Bootstrap mode. The number of iterations.
bootstrap = 0;
% The maximum number of points to be used in each iteration (to keep the weight matrix size managable).
maxNoOfPoints = 3000;
% Maximum iterations.
maxIter = 5;

% Parse the input.
for ii = 1:2:length(varargin),
	switch varargin{ii},
		case 'silentPlot'
			silentPlot = varargin{ii+1};
		case 'bootstrap'
			bootstrap = varargin{ii+1};	
		case 'maxNoOfPoints'
			maxNoOfPoints = varargin{ii+1};	
		case 'maxIter'
			maxIter = varargin{ii+1};	
   		otherwise
			ttext = sprintf('   TRANSFERFUNCGIC: NO SUCH OPTION AS %s',varargin{ii});
			disp(ttext);
	end;
end;

% Fourier tranformation for windows of the raw data. Use the default overlap (50 %).
[tfGIC,ftf,ttf] = spectrogram(GIC,tukeywin(winLen/dt,.2),[],[],1/dt);
[tfX,ftf,ttf] = spectrogram(X,tukeywin(winLen/dt,.2),[],[],1/dt);
[tfY,ftf,ttf] = spectrogram(Y,tukeywin(winLen/dt,.2),[],[],1/dt);

%% Pre-whiten the signals ------

disp('   TRANSFERFUNCGIC: Pre-whitening the signals...');  

% First, design the filter.
[bFilt,aFilt] = yulewalk(10,ftf.'/ftf(end),1./mean(abs(tfX.')));

% And then filter the data. Use the same filter for all signals. 
GICprew = filter(bFilt,aFilt,GIC);
Xprew = filter(bFilt,aFilt,X);
Yprew = filter(bFilt,aFilt,Y);

%% End prewhitening.

% Fourier tranformation for windows of the processed data. Use the default overlap (50 %).
[tfGICprew,ftf,ttf] = spectrogram(GICprew,tukeywin(winLen/dt,.2),[],[],1/dt);
[tfXprew,ftf,ttf] = spectrogram(Xprew,tukeywin(winLen/dt,.2),[],[],1/dt);
[tfYprew,ftf,ttf] = spectrogram(Yprew,tukeywin(winLen/dt,.2),[],[],1/dt);

% Natural constant.
mu0 = 4*pi*1e-7;
		
% A robust solution of the overdetermined linear system A = B*Z. Using (partially) the notation in Eisel and Egbert (2001).

% First determine frequencies to be solved. Ignore the zero-frequency.
fSolveBin = logspace(log10(min(ftf(2:end))),log10(max(ftf(2:end))),nFreq+1);		

% The angular frequencies of the bin centers.
fSolve = fSolveBin(1:end-1) + diff(fSolveBin)/2;
w = 2*pi.*fSolve;

% Initialize the impedance matrix.
if bootstrap,
	Z = NaN*ones(bootstrap,length(w));
else
	Z = NaN*ones(1,length(w));
end;

% Loop over frequency bins.
for ii = 1:length(fSolveBin)-1,

	% Display the progress.
	disp(sprintf('   TRANSFERFUNCGIC: Treating frequency %01.0f/%01.0f...',ii,length(fSolve)));

	% Find the data in the frequency bins.
	kkBin = find(ftf >= fSolveBin(ii) & ftf <= fSolveBin(ii+1));
	
	% Determine how many times the bootstrap (on/off) loop is executed.
	if bootstrap,
		noBootStep = bootstrap;
	else
		noBootStep = 1;
	end;
	
	% Loop over (possible) bootstrap.
	for bb = 1:noBootStep,
			
		% If not data in the bin, jump to the next one.
		if ~isempty(kkBin),
			
			% The model matrix.
			help = (a*tfYprew(kkBin,:) - b*tfXprew(kkBin,:))/(mu0*1e9);
			B = help(:);
			% The data matrix.
			help = tfGICprew(kkBin,:);
			A = help(:);
						
			% Length of the data.
			I = length(A);
					
			% Check if the acceptable number of points is exceeded.  
			if I > maxNoOfPoints,
				% Take a random sample. Note that this part is automatically in a bootstrap mode.
				newInd = ceil(length(A)*rand(1,maxNoOfPoints));
				A = A(newInd);
				B = B(newInd);
				% New length of the data vector.
				I = length(A);
			elseif bootstrap,
				% If the bootstrap mode is on, random sample all frequencies independent of the number of data points.
				newInd = ceil(I*rand(1,I));
				A = A(newInd);
				B = B(newInd);
			end;
				
			% Initial solution using the QR decomposition.
			Ziter = A\B;
	            
			% Iterate until the conditions for the convergence are met or no. of max. iter. are done.
			counter = 1;
			while counter <= maxIter,
						
				% Compute the residuals.
				n = A - Ziter*B;
				
				% The absolute value of the residual component.
				absn = abs(n);
				
				% Check if the tolerance is met.
				if  sum(absn) < tol,
					break;
				end;
				
				% Initialize weights.
				wt = ones(1,I);
				
				% Determine the weights. Switch between regular soft and hard cut-off weights.
				if counter > (maxIter - hardIter),
					% "Hard" cut-off iteration.
					kkWeight = find(absn > n1); wt(kkWeight) = 0;
				else
					% "Soft" cut-off iteration.
					kkWeight = find(absn > n1); wt(kkWeight) = n0/absn(kkWeight);
				end;
											
				% The weight matrix.
				W = diag(wt);
				
				% New iteration. Essentially weighted LSQ.
				Ziter = inv(B'*W*B)*(B'*W*A);
	
				% Add to the counter.
				counter = counter + 1;
		
			end;
			
			% The final solution for the corresponding frequency.
			Z(bb,ii) = Ziter;
					
		% if ~isempty(kkBin)
		end;		
	% for bb = 1:(bootstrap)+1
	end;
%for ii = 1:length(fSolveBin)-1
end;





