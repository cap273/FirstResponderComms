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
% 3) Repeater Tx Power
% 4) Repeater Antenna Aperture for Tx
% 5) Repeater Antenna Aperture for Rx
% 6) Dispatch Center Tx Power
% 7) Dispatch Center Antenna Apeture for Tx
% 8) Dispatch Center Antenna Apeture for Rx
% 9) Frontend Carrier Data Rate (between radio unit and repeater)
% 10) Backhaul Carrier Data Rate (between repeater and dispatch center)
% 11) Frontend Available Bandwidth (between radio unit and repeater)
% 12) Backhaul Carrier Data Rate (between repeater and dispatch center)
% 13) Carrier Frequency (assuming one global center frequency for all links)
% 14) Vertical height to repeater antenna from radio unit or dispatch 
%           (related to slant range, and highly dependent on type of 
%           repeater - land-based, aerial-based, space-based)
%
% In the architecture enumeration matrix, the j'th column contains a value
% for the j'th corresponding decision listed above. For example, the
% matrix's 6th column contains data on the Frontend Carrier Data Rate
% (which is listed under number 6)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Declare the values of the independent decisions
%%%%%%%%%%%%%%%%%%%%%%%%

%1
% Radio Unit Transmit Power = [6,25,45] (Watts)
powerRadio = [6,25,45];

%2 
% Radio Unit Gain = [10,25] (dB)
gainRadio = [convertToLinearFromdb(10),convertToLinearFromdb(25)];

%3 
% Repeater Tx Power = [6,25,45] (Watts)
powerRepeater = [6,25,45];

%4
% Repeater Antenna Aperture for Tx
diaRepeaterTx = [0.1,0.2,0.5];

%5
% Repeater Antenna Aperture for Rx
diaRepeaterRx = [0.1,0.2,0.5];

%6
% Dispatch Center Tx Power
powerDispatch = [50,100,200];

%7
% Dispatch Center Antenna Apeture for Tx
diaDispatchTx = [0.05,0.1,0.2]; 

%8
% Dispatch Center Antenna Apeture for Rx
diaDispatchRx = [0.05,0.1,0.2]; 

%9
% Frontend Carrier Data Rate (bps) = [Voice, Video]
frontDataRate = [5000, 100000]; % 5kbps, 100kbps

%10
% Backhaul Carrier Data Rate (between repeater and dispatch center)
backhaulDataRate = [100000, 1000000]; % 100kbps, 1Mbps

%11
% Frontend Available Bandwidth (between radio unit and repeater)
frontendBandwidth = [6.25*1000]; %6.25 kHz

%12
% Backhaul Available Bandwidth (between repeater and dispatch center)
backhaulBandwidth = [12.5*1000]; %12.5 kHz

%13
% Carrier Frequency = [VHF, UHF1, UHF2, 700/800-1, 700/800-2, 700/800-3] (MHz)
carrierFrequency = [155*10^6,425*10^6,485*10^6,770*10^6,815.5*10^6, ...
                        860.5*10^6];

%14
% Vertical height to repeater antenna from either dispatch center or from 
% radio unit (in meters).
% Implicit assumption: dispatch center and radio unit are at same elevation
heightToRepeater = [5,10,15,20,300*1000,400*1000];


%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate size of architecture
%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize an array to hold the array of options for each decision
% In this array, arrayOptionsPerDecisions(1,k) holds the array of options
% for decision k. For example, arrayOptionsPerDecisions(1,6) holds the
% array frontDataRate
arrayOptionsPerDecisions = {powerRadio,...
                            gainRadio,...
                            powerRepeater,...
                            diaRepeaterTx,...
                            diaRepeaterRx,...
                            powerDispatch,...
                            diaDispatchTx,...
                            diaDispatchRx,...
                            frontDataRate,...
                            backhaulDataRate,...
                            frontendBandwidth,...
                            backhaulBandwidth,...
                            carrierFrequency,...
                            heightToRepeater};

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
     c10, c11, c12, c13, c14] = ndgrid(powerRadio,...
                                        gainRadio,...
                                        powerRepeater,...
                                        diaRepeaterTx,...
                                        diaRepeaterRx,...
                                        powerDispatch,...
                                        diaDispatchTx,...
                                        diaDispatchRx,...
                                        frontDataRate,...
                                        backhaulDataRate,...
                                        frontendBandwidth,...
                                        backhaulBandwidth,...
                                        carrierFrequency,...
                                        heightToRepeater);
                    
                    
 architectures = [c1(:), c2(:), c3(:), c4(:), c5(:),...
     c6(:), c7(:), c8(:), c9(:),...
     c10(:), c11(:), c12(:), c13(:), c14(:)];

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
 
 % Initialize matrix for frontend and backend link margins, where:
 %  - Each row corresponds to one possible architecture
 %  - Column 2 is the link margin from a "spoke" (i.e. radio unit or 
 %              dispatch center links) to a "hub" (i.e. the repeater)
 %  - Column 3 is the link margin from the repeater (i.e. the "hub") to one
 %              of the "spokes" (i.e. radio unit or dispatch center)
 %  - Column 1 is the minimum of column 2 and column 3
 frontendLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 backhaulLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 
 % Iterate through each possible architecture 
 for k = 1:1:NUM_POSSIBLE_ARCHS
     
     % For sanity's sake, extract all values for each decision in this
     % architecture
     thisPowerRadio = architectures(k,1);
     thisGainRadio = architectures(k,2);
     thisPowerRepeater = architectures(k,3);
     thisDiaRepeaterTx = architectures(k,4);
     thisDiaRepeaterRx = architectures(k,5);
     thisPowerDispatch = architectures(k,6);
     thisDiaDispatchTx = architectures(k,7);
     thisDiaDispatchRx = architectures(k,8);
     thisFrontDataRate = architectures(k,9);
     thisBackhaulDataRate = architectures(k,10);
     thisFrontendBandwidth = architectures(k,11);
     thisBackhaulBandwidth = architectures(k,12);
     thisCarrierFrequency = architectures(k,13);
     thisHeightToRepeater = architectures(k,14);
     
     % Calculate slant range based on assumed horizontal range, and on this
     % particular architecture's vertical height
     thisSlantRangeRadioToRepeater = sqrt(hozDistanceRadio2Repeater^2 ...
                                    + thisHeightToRepeater^2);
     thisSlantRangeDispatchToRepeater = sqrt(hozDistanceDispatch2Repeater^2 ...
                                    + thisHeightToRepeater^2);
     
     % Find gain for the repeater (Tx and Rx) and dispatch center (Tx and
     % Rx)
     thisGainRepeaterTx = calculateGainFromAntennaDiameter(eff,...
                    thisDiaRepeaterTx,thisCarrierFrequency);
     thisGainRepeaterRx = calculateGainFromAntennaDiameter(eff,...
                    thisDiaRepeaterRx,thisCarrierFrequency);        
     thisGainDispatchTx = calculateGainFromAntennaDiameter(eff,...
                    thisDiaDispatchTx,thisCarrierFrequency);
     thisGainDispatchRx = calculateGainFromAntennaDiameter(eff,...
                    thisDiaDispatchRx,thisCarrierFrequency);
     
                
     %%%%%%%%%%%%
     % Find Eb/No (both calculated and minimum) for FRONTEND links
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (radio unit to repeater)
     thisFrontendEbNoSpoke2Hub = calculateLinearEbNo(thisPowerRadio,...
                            thisGainRadio,...
                            thisGainRepeaterRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisFrontDataRate,...
                            atmLoss);
     
     % Calculated Eb/No from Hub to Spoke (repeater to radio unit)
     thisFrontendEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisDiaRepeaterTx,...
                            thisGainRadio,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisFrontDataRate,...
                            atmLoss);
     
     % Minimum required Eb/No for both directions.
     % Implicit assumption: data rate bandwidth for comm. link in both 
     % directions is the same
     thisFrontendEbNoMin = calculateLinearMinEbNo(thisFrontDataRate,...
                                                  thisFrontendBandwidth);
     
     %%%%%%%%%%%%
     % Find Eb/No (both calculated and minimum) for BACKHAUL links
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (dispatch to repeater)
     thisBackhaulEbNoSpoke2Hub = calculateLinearEbNo(thisPowerDispatch,...
                            thisGainDispatchTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisBackhaulDataRate,...
                            atmLoss);
                        
     % Calculated Eb/No from Hub to Spoke (repeater to dispatch)
     thisBackhaulEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisGainRepeaterTx,...
                            thisGainDispatchRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisBackhaulDataRate,...
                            atmLoss);
                        
     % Minimum required Eb/No for both directions.
     % Implicit assumption: data rate bandwidth for comm. link in both 
     % directions is the same                   
     thisBackhaulEbNoMin = calculateLinearMinEbNo(thisBackhaulDataRate,...
                                                  thisBackhaulBandwidth);
     
                                              
     %%%%%%%%%%%%
     % Calculate link margins for each individual comm. link
     %%%%%%%%%%% 
     
     % Frontend link margin, radio unit to repeater
     frontendLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisFrontendEbNoSpoke2Hub, ...
                                        thisFrontendEbNoMin);
     
     % Frontend link margin, repeater to radio unit
     frontendLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisFrontendEbNoHub2Spoke, ...
                                        thisFrontendEbNoMin);
     
     % Backhaul link margin, dispatch to repeater
     backhaulLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisBackhaulEbNoSpoke2Hub, ...
                                        thisBackhaulEbNoMin);
     
     
     % Backhaul link margin, repeater to dispatch
     backhaulLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisBackhaulEbNoHub2Spoke, ...
                                        thisBackhaulEbNoMin);
                                    
     
     %%%%%%%%%%%%
     % Compute figure of merit for link margins
     % - Minimum of frontend link margins in both directions
     % - Minimum of backhaul link margins in both directions
     %%%%%%%%%%% 
     
     frontendLinkMargins(k,1) = min(frontendLinkMargins(k,2),...
                                    frontendLinkMargins(k,3));
     
     backhaulLinkMargins(k,1) = min(backhaulLinkMargins(k,2),...
                                    backhaulLinkMargins(k,3));
     
 end
 
 %% Visualization
 
 % TODO: make sense out of the effect of 12 different decisions into link
 % margins and other figures of merit

figure
hold on
frontendMarginPlot = plot(sort(frontendLinkMargins(:,2)));
grid
set(frontendMarginPlot,'LineWidth',1);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Frontend Link Margin (minimum of link margin in both directions)')
hold off

figure
hold on
frontendMarginPlot = plot(sort(backhaulLinkMargins(:,1)));
grid
set(frontendMarginPlot,'LineWidth',2);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Backhaul Link Margin (minimum of link margin in both directions)')
hold off

