function dbLinkMargin = findLinkMarginIndB(calcEbNoLinear, ...
    minEbNoLinear,additionalMargindB)
%findLinkMarginIndB Returns the margin (dB) between Eb/No and required Eb/No
%   The margin is calculated as:
%       Margin = (calculated Eb/No) - (minimum Shannon Eb/No + margin)
%   All inptus are in linear factors, not deciBels
%   Output is in deciBels
%   
%   calcEbNoLinear: calculated Eb/No as a linear factor. This is the output
%       of the function "calculateLinearEbNo"
%   minEbNoLinear: minimum Eb/No according to the Shannon limit, as a
%       linear factor. This is the output of the function
%       "calculateLinearMinEbNo"
%   additionalMargindB: some additional required margin (in deciBels) over 
%       the minimum Eb/No according to the Shannon limit

    % Convert linear Eb/No to deciBel Eb/No
    calcEbNodB = convertTodBFromLinear(calcEbNoLinear);
    minEbNodB = convertTodBFromLinear(minEbNoLinear);
    
    % Find Link Margin
    dbLinkMargin = calcEbNodB - (minEbNodB + additionalMargindB);
end

