function s2 = calculatePropagationPath(s1,v1,v2,h1,h2)
%calculatePropagationPath - Calculate the propagation path through
%smoke/fire or through foliage.
%
%   Model for calculations:
%   Case A: v2 = v3
%       https://github.com/cap273/FirstResponderComms/blob/master/propagationPathCalculationCaseA.png
%       
%   Case B: v2 > v3
%       https://github.com/cap273/FirstResponderComms/blob/master/propagationPathCalculationCaseB.png
%   
%   OUTPUTS:
%       s2: the propagation path through fire/smoke or through
%       foliage, in meters
%   INPUTS:
%       s1: the slant range from the spoke to the hub/repeater, in meters
%       v1: the height from the spoke to the hub/repeater, in meters
%       v2: the maximum height of the cover due to foliage, smoke, or fire,
%               in meters
%       h1: horizontal distance from spoke to hub/repeater
%       h2: the maximum horizontal distance of foliage or smoke/fire cover 
%           between the spoke to the repeater


% If inputted h2 is greater than h1, do calculations as if h2=h1
if h2>h1
    h2=h1;
end

% Find the sine of the triangle
sinTheta = v1/s1;

% Find angle theta (in radians)
theta = asin(sinTheta);

% Find tangent of theta
tanTheta = tan(theta);

if (h2*tanTheta) > v2
    %   Case A: v2 = v3
    %   https://github.com/cap273/FirstResponderComms/blob/master/propagationPathCalculationCaseA.png
    v3 = v2;
    
else
    %   Case B: v2 > v3
    %   https://github.com/cap273/FirstResponderComms/blob/master/propagationPathCalculationCaseB.png
    
    v3 = h2*tanTheta;
end

% Find propagation path
s2 = v3/sinTheta;

end

