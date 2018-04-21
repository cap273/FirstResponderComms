function minEbNo = calculateLinearMinEbNo(dataRate,bandwidth)
%calculateLinearRequiredEbNo Calculate the minimum Eb/No according to the
%Shannon limit, which states the maximum theoretical information transfer 
%rate of a channel for a particular noise level
% NOTE: All inputs and outputs are linear magnitudes (vs deciBel values)
%   dataRate: carrier data rate (in bits per second)
%   bandwidth: available bandwidth for the communications channel (in Hz)

    %Calculate minimum required spectral effiency
    S = dataRate/bandwidth;

    %Calculate minimum Eb/No as per Shannon limit
    minEbNo = (2^S - 1)/S;
end