function sn = sncalc(p,Z,fe,In,Out)

as = 600;
bs = size(In,1)-as;

Z(19,3) = p(1)*real(Z(19,3)) + p(2)*sqrt(-1)*imag(Z(19,3));
Z(19,4) = p(3)*real(Z(19,4)) + p(4)*sqrt(-1)*imag(Z(19,4));

for s = 1:size(In,3) % Loop over segments
    [Ns,fes] = smoothSpectra(Out(as:bs,:,s));
    Eps = Zpredict(fe,Z,In(:,:,s));
    sns(:,:,s) = Ns./smoothSpectra(Out(as:bs,:,s)-Eps(as:bs,:));
end
SNs = mean(sns, 3);
sn = 1/SNs(19,2);
fprintf('p = [%.2f,%.2f,%.2f,%.2f]; SN = %.2f\n',p,1/sn);
