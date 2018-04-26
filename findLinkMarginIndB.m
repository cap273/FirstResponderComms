function dbLinkMargin = findLinkMarginIndB(calcEbNoLinear, ...
    minEbNoLinear)
%findLinkMarginIndB Returns the margin (dB) between Eb/No and required Eb/No
%   The margin is calculated as:
%       Margin = (calculated Eb/No) - (minimum required Eb/No)
%   All inptus are in linear factors, not deciBels
%   Output is in deciBels
%   
%   calcEbNoLinear: calculated Eb/No as a linear factor. This is the output
%       of the function "calculateLinearEbNo"
%   minEbNoLinear: minimum required Eb/No according to the Shannon limit 
%       (plus any additional dBs over the theoretical minimum as a safety 
%        margin). This value is linear factor. This is the output of the 
%        function"calculateLinearMinEbNo"

    % Convert linear Eb/No to deciBel Eb/No
    calcEbNodB = convertTodBFromLinear(calcEbNoLinear);
    minEbNodB = convertTodBFromLinear(minEbNoLinear);
    
    % Find Link Margin
    dbLinkMargin = calcEbNodB - minEbNodB;
end

