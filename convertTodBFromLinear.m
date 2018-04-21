function deciBel = convertTodBFromLinear(linear)
%convertTodBFromLinear Convert a linear factor into a deciBel
%   Reference: https://en.wikipedia.org/wiki/Decibel#Power_quantities

deciBel = 10*log10(linear);

end

