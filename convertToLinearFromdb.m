function linear = convertToLinearFromdb(deciBel)
%convertToLinearFromdb Convert a deciBel value into a linear factor
%   Reference: https://en.wikipedia.org/wiki/Decibel#Power_quantities
    linear = 10^(deciBel/10);
end