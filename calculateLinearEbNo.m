% Reminder for losses:
% As linear values: they should be a fraction less than 1
% As deciBel values: they should be a negative value

function EbNo = calculateLinearEbNo(Ptx,Gtx,Grx,slantRange,radioFreq,Tr,dataRate,atmLoss)
%calculateLinearEbNo Calculate Eb/No for one digital comms link. 
%Eb/No is the the energy per bit to noise power spectral density ratio
% NOTE: All inputs and outputs are linear magnitudes (vs deciBel values)
%   Ptx: transmitter radiofrequency (RF) power
%   Gtx: transmitter antenna gain
%   Grx: receiver antenna gain
%   slantRange: the straight-line distance (in meters) from the transmitter
%   to the receiver
%   radioFreq: the radio frequency of the signal (in Hertz)
%   Tr: temperature (in Kelvin) of the receiver antenna
%   dataRate: carrier data rate (in bits per second)
%   atmLoss: losses due to atmospheric conditions, including any smoke or
%       foliage


    % Calculate losses due to thermal noise
    thermalNoiseLoss = calculateLossThermalNoise(Tr,dataRate);

    % Calculate free space path loss (FSPL)
    FSPL = calculateFSPL(radioFreq,slantRange);

    % Calculate Eb/No for this digital communication link
    EbNo = Ptx*Gtx*Grx*FSPL*thermalNoiseLoss*atmLoss;

end

function thermalNoiseLoss = calculateLossThermalNoise(Tr,dataRate)
%calculateNoiseDensity Calculate loss due to thermal noise on the receiver 
%antenna
%   Tx: temperature (in Kelvin) of the receiver antenna
%   dataRate: carrier data rate (in bits per second)

    % Define Boltzmann constant, in SI base units (mks)
    kb = 1.38064852 * 10^(-23);

    % Calculate noise density
    Nd = kb*Tr;

    % Calculate thermal noise loss
    thermalNoiseLoss = 1/(Nd*dataRate);

end

function FSPL = calculateFSPL(radioFreq,slantRange)
%calculateFSPL Calculate free space path loss (FSPL)
%   slantRange: the straight-line distance (in meters) from the transmitter
%   to the receiver
%   radioFreq: the radio frequency of the signal (in Hertz)

    % Define speed of light (in m/s)
    c = 299792458;

    % Calculate FSPL
    FSPL = (c/(radioFreq*4*pi*slantRange))^2;

end