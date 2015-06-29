function varargout = sorton(varargin)
%SORTON Sort matrix by first column or first row
%
%   Y = SORTON(X) Sorts the matrix X in the order determined by sorting the
%   first column of X, i.e.,
%
%   [Y,I] = SORT(X(:,1)); Y(:,2:end) = Y(I,2:end);
%
%   [Y1,Y2,...] = SORTON(X1,X2,...) sorts X1, X2, ... on the first column
%   of X1.
%
%   See also SORT.

m = size(varargin{1},2);  

[varargout{1},I] = sort(varargin{1}(:,1));

if (m > 1)
  varargout{1}(:,2:m) = varargin{1}(I,2:m);
end

if (length(varargin) > 1)
  for i = 2:length(varargin)
    if ( size(varargin{i},1) ~= length(I) )
      error('sorton: Inputs must have the same number of rows');
    end
    varargout{i} = varargin{i}(I,:);
  end
end
