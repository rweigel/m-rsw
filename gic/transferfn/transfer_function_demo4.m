
for j = 1:length(feP)
    pw{j}   = parzenwin(2*NeP(j)+1); 
    r       = [IcP(j)-NeP(j):IcP(j)+NeP(j)];  
    BxBx(j) = sum(pw{j}.*ftB(r,1).*conj(ftB(r,1))); 
    ByBx(j) = sum(pw{j}.*ftB(r,2).*conj(ftB(r,1))); 
    ExBx(j) = sum(pw{j}.*ftE(r,1).*conj(ftB(r,1))); 
    EyBx(j) = sum(pw{j}.*ftE(r,2).*conj(ftB(r,1))); 

    ByBy(j) = sum(pw{j}.*ftB(r,2).*conj(ftB(r,2))); 
    ExBy(j) = sum(pw{j}.*ftE(r,1).*conj(ftB(r,2))); 
    EyBy(j) = sum(pw{j}.*ftE(r,2).*conj(ftB(r,2))); 

    ExEx(j) = sum(pw{j}.*ftE(r,1).*conj(ftE(r,1)));
    EyEx(j) = sum(pw{j}.*ftE(r,2).*conj(ftE(r,1)));

    EyEy(j) = sum(pw{j}.*ftE(r,2).*conj(ftE(r,2)));

    BxBy(j) = sum(pw{j}.*ftB(r,1).*conj(ftB(r,2)));

    DET(j) =  BxBx(j)*ByBy(j) - BxBy(j)*ByBx(j);
    Zxx(j) = (ExBx(j)*ByBy(j) - ExBy(j)*ByBx(j))/DET(j);
    Zxy(j) = (ExBy(j)*BxBx(j) - ExBx(j)*BxBy(j))/DET(j);
    Zyx(j) = (EyBx(j)*ByBy(j) - EyBy(j)*ByBx(j))/DET(j);
    Zyy(j) = (EyBy(j)*BxBx(j) - EyBx(j)*BxBy(j))/DET(j);
end
