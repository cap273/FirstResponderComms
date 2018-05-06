function linFoliageLoss = calculateFoliageLoss(d,f)
%calculateFireLoss - Calculate losses due to propagation through smoke
%   linFoliageLoss = calculateFoliageLoss(d,f) retuns the losses due to
%   propagation through foliage (i.e. trees, vegetation, leaves, etc.)
%   
%   OUTPUTS:
%       linFireLoss: a linear factor (instead of a value in deciBels) of
%       the loss due to propagation through foliage
%   INPUTS:
%       d: the propagation path through foliage in meters
%       f: the frequency (in Hertz) of the communications link

% Convert frequency in Hertz to frequency in GigaHertz
fGhz = f*(1e-9);

% Formula to calculate foliage loss in deciBels
% Reference:
% https://github.com/cap273/FirstResponderComms/blob/master/foliageLossEmpiricalFormula.png
dbFoliageLoss = 1.33*(fGhz^0.284)*(d^0.588);

% Convert dB value to linear value for output
linFoliageLoss = convertToLinearFromdb(-dbFoliageLoss);

end

