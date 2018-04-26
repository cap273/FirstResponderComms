function minEbNo = calculateLinearMinEbNo(dataRate,bandwidth)
%calculateLinearMinEbNo Calculate the minimum required Eb/No.
% The Shannon–Hartley theorem says that the limit of reliable information 
% rate of a channel depends on bandwidth and signal-to-noise ratio.
% Calculate minimum required Eb/No for reliable information rate based on
% Shannon limit.
% NOTE: All inputs and outputs are linear magnitudes (vs deciBel values)
%   dataRate: carrier data rate (in bits per second)
%   bandwidth: available bandwidth for the communications channel (in Hz)

    %Calculate minimum required spectral effiency
    S = dataRate/bandwidth;

    %Calculate the Shannon-limit lower bound on Eb/No
    theoreticalMinEbNo = (2^S - 1)/S;
    
    % Specify some additional required margin (in deciBels) over the 
    % theoretical Shannon-limit lower bound on Eb/No
    additionalMargindB = 3;
    
    % Considering the additional dBs of margin over the theoretical
    % minimum, return the minimum required Eb/No for reliable communication
    minEbNo = theoreticalMinEbNo*convertToLinearFromdb(additionalMargindB);
end