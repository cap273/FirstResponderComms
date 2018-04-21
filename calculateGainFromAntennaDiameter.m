function gain = calculateGainFromAntennaDiameter(eff,diameter,radioFreq)
%calculateGainFromAntennaDiameter Calculate gain from antenna diameter
%   Assumption: the aperture antenna has a circular shape.
%   This function is appliable to aperture antennas. It is not applicable
%   to wire antennas (such as those found on hand-held rados)
%   
%   eff: aperture efficiency (in order to relate physical antenna aperture 
%        to effective antenna aperture)
%   diameter: the physical diameter of the antenna
%   radioFreq: the radio frequency of the signal (in Hertz)
    
    % Define speed of light (in m/s)
    c = 299792458;
    
    % Calculate antenna gain
    gain = eff*(pi*diameter*radioFreq/c)^2;

end

