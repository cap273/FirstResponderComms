function D = recursiveCrossJoin(varargin)

% recursiveCrossJoin - Recursive Cross Join of N Matrices
%    D = crossJoin(C1,C2,...,CN) returns the cross join (aka the 
%    cartesian product) of matrices C1,C2,...,CN by recursively calling
%    the function C = crossJoin(A,B)

    narginchk(1,Inf);
    NC = nargin;
    
    if NC==1
        D = varargin{1};
    else
        D = crossJoin(varargin{1},recursiveCrossJoin(varargin{2:NC}));
    end
    
end