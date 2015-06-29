function [err,hf] = errfn2(x)

    global hmem;
    global tf;

a = x(1:end/2);
tau = x(end/2+1:end);
hf = zeros(length(hmem),1);

for i = 1:length(x)/2
    hf = hf + a(i)*exp(-(tf)/tau(i));
end

err = mse(hmem,hf);
