function padding = pad(methods)

% Get padding for fprintf.
for m = 1:length(methods)
    L(m) = length(methods{m});
end
mL = max(L);
for m = 1:length(methods)
    padding{m} = repmat(' ',1, mL - length(methods{m}));
end
