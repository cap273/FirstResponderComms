function linFireLoss = calculateFireLoss(d,f)
%calculateFireLoss - Calculate losses due to propagation through smoke
%   linFireLoss = calculateFireLoss(d,f) retuns the losses due to
%   propagation through smoke (due to a fire).
%   
%   OUTPUTS:
%       linFireLoss: a linear factor (instead of a value in deciBels) of
%       the loss due to propagation through smoke
%   INPUTS:
%       d: the propagation path through smoke (due to fire) in meters
%       f: the frequency (in Hertz) of the communications link

% Convert frequency in Hertz to frequency in MegaHertz
fMhz = f*(1e-6);

% Formula to calculate fire loss in deciBels based
% on linear fit of three data points
% Linear fit calculation: 
% https://github.com/cap273/FirstResponderComms/blob/master/fireLossLinearFit.png
% Investigate further: accuracy of this linear fit model in lower-frequency
% ranges
dbFireLoss = d*( (0.000563775*fMhz) - 0.010559);

% Convert dB value to linear value for output
linFireLoss = convertToLinearFromdb(-dbFireLoss);

end

