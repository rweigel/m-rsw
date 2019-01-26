function [Z,fe,H,t,Ep,SB,SE,SEerr] = transferfnFD(B,E,method,winfn,winopts)
%TRANSFERFNFD Estimates transfer function
%
%  Estimates complex transfer function Z(f) in models
%
%  E(f) = Z(f)B(f)
%  E(f) = Zx(f)Bx(f) + Zy(f)By(f)
%
%  where w is frequency.
%
%  [Z,fe,H,t,Ep,SB,SE,SEerr] = transferfnFD(B,E,method,winfn,winopts)
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
if (nargin < 3)
    method = 1;
end
if (nargin < 4)
    winfn = 'rectangular';
end
if (nargin < 5)
    winopts = [];
end
if (nargin < 6)
    sigma = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caution - code below is duplicated in smoothSpectra()
N = size(B,1);
f = [0:N/2]'/N;

if ~isempty(winopts)
    [fe,Ne,Ic] = evalfreq(f,'linear',winopts);
else
    [fe,Ne,Ic] = evalfreq(f);
end
% End duplicated code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(B,2) == 1 && size(E,2) == 1
    if method <= 3
        % Ex = ZxBx
        % Case is handled by default.
    else
        % Bx = CxxEx
        method = method - 3;
        [C,fe,H,t,Ep,SB,SE,SEerr] = transferfnFD(E,B,method,winfn,winopts);        
        Z = 1./C;
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);
        [Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts);
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
        [Z(:,1:2),fe,H(:,1:2),t,Ep(:,1),SB,SE(:,1),SEerr(:,1)] = transferfnFD(B,E(:,1),method,winfn,winopts);
        [Z(:,3:4),fe,H(:,3:4),t,Ep(:,2),SB,SE(:,2),SEerr(:,2)] = transferfnFD(B,E(:,2),method,winfn,winopts);
        return
    else
        % Bx = CxxEx + CxyEy
        % By = CyxEx + CyyEy
        method = method - 3;
        [C(:,1:2),fe,HB(:,1:2),t,Bp(:,1),SE,SB(:,1),SBerr(:,1)] = transferfnFD(E,B(:,1),method,winfn,winopts);
        [C(:,3:4),fe,HB(:,3:4),t,Bp(:,2),SE,SB(:,2),SBerr(:,2)] = transferfnFD(E,B(:,2),method,winfn,winopts);
        
        % Compute Z = C^{-1}
        DET = C(:,1).*C(:,4)-C(:,2).*C(:,3);
        Z   = [C(:,4),-C(:,2),-C(:,3),C(:,1)]./repmat(DET,1,4);
        H = Z2H(fe,Z,f);
        H = fftshift(H,1);
        [Ep(:,1),SEerr(:,1)] = calcErrors(Z(:,1:2),B,E(:,1),winfn,winopts);
        [Ep(:,2),SEerr(:,2)] = calcErrors(Z(:,3:4),B,E(:,2),winfn,winopts);
        return;
    end
end


%ftB = fft([diff(B);zeros(size(B,2))]);
%ftE = fft([diff(E);zeros(size(E,2))]);
ftB = fft(B);
ftE = fft(E);
ftB = ftB(1:N/2+1,:);
ftE = ftE(1:N/2+1,:);

PB = smoothSpectra(B,'parzen');
PE = smoothSpectra(E,'parzen');

PB = interp1(fe,PB,f);
PE = interp1(fe,PE,f);

for j = 2:length(Ic)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Caution - code below is duplicated in smoothSpectra()
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

[Ep,SEerr] = calcErrors(Z,B,E,winfn,winopts);

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
