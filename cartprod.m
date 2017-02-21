function X = cartprod(inpcell)
%CARTPROD Cartesian product of multiple sets.
%
%   X = CARTPROD(A,B,C,...) returns the cartesian product of the sets 
%   A,B,C, etc, where A,B,C, are numerical vectors.  
%
%   Example: A = [-1 -3 -5];   B = [10 11];   C = [0 1];
% 
%   X = cartprod(A,B,C)
%   X =
% 
%     -5    10     0
%     -3    10     0
%     -1    10     0
%     -5    11     0
%     -3    11     0
%     -1    11     0
%     -5    10     1
%     -3    10     1
%     -1    10     1
%     -5    11     1
%     -3    11     1
%     -1    11     1
%
%   This function requires IND2SUBVECT, also available (I hope) on the MathWorks 
%   File Exchange site.
% Reference: http://in.mathworks.com/matlabcentral/fileexchange/5475-cartprod--cartesian-product-of-multiple-sets/content//cartprod.m


numSets = length(inpcell);
for i = 1:numSets,
    thisSet = sort(inpcell{i});
    if ~isequal(prod(size(thisSet)),length(thisSet)),
        error('All inputs must be vectors.')
    end
    if ~isnumeric(thisSet),
        error('All inputs must be numeric.')
    end
    if ~isequal(thisSet,unique(thisSet)),
        error(['Input set' ' ' num2str(i) ' ' 'contains duplicated elements.'])
    end
    sizeThisSet(i) = length(thisSet);
    inpcell{i} = thisSet;
end

X = zeros(prod(sizeThisSet),numSets);
for i = 1:size(X,1),
    
    % Envision imaginary n-d array with dimension "sizeThisSet" ...
    % = length(inpcell{1}) x length(inpcell{2}) x ...
    
    ixVect = ind2subVect(sizeThisSet,i);
    
    for j = 1:numSets,
        X(i,j) = inpcell{j}(ixVect(j));
    end
end
