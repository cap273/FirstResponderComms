function C = crossJoin(A,B)

% crossJoin - Cross Join of Two Matrices
%    C = crossJoin(A,B) returns the cross join (aka the cartesian product)
%    of two matrices A and B.
%    Reference: https://en.wikipedia.org/wiki/Join_(SQL)#Cross_join

    ma=size(A,1);
    mb=size(B,1);
    
    [c1, c2] = ndgrid(1:ma,1:mb);
    C = [A(c1,:), B(c2,:)];
end

