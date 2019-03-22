function S = transferfnFD(B,E,opts,t)
%function [Z,fe,H,t,Ep] = transferfnFD(B,E,opts)
%TRANSFERFNFD Estimates transfer function
%
%  Estimates the complex-valued transfer function Z(f) in
%
%  E(f) = Z(f)B(f) or E(f) = Zx(f)Bx(f) + Zy(f)By(f)
%
%  where f is frequency.
%
%  S = transferfnFD(B,E,opts) where E is a 1-column time series and
%  B is a 1- or 2-column time series.
%
%  S = transferfnFD(B,E,opts,t)
%
%  Methods:
%
%  Compute Z in E = ZB or E = ZxBx + ZyBy
%    method 1: Uses closed-form equations
%    method 2: Uses regress()
%    method 3: Uses robustfit()
%
%  Compute Z = C^{-1} in B = CE
%    method 4: Uses closed-form equations
%    method 5: Uses regress()
%    method 6: Uses robustfit()
%
%  For method = 1, 2, and 3, solves one of (depending on # cols in E and B)
%
%  Ex = ZxxBx
%
%  Ex = ZxxBx + ZxyBy
%
%  Ex = ZxxBx + ZxyBy
%  Ey = ZyxBx + ZyyBy
% 
%  For methods 4,5,6, solves for Z by computing Z = C^{-1} with C computed
%  using one of (depending on # cols in E and B)
%
%  Bx = CxxEx
%
%  Bx = CxxEx + CxyEy can't be done and an error is thrown.
%
%  Bx = CxxEx + CxyEy
%  By = CyxEx + CyyEy

verbose = 0;

if nargin < 4
    t = [1:size(B,1)]';
end

if ~isnan(opts.td.window.width)
    Tw = opts.td.window.width;
    Ts = opts.td.window.shift;
    opts.td.window.width = NaN;
    opts.td.window.shift = NaN;
    Io = [1:Ts:size(B,1)-Tw+1];
    if Io(end) > size(B,1)
        Io = Io(1:end);
    end
    for i = 1:length(Io)
        Iseg = [Io(i):Io(i)+Tw-1];
        if isfield(opts.td,'pad') && opts.td.pad > 0
            Scell{i} = transferfnFD([B(Iseg,:,:);zeros(opts.td.pad,size(B,2))],[E(Iseg,:);zeros(opts.td.pad,size(E,2))],opts,t(Iseg));
        else
            Scell{i} = transferfnFD(B(Iseg,:,:),E(Iseg,:),opts,t(Iseg));
        end
        fprintf('transferfnFD.m: %d/%d PE/CC/MSE of In_x = %.2f/%.2f/%.3f\n',i,length(Io),Scell{i}.PE(1),Scell{i}.CC(1),Scell{i}.MSE(1));
        if size(E,2) > 1
            fprintf('transferfnFD.m: %d/%d PE/CC/MSE of In_y = %.2f/%.2f/%.3f\n',i,length(Io),Scell{i}.PE(2),Scell{i}.CC(2),Scell{i}.MSE(2));
        end
    end
    S = transferfnCombine(Scell);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in smoothSpectra()
N = size(B,1);
f = [0:N/2]'/N; % Assumes N is even.

if nargin > 2
    if strmatch(opts.fd.evalfreq.method,'linear','exact')
        [fe,Ne,Ic] = evalfreq(f,'linear',opts.fd.evalfreq.options);
    elseif strmatch(opts.fd.evalfreq.method,'logarithmic','exact')
        [fe,Ne,Ic] = evalfreq(f);
    else
        [fe,Ne,Ic] = evalfreq(f);
    end
end
if isfield(opts.fd,'evalfreqN')
    [fe,Ic,Ne] = evalfreq2(N,opts.fd.evalfreqN);
end

% End duplicated code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 2
    method = opts.fd.regression.method;
else
    method = 2;
end
if nargin > 2
    winfn = opts.fd.window.function;
else
    winfn = @parzenwin;
end

if size(B,2) == 1 && size(E,2) == 1
    if method <= 3
        % Ex = ZxBx
        % Case is handled by default.
    else
        % Bx = CxxEx
        opts.method.fd = opts.method.fd - 3;
        S = transferfnFD(E,B,opts,t);        
        Z = 1./C;
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);
        S.Z = Z;
        S.H = H;        
        [Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts);
        S = createStruct(Z,fe,H,t,Ep,f,E,B,S.E_FT,S.B_FT,S.Time);
        return;
    end
elseif size(B,2) == 2 && size(E,2) == 1
    if method <= 3
        % Ex = ZxBx + ZyBy
        % Case is handled by default.
    else
        % Bx = CxxEx + CxyEy does not make sense to request
        error('Method requires input and output to both have two columns.')
    end
elseif size(B,2) == 2 && size(E,2) == 2
    if method <= 3
        % Ex = ZxxBx + ZxyBy
        % Ey = ZyxBx + ZyyBy
        Sx = transferfnFD(B,E(:,1),opts,t);
        Sy = transferfnFD(B,E(:,2),opts,t);
        S = createStruct([Sx.Z,Sy.Z],Sx.fe,[Sx.H,Sx.H],Sx.t,...
            [Sx.Predicted,Sy.Predicted],E,B,Sx.F_FT,...
            [Sx.Out_FT,Sy.Out_FT],[Sx.In_FT,Sy.In_FT],Sx.Time);
        return;
    else
        % Bx = CxxEx + CxyEy
        % By = CyxEx + CyyEy
        opts.method.fd = opts.method.fd - 3;
        Sx = transferfnFD(E,B(:,1),opts,t);
        Sy = transferfnFD(E,B(:,2),opts,t);
        C = [Sx.Z,Sy.Z];
        
        % Compute Z = C^{-1}
        DET = C(:,1).*C(:,4)-C(:,2).*C(:,3);
        Z   = [C(:,4),-C(:,2),-C(:,3),C(:,1)]./repmat(DET,1,4);
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);

        [Ep(:,1),SEerr(:,1)] = calcErrors(Z(:,1:2),B,E(:,1),opts);
        [Ep(:,2),SEerr(:,2)] = calcErrors(Z(:,3:4),B,E(:,2),opts);        
        S = createStruct(Z,Sx.fe,H,Sx.t,Ep,Sx.F_FT,...
            [Sx.Out_FT,Sy.Out_FT],B,E,Sx.F_FT,[Sx.Out_FT,Sy.Out_FT],...
            [Sx.In_FT,Sy.In_FT],Sx.Time);
        return;
    end
else
    error('Invalid input/output dimensions.');
end

if nargin > 2 & strmatch(opts.td.prewhiten.method,'yulewalker','exact')
    [~,a,b] = prewhiten(B(:,1),opts.td.prewhiten.options);
    Ew = filter(b,a,E);
    Bw = filter(b,a,B);
else
    Bw = B;
    Ew = E;
end

ftB = fft(Bw(:,:,1));
ftE = fft(Ew);
ftB = ftB(1:N/2+1,:);
ftE = ftE(1:N/2+1,:);

% Remote reference
if size(Bw,3) > 1
    ftBr = fft(Bw(:,:,2));
else
    ftBr = ftB;
end


for j = 2:length(Ic)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Caution - code below is duplicated in smoothSpectra()
    W = winfn(2*Ne(j)+1);
    W = W/sum(W);
    
    r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];
    
    fa = f(Ic(j)-Ne(j));    
    fb = f(Ic(j)+Ne(j));
    % End duplicated code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if verbose
        fprintf('Window at f = %.8f has %d points; fl = %.8f fh = %.8f\n',...
                fe(j),length(r),fa,fb)
    end
    
    if method == 1
        if size(B,2) == 1
            % Ex = ZxxBx
            Z(j,1) = sum(W.*(ftE(r,1).*conj(ftB(r,1))))/sum(W.*(ftB(r,1).*conj(ftB(r,1))));
        else
            % OLS solution to Ex = ZxxBx + ZxyBy. Minimizes errors in Ex.
            BxBx(j) = sum(W.*(ftB(r,1).*conj(ftBr(r,1)))); 
            ByBy(j) = sum(W.*(ftB(r,2).*conj(ftBr(r,2)))); 
            
            ExEx(j) = sum(W.*(ftE(r,1).*conj(ftE(r,1))));

            BxBy(j) = sum(W.*(ftB(r,1).*conj(ftBr(r,2))));
            ByBx(j) = sum(W.*(ftB(r,2).*conj(ftBr(r,1))));

            ExBx(j) = sum(W.*(ftE(r,1).*conj(ftBr(r,1)))); 
            ExBy(j) = sum(W.*(ftE(r,1).*conj(ftBr(r,2)))); 

            BxEx(j) = sum(W.*(ftB(r,1).*conj(ftE(r,1)))); 

            DET =  BxBy(j)*ByBx(j) - BxBx(j)*ByBy(j);
            Zxx = (ExBy(j)*ByBx(j) - ExBx(j)*ByBy(j))/DET;
            Zxy = (ExBx(j)*BxBy(j) - ExBy(j)*BxBx(j))/DET;
            Z(j,:) = [Zxx,Zxy];
        end
    end

    W = sqrt(W);
    Wr = repmat(W,1,size(B,2));
    E_FT{j,1} = W.*ftE(r,1);
    B_FT{j,1} = Wr.*ftB(r,:);
    F_FT{j,1} = f(r);
    
    if method == 2
        % Same as method 1 except uses MATLAB's regress function.
        Z(j,:) = regress(W.*ftE(r,1),Wr.*ftB(r,:));
    end

    if 0 && j > 15
        Er_act = real(W.*ftE(r,1));
        Ei_act = real(W.*ftE(r,1));

        Z_rob(j,:) = robustfit(Wr.*ftB(r,:),W.*ftE(r,1),'cauchy',[],'off');        
        Er_rob = real(Wr.*ftB(r,:)*Z_rob(j,:).');
        Ei_rob = imag(Wr.*ftB(r,:)*Z_rob(j,:).');

        Z_ols(j,:) = regress(W.*ftE(r,1),Wr.*ftB(r,:));
        Er_ols = real(Wr.*ftB(r,:)*Z_ols(j,:).');
        Ei_ols = imag(Wr.*ftB(r,:)*Z_ols(j,:).');

        keyboard
        
        figure();
            plot(Er_act,Er_rob,'r.','MarkerSize',20);
            hold on;
            plot(Er_act,Er_ols,'b.','MarkerSize',10);
        figure()
            qqplot(Er_act-Er_rob);
            hold on;
            qqplot(Er_act-Er_ols);
        keyboard
    end
    
    if method == 3
        % Same as method 1 except using MATLAB's robustfit function.
        if size(W,1) < 5
            Z(j,:) = regress(W.*ftE(r,1),Wr.*ftB(r,:));
        else
            Z(j,:) = robustfit(Wr.*ftB(r,:),W.*ftE(r,1),[],[],'off');
        end
    end

end

H = Z2H(fe,Z,f);
H = fftshift(H,1);
n = (size(H,1)-1)/2;
tH = [-n:n]';

Ep = real(Zpredict(fe,Z,B));

S = createStruct(Z,fe,H,tH,Ep,E,B,F_FT,E_FT,B_FT,t);

function S = createStruct(Z,fe,H,tH,Ep,E,B,F_FT,E_FT,B_FT,t)
    S = struct();

    S.Out = E;
    S.In = B(:,:,1);
    if size(B,3) > 1
        S.InRR = B(:,:,2);
    end
    
    S.Time = t;
    
    S.Out_FT = E_FT;
    S.In_FT = B_FT;
    S.F_FT = F_FT;
    
    S.Z = Z;
    S.fe = fe;
    S.H = H;
    S.t = tH;
    S.Predicted = Ep;

    S.PE  = pe_nonflag(E,Ep);
    S.MSE = mse_nonflag(E,Ep);
    S.CC  = cc_nonflag(E,Ep);

    S.In_PSD    = smoothSpectra(B(:,:,1),opts);
    S.Out_PSD   = smoothSpectra(E,opts);
    S.Error_PSD = smoothSpectra(E-Ep,opts);
    S.SN        = S.Out_PSD./S.Error_PSD;
    S.Coherence = smoothCoherence(E,Ep,opts);
    S.Phi       = atan2(imag(Z),real(Z));
end

function [Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts)

    N = size(B,1);
    f = [0:N/2]'/N;

    if ~isempty(winopts)
        [fe,Ne,Ic] = evalfreq(f,'linear',winopts);
    else
        [fe,Ne,Ic] = evalfreq(f);
    end
    

    Ep = real(Zpredict(fe,Z,B));

    E_error = Ep-E;
    ftE_error = fft(E_error);
    ftE_error = ftE_error(1:N/2+1,:);
    Pe = ftE_error.*conj(ftE_error); % Power in error as a function of f

    for j = 1:length(Ic)

        if strmatch(winfn,'parzen','exact')
            W = parzenwin(2*Ne(j)+1); 
            W = W/sum(W);
        end
        if strmatch(winfn,'bartlett','exact')
            W = bartlett(2*Ne(j)+1); 
            W = W/sum(W);
        end
        if strmatch(winfn,'rectangular','exact')
           W = ones(2*Ne(j)+1,1);  
           W = W/sum(W);
        end
        r = [Ic(j)-Ne(j):Ic(j)+Ne(j)];  

        fa = f(Ic(j)-Ne(j));    
        fb = f(Ic(j)+Ne(j));
        if verbose
            fprintf('Window at f = %.8f has %d points; fl = %.8f fh = %.8f\n',...
                    fe(j),length(r),fa,fb)
        end
        SEerr(j,1) = sum(W.*Pe(r,1));
        %SEerr(j,2) = sum(W.*Pe(r,2));
    end
end

end
