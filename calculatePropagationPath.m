function s2 = calculatePropagationPath(s1,v1,v2,h1,h2)
%calculatePropagationPath - Calculate the propagation path through
%smoke/fire or through foliage.
%
%   Model for calculations:
%       https://github.com/cap273/FirstResponderComms/blob/master/propagationPathCalculation.png
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

% Find the sine of the triangle
sinTheta = v1/s1;

% Find propagation path, as both triangles are similar to each other
s2 = v2/sinTheta;

end

