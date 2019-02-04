function [Z,fe,H,t,Ep] = transferfnFD(B,E,opts)
%TRANSFERFNFD Estimates transfer function
%
%  Estimates complex transfer function Z(f) in one of
%
%  E(f) = Z(f)B(f)
%
%  E(f) = Zx(f)Bx(f) + Zy(f)By(f)
%
%  where f is frequency.
%
%  [Z,fe,H,t,Ep] = transferfnFD(B,E,method,winfn,winopts)
%
%  Methods:
%
%  Compute Z in E = ZB
%    method 1: Uses closed-form equations
%    method 2: Uses regress()
%    method 3: Uses robustfit()
%
%  Compute Z = C^{-1} in B = CE
%    method 4: Uses closed-form equations to compute 
%    method 5: Uses regress()
%    method 6: Uses robustfit()
%
%  For method = 1,2,3, solves one of (depending on # cols in E and B)
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

if (0)
if ~isnan(opts.td.window.width)
    Tw = opts.td.window.width;
    Ts = opts.td.window.shift;
    opts.td.window.width = NaN;
    Io = [1:Ts:size(B,1)-Tw+1];
    for i = 1:length(Io)
        Iseg = [Io(i):Io(i)+Tw-1];
        Scell{i} = transferfnFD(B(Iseg,1:2),E(Iseg,:),opts);
        fprintf('transferfnFD.m: %d/%d PE/CC/MSE of Ex using B = %.2f/%.2f/%.3f\n',i,length(Io),Scell{i}.PE(1),Scell{i}.CC(1),Scell{i}.MSE(1));
        fprintf('transferfnFD.m: %d/%d PE/CC/MSE of Ey using B = %.2f/%.2f/%.3f\n',i,length(Io),Scell{i}.PE(2),Scell{i}.CC(2),Scell{i}.MSE(2));
        Z = struct();
        Z.fe = Scell{1}.fe;
        for i = 1:length(Scell)
            Z.Z(:,:,i)  = Scell{i}.Z;
            Z.E(:,:,i)  = Scell{i}.E;
            Z.B(:,:,i)  = Scell{i}.B;
            Z.H(:,:,i)  = Scell{i}.H;
            Z.Ep(:,:,i) = Scell{i}.Ep;

            Z.MSE(1,:,i) = Scell{i}.MSE;
            Z.PE(1,:,i)  = Scell{i}.PE;
            Z.CC(1,:,i)  = Scell{i}.CC;

            Z.B_PSD(:,:,i)     = Scell{i}.B_PSD;
            Z.E_PSD(:,:,i)     = Scell{i}.E_PSD;
            Z.Err_PSD(:,:,i)   = Scell{i}.Err_PSD;
            Z.Coherence(:,:,i) = Scell{i}.Coherence;
            Z.Phi(:,:,i)       = Scell{i}.Phi;
        end
    end
    return;
end
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
        method = method - 3;
        [C,fe,H,t,Ep] = transferfnFD(E,B,opts);        
        Z = 1./C;
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);
        [Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts);
        if nargout == 1
            Z = createStruct(Z,fe,H,t,Ep,E,B);
        end
        return;
    end
end

if size(B,2) == 2 && size(E,2) == 1
    if method <= 3
        % Ex = ZxBx + ZyBy
        % Case is handled by default.
    else
        % Bx = CxxEx + CxyEy does not make sense to request
        error('Method cannot be used give input dimensions.')
    end
end

if size(B,2) == 2 && size(E,2) == 2
    if method <= 3
        % Ex = ZxxBx + ZxyBy
        % Ey = ZyxBx + ZyyBy
        [Z(:,1:2),fe,H(:,1:2),t,Ep(:,1)] = transferfnFD(B,E(:,1),opts);
        [Z(:,3:4),fe,H(:,3:4),t,Ep(:,2)] = transferfnFD(B,E(:,2),opts);
        if nargout == 1
            Z = createStruct(Z,fe,H,t,Ep,E,B);
        end
        return;
    else
        % Bx = CxxEx + CxyEy
        % By = CyxEx + CyyEy
        method = method - 3;
        [C(:,1:2),fe,HB(:,1:2),t,Bp(:,1)] = transferfnFD(E,B(:,1),opts);
        [C(:,3:4),fe,HB(:,3:4),t,Bp(:,2)] = transferfnFD(E,B(:,2),opts);

        % Compute Z = C^{-1}
        DET = C(:,1).*C(:,4)-C(:,2).*C(:,3);
        Z   = [C(:,4),-C(:,2),-C(:,3),C(:,1)]./repmat(DET,1,4);
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);
        [Ep(:,1),SEerr(:,1)] = calcErrors(Z(:,1:2),B,E(:,1),opts);
        [Ep(:,2),SEerr(:,2)] = calcErrors(Z(:,3:4),B,E(:,2),opts);
        if nargout == 1
            Z = createStruct(Z,fe,H,t,Ep,E,B);
        end
        return;
    end
end

if nargin > 2 & strmatch(opts.td.prewhiten.method,'yulewalker','exact')
    [~,a,b] = prewhiten(B(:,1),opts.td.prewhiten.options);
    Ew = filter(b,a,E);
    Bw = filter(b,a,B);
else
    Bw = B;
    Ew = E;
end

ftB = fft(Bw);
ftE = fft(Ew);
ftB = ftB(1:N/2+1,:);
ftE = ftE(1:N/2+1,:);

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

    if 0
        % Give higher weight to low freq (which has lower noise)
        W = W.*mean(PB(r,:),2);
        W = W/sum(W);
    end
    
    if verbose
        fprintf('Window at f = %.8f has %d points; fl = %.8f fh = %.8f\n',...
                fe(j),length(r),fa,fb)
    end

    BxBx(j) = sum(W.*(ftB(r,1).*conj(ftB(r,1)))); 
    ExEx(j) = sum(W.*(ftE(r,1).*conj(ftE(r,1))));

    SE(j,1) = ExEx(j);
    if size(B,2) == 1
        SB(j,1) = BxBx(j);
    else
        ByBy(j) = sum(W.*(ftB(r,2).*conj(ftB(r,2))));    
        SB(j,1:2) = [BxBx(j),ByBy(j)];
    end
    
    if method == 1
        if size(B,2) == 1
            % Ex = ZxxBx
            Z(j,1) = sum(W.*(ftE(r,1).*conj(ftB(r,1))))/sum(W.*(ftB(r,1).*conj(ftB(r,1))));
        else
            % Ex = ZxxBx + ZxyBy
            % OLS solution to above. Minimizes errors in Ex.
            BxBy(j) = sum(W.*(ftB(r,1).*conj(ftB(r,2))));
            ByBx(j) = sum(W.*(ftB(r,2).*conj(ftB(r,1))));

            ExBx(j) = sum(W.*(ftE(r,1).*conj(ftB(r,1)))); 
            ExBy(j) = sum(W.*(ftE(r,1).*conj(ftB(r,2)))); 

            BxEx(j) = sum(W.*(ftB(r,1).*conj(ftE(r,1)))); 

            DET =  BxBy(j)*ByBx(j) - BxBx(j)*ByBy(j);
            Zxx = (ExBy(j)*ByBx(j) - ExBx(j)*ByBy(j))/DET;
            Zxy = (ExBx(j)*BxBy(j) - ExBy(j)*BxBx(j))/DET;
            Z(j,:) = [Zxx,Zxy];
        end
    end

    if method == 2
        % Same as method 1 except using regress function.
        W = sqrt(W);
        Wr = repmat(W,1,size(B,2));
        Z(j,:) = regress(W.*ftE(r,1),Wr.*ftB(r,:));
    end

    if 0 && j > 15
        W = sqrt(W);
        Wr = repmat(W,1,size(B,2));
        Er_act = real(W.*ftE(r,1));
        Ei_act = real(W.*ftE(r,1));

        Z_rob(j,:) = robustfit(Wr.*ftB(r,:),W.*ftE(r,1),'cauchy',[],'off');        
        Er_rob = real(Wr.*ftB(r,:))*real(Z_rob(j,:))';        
        Ei_rob = imag(Wr.*ftB(r,:))*imag(Z_rob(j,:))';        

        Z_ols(j,:) = regress(W.*ftE(r,1),Wr.*ftB(r,:));
        Er_ols = real(Wr.*ftB(r,:))*real(Z_ols(j,:))';
        Ei_ols = imag(Wr.*ftB(r,:))*imag(Z_ols(j,:))';

        clf;
        plot(Er_act,Er_rob,'r.','MarkerSize',20);
        hold on;
        plot(Er_act,Er_ols,'b.','MarkerSize',10);

        err = Er_act-Er_rob;
        % Remove "outlier" errors.
        I = find(err/std(err) <= 1.5);

        Z_ols(j,:) = regress(W(I,:).*ftE(r(I),1),Wr(I,:).*ftB(r(I),:));
        Er_ols = real(Wr(I,:).*ftB(r(I),:))*real(Z_ols(j,:))';
        Ei_ols = imag(Wr(I,:).*ftB(r(I),:))*imag(Z_ols(j,:))';
        plot(Er_act(I),Er_ols,'g.','MarkerSize',5);        
        legend('Re(FT(E)) OLS','Re(FT(E)) Robust','Re(FT(E) OLS Trimmed');
        keyboard
    end
    
    if method == 3
        % Same as method 1 except using robustfit function.
        W = sqrt(W);
        Wr = repmat(W,1,size(B,2));
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
t = [-n:n]';

Ep = real(Zpredict(fe,Z,B));

%[Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts);
SEerr = smoothSpectra(E,opts);

if nargout == 1
    Z = createStruct(Z,fe,H,t,Ep);
end

function S = createStruct(Z,fe,H,t,Ep,E,B)
    S = struct();

    S.E = E;
    S.B = B;
    
    S.Z = Z;
    S.fe = fe;
    S.H = H;
    S.t = t;
    S.Ep = Ep;

    S.PE  = pe_nonflag(E,Ep);
    S.MSE = mse_nonflag(E,Ep);
    S.CC  = cc_nonflag(E,Ep);

    S.B_PSD     = smoothSpectra(B(:,1:2),opts);
    S.E_PSD     = smoothSpectra(E,opts);
    S.Err_PSD   = smoothSpectra(E-Ep,opts);
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
