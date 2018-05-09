function index = findConditionalNthIndex(A,b,n)
%findConditionalNthIndex Extract the n'th element satisfying a condition A == b.
%   Reference: 
%   https://www.mathworks.com/matlabcentral/answers/37686-finding-the-n-th-element-satisfying-a-condition

tempIdx = find(A==b,n,'first');
index = tempIdx(end);

end

