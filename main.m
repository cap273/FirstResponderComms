%% main
% This script calculates certain Figures of Merit for various architectures
% in a hub-and-spoke network topology.
%
% Diagram of the model for the physical dimensions of the network topology:
% https://github.com/cap273/FirstResponderComms/blob/master/HubAndSpoke-SlantRange.png
%
% Diagram of the model for the various communications links, and their
% relates Figures of Merit:
% https://github.com/cap273/FirstResponderComms/blob/master/HubAndSpoke-CommLinks.png

%% Clear everything
clc
clear
close all

%% MATLAB Reminders
% Regarding matrix indexing:
% A(2,4)  -> % Extract the element in row 2, column 4
%
% Use square brackets (not curly brackets) to declare a
% matrix of numbers (as opposed to a cell array). Reference:
% https://stackoverflow.com/questions/5966817/difference-between-square-brackets-and-curly-brackets-in-matlab


%% Architecture Enumeration
% Create an M x N matrix, where each row in the matrix represents one 
% complete architecture definition. 
%   N represents the number of indepdentedent decisions in the
%   architecture.
%   For each i'th decision, there are Ni options available
%   M is the product of the sequence of all Ni
%
% The list of independent decisions that represent one complete
% architecture are the following:
% 1) Radio Unit Transmit [Tx] Power
% 2) Radio Unit Gain - this is a wire antenna, and therefore we cannot 
%                       calculate gain based on antenna aperture
% 3) Repeater Antenna Aperture
% 4) Dispatch Center Power
% 5) Dispatch Center Antenna Apeture
% 6) Frontend Carrier Data Rate (between radio unit and repeater)
% 7) Backhaul Carrier Data Rate (between repeater and dispatch center)
% 8) Frontend Available Bandwidth (between radio unit and repeater)
% 9) Backhaul Carrier Data Rate (between repeater and dispatch center)
% 10) Carrier Frequency (assuming one global center frequency for all links)
% 11) Vertical height to repeater antenna from radio unit (related to 
%           slant range, and highly dependent on type of repeater -
%           land-based, aerial-based, space-based)
% 12) Vertical height to repeater antenna from dispatch center (related to 
%           slant range, and highly dependent on type of repeater -
%           land-based, aerial-based, space-based)
%
% In the architecture enumeration matrix, the j'th column contains a value
% for the j'th corresponding decision listed above. For example, the
% matrix's 6th column contains data on the Frontend Carrier Data Rate
% (which is listed under number 6)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Declare the values of the independent decisions
%%%%%%%%%%%%%%%%%%%%%%%%

%1
% Radio Unit Transmit = [6,25,45] (Watts)
powerRadio = [6,25,45];

%2 
% Radio Unit Gain = [10,25] (dB)
gainRadio = [convertToLinearFromdb(10),convertToLinearFromdb(25)];

%3 
% Repeater Antenna Aperture
diaRepeater = [0.1,0.2,0.5];

%4
% Dispatch Center Power
powerDispatch = [50,100,200];

%5
% Dispatch Center Antenna Apeture
diaDispatch = [0.05,0.1,0.2]; 

%6
% Frontend Carrier Data Rate (bps) = [Voice, Video]
frontDataRate = [5000, 100000]; % 5kbps, 100kbps

%7
% Backhaul Carrier Data Rate (between repeater and dispatch center)
backhaulDataRate = [100000, 1000000]; % 100kbps, 1Mbps

%8 
% Frontend Available Bandwidth (between radio unit and repeater)
frontendBandwidth = [6.25*1000]; %6.25 kHz

%9
% Backhaul Available Bandwidth (between repeater and dispatch center)
backhaulBandwidth = [12.5*1000]; %12.5 kHz

%10 
% Carrier Frequency = [VHF, UHF1, UHF2, 700/800-1, 700/800-2, 700/800-3] (MHz)
carrierFrequency = [155*10^6,425*10^6,485*10^6,770*10^6,815.5*10^6, ...
                        860.5*10^6];
                    
%11
% Vertical height to repeater antenna from radio unit
% Considering land-based, aerial-based, and space-based repeaters
heightRadioToRepeater = [5,10,15,20,300*1000,400*1000]; 

%12
% Vertical height to repeater antenna from dispatch center
heightDispatchToRepeater = [5,10,15,20,300*1000,400*1000];


%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate size of architecture
%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize an array to hold the array of options for each decision
% In this array, arrayOptionsPerDecisions(1,k) holds the array of options
% for decision k. For example, arrayOptionsPerDecisions(1,6) holds the
% array frontDataRate
arrayOptionsPerDecisions = {powerRadio,...
                            gainRadio,...
                            diaRepeater,...
                            powerDispatch,...
                            diaDispatch,...
                            frontDataRate,...
                            backhaulDataRate,...
                            frontendBandwidth,...
                            backhaulBandwidth,...
                            carrierFrequency,...
                            heightRadioToRepeater,...
                            heightDispatchToRepeater};

% Calculate number of independent decisions, based on
% arrayOptionsPerDecisions
NUMBER_OF_DECISIONS = numel(arrayOptionsPerDecisions);

% Initialize array to hold the number of options per decision
% In this array, numArrayOptionsPerDecisions(1,k) represents the number of
% options available for decision k
numArrayOptionsPerDecisions = zeros(1,NUMBER_OF_DECISIONS);

% Populate array containing number of options per decision
for i = 1:1:NUMBER_OF_DECISIONS
    numArrayOptionsPerDecisions(1,i) = numel(arrayOptionsPerDecisions{i});
end


%%%%%%%%%%%%%%%%%
% Enumerate all possible architectures
%%%%%%%%%%%%%%%%%

% Reference for this solution:
% https://www.mathworks.com/matlabcentral/answers/341815-all-possible-combinations-of-three-vectors
 [c1, c2, c3, c4, c5,...
     c6, c7, c8, c9,...
     c10, c11, c12] = ndgrid(powerRadio,...
                        gainRadio,...
                        diaRepeater,...
                        powerDispatch,...
                        diaDispatch,...
                        frontDataRate,...
                        backhaulDataRate,...
                        frontendBandwidth,...
                        backhaulBandwidth,...
                        carrierFrequency,...
                        heightRadioToRepeater,...
                        heightDispatchToRepeater);
                    
                    
 architectures = [c1(:), c2(:), c3(:), c4(:), c5(:),...
     c6(:), c7(:), c8(:), c9(:),...
     c10(:), c11(:), c12(:)];

 % Assert that calculated number of architectures (i.e. rows in the architecture
 % matrix) is the same as the number of expected architectures
 if ( size(architectures,1) ~= prod(numArrayOptionsPerDecisions) )
     error('Error in enumerating all possible architectures');
 else
     % Establish number of possible architectures
     NUM_POSSIBLE_ARCHS = size(architectures,1);
 end
 
 
 %% Architecture Evaluation
 
 %%%%%%%%%%%%%%%%%%%%
 % Make general assumptions
 %%%%%%%%%%%%%%%%%%%%
 
 % Antenna aperture efficiency (for both dispatch and repeater)
 eff = 0.55;
 
 % Temperature (in Kelvin) of receiving antenna, for all antennas
 Tr = 200;

 % TODO: make assumptions on atmospheric losses
 % losses of 10.0, converted to linear value
 atmLoss = convertToLinearFromdb(-10); 

 % TODO: make assumptions on horizontal distance to repeater, for radio
 % unit and for dispatch
 hozDistanceRadio2Repeater = 10000; %10km
 hozDistanceDispatch2Repeater = 3000; %3km
 
 
%%%%%%%%%%%%%%%%%%%%%%%
% Calculate link margin for frontend (between repeater and radio unit)
% and link margin for backhaul (between repeater and dispatch) for each
% possible architecture
%%%%%%%%%%%%%%%%%%%%%%%
 
 % Initialize column vector of length NUM_POSSIBLE_ARCHS
 frontendLinkMargin = zeros(NUM_POSSIBLE_ARCHS,1);
 backhaulLinkMargin = zeros(NUM_POSSIBLE_ARCHS,1);
 
 % Iterate through each possible architecture 
 for k = 1:1:NUM_POSSIBLE_ARCHS
     
     % For sanity's sake, extract all values for each decision in this
     % architecture
     thisPowerRadio = architectures(k,1);
     thisGainRadio = architectures(k,2);
     thisDiaRepeater = architectures(k,3);
     thisPowerDispatch = architectures(k,4);
     thisDiaDispatch = architectures(k,5);
     thisFrontDataRate = architectures(k,6);
     thisBackhaulDataRate = architectures(k,7);
     thisFrontendBandwidth = architectures(k,8);
     thisBackhaulBandwidth = architectures(k,9);
     thisCarrierFrequency = architectures(k,10);
     thisHeightRadioToRepeater = architectures(k,11);
     thisHeightDispatchToRepeater = architectures(k,12);
     
     % Calculate slant range based on assumed horizontal range, and on this
     % particular architecture's vertical height
     thisSlantRangeRadioToRepeater = sqrt(hozDistanceRadio2Repeater^2 ...
                                    + thisHeightRadioToRepeater^2);
     thisSlantRangeDispatchToRepeater = sqrt(hozDistanceDispatch2Repeater^2 ...
                                    + thisHeightDispatchToRepeater^2);
     
     % Find gain for the repeater and dispatch antenna
     thisGainRepeater = calculateGainFromAntennaDiameter(eff,...
                    thisDiaRepeater,thisCarrierFrequency);
     thisGainDispatch = calculateGainFromAntennaDiameter(eff,...
                    thisDiaDispatch,thisCarrierFrequency);
                
     % Find Eb/No (both calculated and minimum) for frontend links
     thisFrontendEbNo = calculateLinearEbNo(thisPowerRadio,...
                            thisGainRadio,...
                            thisGainRepeater,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisFrontDataRate,...
                            atmLoss);
                        
     thisFrontendEbNoMin = calculateLinearMinEbNo(thisFrontDataRate,...
                                                  thisFrontendBandwidth);
     
     % Find Eb/No (both calculated and required) for backhaul links
     thisBackhaulEbNo = calculateLinearEbNo(thisPowerDispatch,...
                            thisGainDispatch,...
                            thisGainRepeater,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisBackhaulDataRate,...
                            atmLoss);
     thisBackhaulEbNoMin = calculateLinearMinEbNo(thisBackhaulDataRate,...
                                                  thisBackhaulBandwidth);
                                              
     % Calculate link margin for frontend and backhaul links
     frontendLinkMargin(k,1) = findLinkMarginIndB(thisFrontendEbNo, ...
                                        thisFrontendEbNoMin);
     
     backhaulLinkMargin(k,1) = findLinkMarginIndB(thisBackhaulEbNo, ...
                                        thisBackhaulEbNoMin);
     
 end
 
 %% Visualization
 
 % TODO: make sense out of the effect of 12 different decisions into link
 % margins and other figures of merit

figure
hold on
frontendMarginPlot = plot(sort(frontendLinkMargin));
grid
set(frontendMarginPlot,'LineWidth',2);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Frontend Link Margin')
hold off

figure
hold on
frontendMarginPlot = plot(sort(backhaulLinkMargin));
grid
set(frontendMarginPlot,'LineWidth',2);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Backhaul Link Margin')
hold off

