function varargout = removemean(varargin)

% Remove mean
for c = 1:length(varargin)
    if length(size(varargin{c})) > 3
        error('Input matrix must have less than 4 dimensions');
    end
    varargout{c} = varargin{c}; % Preallocate
    for k = 1:size(varargin{c},3)
        for j = 1:size(varargin{c},2)
            Ig = find(~isnan(varargin{c}(:,j,k)));
            varargout{c}(:,j,k) = varargin{c}(:,j,k)-mean(varargin{c}(Ig,j,k));
        end
    end
end

return

for i = 1:size(E,2)
    Ig = find(~isnan(E(:,i)));
    E(:,i) = E(:,i)-mean(E(Ig,i));
end
for k = 1:size(B,3)
    for i = 1:size(B,2)
        Ig = find(~isnan(B(:,i,k)));
        B(:,i,k) = B(:,i,k)-mean(B(Ig,i,k));
    end
end
for i = 1:size(GIC,2)
    Ig = find(~isnan(GIC(:,i)));
    GIC(:,i) = GIC(:,i)-mean(GIC(Ig,i));
end
