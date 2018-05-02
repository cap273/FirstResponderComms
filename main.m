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

%% Global definitions
periodOfTimeForCostModel = 15; %years

%% MATLAB Reminders
% Regarding matrix indexing:
% A(2,4)  -> % Extract the element in row 2, column 4
%
% Use square brackets (not curly brackets) to declare a
% matrix of numbers (as opposed to a cell array). Reference:
% https://stackoverflow.com/questions/5966817/difference-between-square-brackets-and-curly-brackets-in-matlab

%% Architecture Definitions for each Communications Network Node

%%%%%%%%%%%%%%%%%%
% For each architectural decision on the type of network node (e.g. the 
% kind of radio unit that first responders will use to communicate, or the 
% type of repeater in the hub-and-spoke network topology), create a variable
% (of data type "structure") that defines the properties of the system as
% a set of key-value pairs (a.k.a. field-value pairs).
%
% The fields in each variable (of data type "structure") are the following:
%
% Name: the name of this node type (for sanity's sake)            
% PurchaseCost: the capital expenses to adquire this subsystem, in US
%               dollars. This will also add to the total cost of ownership
%               at year 0 (when it is initially purchased), plus when the
%               subsystem needs to be repurchased at the end of its usable
%               life.
% MaintenanceCostPerYear: the yearly maintenance costs of this subsystem,
%               in US dollars.
% ExpectedUsableLifeInYears: the expected usable life of this subsystem, in
%               years. At the end of this subsystem's usable life, the 
%               subsystem needs to be repurchased (at a cost defined by the 
%               field purchaseCost)
% RxGainValues OR RxAntennaDiameterValues: an array, where each element of 
%               the array is EITHER 
%                   (a) one possible receiver gain of the node 
%                           (as linear factor, not deciBels), OR
%                   (b) one possible length of the diameter of the
%                           receiver antenna (from which the gain can 
%                           then be calculated)
% RxGainCostMultiplier: an array, where each element of the array is the
%               cost multipler associated with some Rx gain of the node or
%               some Rx antenna diameter of the node.
%               E.g. for an Rx gain of rxGainValues(i), or for a Rx 
%               antenna diameter of rxAntennaDiameterValues(i), the total 
%               cost of this subsystem would be multiplied by 
%               RxGainCostMultiplier(i).
% TxGainValues OR TxAntennaDiameterValues: an array, where each element of 
%               the array is EITHER 
%                   (a) one possible transmitter gain of the node 
%                           (as linear factor, not deciBels), OR
%                   (b) one possible length of the diameter of the
%                           transmitter antenna (from which the gain can 
%                           then be calculated)
% TxGainCostMultiplier: an array, where each element of the array is the
%               cost multipler associated with some Tx gain of the node or
%               some Tx antenna diameter of the node.
%               E.g. for an Tx gain of txGainValues(i), or for a Tx 
%               antenna diameter of txAntennaDiameterValues(i), the total 
%               cost of this subsystem would be multiplied by 
%               txGainCostMultiplier(i).
% TxPowerValues: an array, where each element of the array is one possible 
%               transmitter power of the node, in Watts
% TxPowerCostMultiplier: an array, where each element of the array is the
%               cost multipler associated with some Tx power of the node. 
%               E.g. for an Tx power of txPowerValues(i), the total cost of 
%               this subsystem would be multiplied by 
%               txPowerCostMultiplier(i).
% VerticalHeight: the vertical height (in meters) of this node over ground 
%               level. This value of this field always 0 for the dispatch 
%               center and the portable radio. However, it is a relevant 
%               variable for different repeater types.
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First Responder Radio Options (Node 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Global declarations (across all portable radio types)

%%%% USER INPUT:
% Number of different portable radio overall types
numberOfPortableRadioTypes = 1;

%%% INTERMEDIATE VARIABLES:
portableRadioTypes = cell(1,numberOfPortableRadioTypes);
portableRadioTypesMatrices = cell(1,numberOfPortableRadioTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 1

%%%% USER INPUT:
thisOptionName = "Regular Handheld Radio";
thisOptionPurchaseCost = 1800;
thisOptionMaintenanceCostPerYear = 90;
thisOptionExpectedUsableLifeInYears = 7;
verticalHeight = 0;

% Receiver (Rx) Gain values (as linear factors) and cost multipliers
% Since this is a WIRE antenna, use gain values (instead of antenna sizes)
rxGainValuesArray = [convertToLinearFromdb(10),... % 10 dB
                     convertToLinearFromdb(25)];   % 25 dB
rxGainCostMultiplierArray = [1,1.5];

% Transmitter (Tx) Gain values (as linear factors) and cost multipliers
% Since this is a WIRE antenna, use gain values (instead of antenna sizes)
txGainValuesArray = [convertToLinearFromdb(10),... % 10 dB
                     convertToLinearFromdb(25)];   % 25 dB
txGainCostMultiplierArray = [1,1.5];

% Transmitter (Tx) Power values (as Watts) and cost multipliers
txPowerValuesArray = [6,25,45]; %6W, 25W, 45W
txPowerCostMultiplierArray = [1,1.25,1.5];

%%% INTERMEDIATE VARIABLES:
portableRadioTypes{1,1} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxGainValues',rxGainValuesArray,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxGainValues',txGainValuesArray,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerValuesArray,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
               

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Repeater (Node 2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Global declarations (across all repeater types)

%%%% USER INPUT:

% Number of different portable radio overall types
numberOfRepeaterTypes = 6;

% Repeater Antenna Aperture for Tx (in meters)
diaRepeaterTx = [0.1,0.2,0.5];
txGainCostMultiplierArray = [1,1.25,2];

% Repeater Antenna Aperture for Rx (in meters)
diaRepeaterRx = [0.1,0.2,0.5];
rxGainCostMultiplierArray = [1,1.25,2];

% Repeater Tx Power Options (in Watts)
txPowerRepeater = [6,25,45];
txPowerCostMultiplierArray = [1,2,3];

%%% INTERMEDIATE VARIABLES:
repeaterTypes = cell(1,numberOfRepeaterTypes);
repeaterTypesMatrices = cell(1,numberOfRepeaterTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 1 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Portable Repeater On Ground";
thisOptionPurchaseCost = 2500;
thisOptionMaintenanceCostPerYear = 1250;
thisOptionExpectedUsableLifeInYears = 10;
verticalHeight = 5; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,1} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 2 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Portable Repeater On UAS";
thisOptionPurchaseCost = 2500;
thisOptionMaintenanceCostPerYear = 1250;
thisOptionExpectedUsableLifeInYears = 10;
verticalHeight = 10; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,2} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 3 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Tower Mounted Repeater Low";
thisOptionPurchaseCost = 29025;
thisOptionMaintenanceCostPerYear = 4354;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 15; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,3} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 4 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Tower Mounted Repeater High";
thisOptionPurchaseCost = 29025;
thisOptionMaintenanceCostPerYear = 4354;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 20; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,4} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 5 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Satellite Constellation Repeater Low";
thisOptionPurchaseCost = 0; % No CapEx in renting satellites
thisOptionMaintenanceCostPerYear = 51120;
thisOptionExpectedUsableLifeInYears = 15;
verticalHeight = 300*1000; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,5} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 5 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = "Satellite Constellation Repeater High";
thisOptionPurchaseCost = 0; % No CapEx in renting satellites
thisOptionMaintenanceCostPerYear = 51120;
thisOptionExpectedUsableLifeInYears = 15;
verticalHeight = 400*1000; % (in meters)

%%% INTERMEDIATE VARIABLES:
repeaterTypes{1,6} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaRepeaterRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaRepeaterTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',txPowerRepeater,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dispatch Center (Node 3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Global declarations (across all dispatch center types)

%%%% USER INPUT:
% Number of different portable radio overall types
numberOfDispatchTypes = 3;

% Dispatch Center Antenna Apeture for Tx (in meters)
diaDispatchTx = [0.05,0.1,0.2]; 
txGainCostMultiplierArray = [1,1.25,2];

% Dispatch Center Antenna Apeture for Rx (in meters)
diaDispatchRx = [0.05,0.1,0.2]; 
rxGainCostMultiplierArray = [1,1.25,2];

%%% INTERMEDIATE VARIABLES:
dispatchTypes = cell(1,numberOfDispatchTypes);
dispatchTypesMatrices = cell(1,numberOfDispatchTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 1 Dispatch (Node 3)

%%%% USER INPUT:
thisOptionName = "Dispatch Low Transmit Power";
thisOptionPurchaseCost = 145125;
thisOptionMaintenanceCostPerYear = 45453;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 0; % (in meters)

% Dispatch Center Tx Power Options (in Watts)
powerDispatch = 50;
txPowerCostMultiplierArray = 1;

%%% INTERMEDIATE VARIABLES:
dispatchTypes{1,1} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaDispatchRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaDispatchTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',powerDispatch,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 2 Dispatch (Node 3)

%%%% USER INPUT:
thisOptionName = "Dispatch Medium Transmit Power";
thisOptionPurchaseCost = 181400;
thisOptionMaintenanceCostPerYear = 52767;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 0; % (in meters)

% Dispatch Center Tx Power Options (in Watts)
powerDispatch = 100;
txPowerCostMultiplierArray = 1.1;

%%% INTERMEDIATE VARIABLES:
dispatchTypes{1,2} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaDispatchRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaDispatchTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',powerDispatch,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 3 Dispatch (Node 3)

%%%% USER INPUT:
thisOptionName = "Dispatch High Transmit Power";
thisOptionPurchaseCost = 464400;
thisOptionMaintenanceCostPerYear = 69660;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 0; % (in meters)

% Dispatch Center Tx Power Options (in Watts)
powerDispatch = 200;
txPowerCostMultiplierArray = 1.2;

%%% INTERMEDIATE VARIABLES:
dispatchTypes{1,3} = struct('Name',thisOptionName,...
        'PurchaseCost',thisOptionPurchaseCost,...
        'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
        'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
        'VerticalHeight',verticalHeight,...
        'RxAntennaDiameterValues',diaDispatchRx,...
        'RxGainCostMultiplier',rxGainCostMultiplierArray,...
        'TxAntennaDiameterValues',diaDispatchTx,...
        'TxGainCostMultiplier',txGainCostMultiplierArray,...
        'TxPowerValues',powerDispatch,...
        'TxPowerCostMultiplier',txPowerCostMultiplierArray);
    
%% Architecture Definitions for Communications Channel
% Frontend Carrier Data Rate (between radio unit and repeater)
% Backhaul Carrier Data Rate (between repeater and dispatch center)
% Frontend Available Bandwidth (between radio unit and repeater)
% Backhaul Carrier Data Rate (between repeater and dispatch center)
% Carrier Frequency (assuming one global center frequency for all links)
% Frontend Carrier Data Rate

%%%% USER INPUT:
frontDataRate = [5000, 100000]; % 5kbps, 100kbps

% Backhaul Carrier Data Rate (between repeater and dispatch center)
backhaulDataRate = [100000, 1000000]; % 100kbps, 1Mbps

% Frontend Available Bandwidth (between radio unit and repeater)
frontendBandwidth = [6.25*1000]; %6.25 kHz

% Backhaul Available Bandwidth (between repeater and dispatch center)
backhaulBandwidth = [12.5*1000]; %12.5 kHz

% Carrier Frequency = [VHF, UHF1, UHF2, 700/800-1, 700/800-2, 700/800-3] (MHz)
carrierFrequency = [155*10^6,425*10^6,485*10^6,770*10^6,815.5*10^6, ...
                        860.5*10^6];
               
%% Architecture Enumeration - Intermediate
% Find matrices containing the architecture enumeration for:
%   Node Type 1 (portable radio unit)
%   Node Type 2 (Repeater)
%   Node Type 3 (Dispatch Center)
%   Channel (e.g. bandwidth, data rate, etc.)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Node 1 (Portable Unit)
%%%%%%%%%%%%%%%%%%%%%%%%

% For each option for this particular node type (portable unit), calculate
% all possible architectures
for k = 1:1:numberOfPortableRadioTypes
    
    % Get the matrix of all possible architectures.
    % Each column contains the following information (in order from 1 to
    % 10):
    %     'PurchaseCost'
    %     'MaintenanceCostPerYear'
    %     'ExpectedUsableLifeInYears'
    %     'VerticalHeight'
    %     'RxGainValues'
    %     'RxGainCostMultiplier'
    %     'TxGainValues'
    %     'TxGainCostMultiplier'
    %     'TxPowerValues'
    %     'TxPowerCostMultiplier'
    %
    % Also note that this node type specifies a linear gain (as it is a
    % wire antenna), and does not specify antenna diameter
    [portableRadioTypesMatrices{1,k},~] = ...
        enumNodeArchitectures(portableRadioTypes{1,k},"linearGain");
end

% Once all architecture matrices for each option has been retrieved,
% vertically concatenate these matrices to produce a single matrix. This
% single matrix now enumerates all possible architectures for this node
% type.
subsetArchsPortableRadios = vertcat(portableRadioTypesMatrices{1,:});

% This matrix still contains 10 columns. Create table to carry 
% column names
subsetArchsPortableRadiosTable = array2table(subsetArchsPortableRadios,...
            'VariableNames',{'PurchaseCost',...
                            'MaintenanceCostPerYear',...
                            'ExpectedUsableLifeInYears',...
                            'VerticalHeight',...
                            'RxGainValues',...
                            'RxGainCostMultiplier',...
                            'TxGainValues',...
                            'TxGainCostMultiplier',...
                            'TxPowerValues',...
                            'TxPowerCostMultiplier'});

%%%%%%%%%%%%%%%%%%%%%%%%%
% Node 2 (Repeater)
%%%%%%%%%%%%%%%%%%%%%%%%

% For each option for this particular node type (portable unit), calculate
% all possible architectures
for k = 1:1:numberOfRepeaterTypes
    
    % Get the matrix of all possible architectures.
    % Each column contains the following information (in order from 1 to
    % 10):
    %   'PurchaseCost'
    %   'MaintenanceCostPerYear'
    %   'ExpectedUsableLifeInYears'
    %   'VerticalHeight'
    %   'RxAntennaDiameterValues'
    %   'RxGainCostMultiplier'
    %   'TxAntennaDiameterValues'
    %   'TxGainCostMultiplier'
    %   'TxPowerValues'
    %   'TxPowerCostMultiplier'
    %
    % Also note that this node type specifies an antenna diameter (instead
    % of a linear gain). The linear gain can be calculated from the antenna
    % diameter
    [repeaterTypesMatrices{1,k},~] = ...
        enumNodeArchitectures(repeaterTypes{1,k},"antennaDiameter");
end

% Vertically concatenate to produce architecture enumeration for all
% repeater combinations
subsetArchsRepeaters = vertcat(repeaterTypesMatrices{1,:});

% This matrix still contains 10 columns. Create table to carry 
% column names
subsetArchsRepeatersTable = array2table(subsetArchsRepeaters,...
            'VariableNames',{'PurchaseCost',...
                            'MaintenanceCostPerYear',...
                            'ExpectedUsableLifeInYears',...
                            'VerticalHeight',...
                            'RxAntennaDiameterValues',...
                            'RxGainCostMultiplier',...
                            'TxAntennaDiameterValues',...
                            'TxGainCostMultiplier',...
                            'TxPowerValues',...
                            'TxPowerCostMultiplier'});

%%%%%%%%%%%%%%%%%%%%%%%%%
% Node 3 (Dispatch Center)
%%%%%%%%%%%%%%%%%%%%%%%%

% For each option for this particular node type (portable unit), calculate
% all possible architectures
for k = 1:1:numberOfDispatchTypes
    
    % Get the matrix of all possible architectures.
    % Each column contains the following information (in order from 1 to
    % 10):
    %   'PurchaseCost'
    %   'MaintenanceCostPerYear'
    %   'ExpectedUsableLifeInYears'
    %   'VerticalHeight'
    %   'RxAntennaDiameterValues'
    %   'RxGainCostMultiplier'
    %   'TxAntennaDiameterValues'
    %   'TxGainCostMultiplier'
    %   'TxPowerValues'
    %   'TxPowerCostMultiplier'
    %
    % Also note that this node type specifies an antenna diameter (instead
    % of a linear gain). The linear gain can be calculated from the antenna
    % diameter
    [dispatchTypesMatrices{1,k},~] = ...
        enumNodeArchitectures(dispatchTypes{1,k},"antennaDiameter");
end

% Vertically concatenate to produce architecture enumeration for all
% dispatch center combinations
subsetArchsDispatchCenter = vertcat(dispatchTypesMatrices{1,:});

% This matrix still contains 10 columns. Create table to carry 
% column names
subsetArchsDispatchCenterTable = array2table(subsetArchsDispatchCenter,...
            'VariableNames',{'PurchaseCost',...
                            'MaintenanceCostPerYear',...
                            'ExpectedUsableLifeInYears',...
                            'VerticalHeight',...
                            'RxAntennaDiameterValues',...
                            'RxGainCostMultiplier',...
                            'TxAntennaDiameterValues',...
                            'TxGainCostMultiplier',...
                            'TxPowerValues',...
                            'TxPowerCostMultiplier'});

%%%%%%%%%%%%%%%%%%%%%%%%%
% Communications Channel
%%%%%%%%%%%%%%%%%%%%%%%%

% Find all combinations of all the independent channel properties
subsetArchsChannel = allcomb(frontDataRate,...
                              backhaulDataRate,...
                              frontendBandwidth,...
                              backhaulBandwidth,...
                              carrierFrequency);

% Create a table to carry the column names in this matrix
subsetArchsChannelTable = array2table(subsetArchsChannel,...
            'VariableNames',{'FrontDataRate',...
                            'BackhaulDataRate',...
                            'FrontendBandwidth',...
                            'BackhaulBandwidth',...
                            'carrierFrequency'});
                        
%% Architecture Enumeration - Final
% Create an M x N matrix, where each row in the matrix represents one 
% complete architecture definition. 
%   N represents the number of numeric factors in the architecture (where
%       not all numeric factors are independent decisions of each other)
%   M is the number of possible architectures

% The architecture enumeration is the cross join (aka cartesian product) of
% the following matrices:
%   subsetArchsPortableRadios
%   subsetArchsRepeaters
%   subsetArchsDispatchCenter
%   subsetArchsChannel
architectures = recursiveCrossJoin(subsetArchsPortableRadios,...
                                   subsetArchsRepeaters,... 
                                   subsetArchsDispatchCenter,...
                                   subsetArchsChannel);
                               
% Also create table to carry column names
architecturesTable = array2table(architectures,...
            'VariableNames',{'PortableRadioPurchaseCost',...
                            'PortableRadioMaintenanceCostPerYear',...
                            'PortableRadioExpectedUsableLifeInYears',...
                            'PortableRadioVerticalHeight',...
                            'PortableRadioRxGainValues',...
                            'PortableRadioRxGainCostMultiplier',...
                            'PortableRadioTxGainValues',...
                            'PortableRadioTxGainCostMultiplier',...
                            'PortableRadioTxPowerValues',...
                            'PortableRadioTxPowerCostMultiplier',...
                            'RepeaterPurchaseCost',...
                            'RepeaterMaintenanceCostPerYear',...
                            'RepeaterExpectedUsableLifeInYears',...
                            'RepeaterVerticalHeight',...
                            'RepeaterRxAntennaDiameterValues',...
                            'RepeaterRxGainCostMultiplier',...
                            'RepeaterTxAntennaDiameterValues',...
                            'RepeaterTxGainCostMultiplier',...
                            'RepeaterTxPowerValues',...
                            'RepeaterTxPowerCostMultiplier',...
                            'DispatchPurchaseCost',...
                            'DispatchMaintenanceCostPerYear',...
                            'DispatchExpectedUsableLifeInYears',...
                            'DispatchVerticalHeight',...
                            'DispatchRxAntennaDiameterValues',...
                            'DispatchRxGainCostMultiplier',...
                            'DispatchTxAntennaDiameterValues',...
                            'DispatchTxGainCostMultiplier',...
                            'DispatchTxPowerValues',...
                            'DispatchTxPowerCostMultiplier',...
                            'FrontDataRate',...
                            'BackhaulDataRate',...
                            'FrontendBandwidth',...
                            'BackhaulBandwidth',...
                            'carrierFrequency'});

% Establish number of possible architectures
NUM_POSSIBLE_ARCHS = size(architectures,1);

 %% Architecture Evaluation
 
 %%%%%%%%%%%%%%%%%%%%
 % Make general assumptions
 %%%%%%%%%%%%%%%%%%%%
 
 % Antenna aperture efficiency (for both dispatch and repeater)
 eff = 0.55;
 
 % Temperature (in Kelvin) of receiving antenna, for all antennas
 Tr = 300;

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
     thisPowerRadio = architectures(k,9);
     thisGainRadioTx = architectures(k,7);
     thisGainRadioRx = architectures(k,5);
     
     thisPowerRepeater = architectures(k,19);
     thisDiaRepeaterTx = architectures(k,17);
     thisDiaRepeaterRx = architectures(k,15);
     
     thisPowerDispatch = architectures(k,29);
     thisDiaDispatchTx = architectures(k,17);
     thisDiaDispatchRx = architectures(k,15);
     
     thisFrontDataRate = architectures(k,31);
     thisBackhaulDataRate = architectures(k,32);
     thisFrontendBandwidth = architectures(k,33);
     thisBackhaulBandwidth = architectures(k,34);
     thisCarrierFrequency = architectures(k,35);
     
     % Repeater vertical height, assuming dispatch center and portable
     % radio units are at vertical height = 0
     thisHeightToRepeater = architectures(k,24); 
     
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
                            thisGainRadioTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            Tr,...
                            thisFrontDataRate,...
                            atmLoss);
     
     % Calculated Eb/No from Hub to Spoke (repeater to radio unit)
     thisFrontendEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisDiaRepeaterTx,...
                            thisGainRadioRx,...
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
 
%%%%%%%%%%%%%%%%%%%%%%%
% For each architecture, calculate total cost of ownership over a period 
% specified by periodOfTimeForCostModel
%%%%%%%%%%%%%%%%%%%%%%%

% Initialize matrix for cost calculations, where:
 %  - Each row corresponds to one possible architecture
 %  - Column 1 is the TCO for Node 1 (the portable radio)
 %  - Column 2 is the TCO for Node 2 (the repeater)
 %  - Column 3 is the TCO for Node 3 (the dispatch center)
 %  - Column 4 is the sum of columns 1 through 3
 totalCost = zeros(NUM_POSSIBLE_ARCHS,3);

  % Iterate through each possible architecture 
 for k = 1:1:NUM_POSSIBLE_ARCHS
     
     % Calculate overall cost multipliers for Node 1, Node 2, and Node 3
     % (where column 1 corresponds to the multiplier for Node 1)
     nodeMultipliers = zeros(1,3);
     nodeMultipliers(1,1) = architectures(k,6)*architectures(k,8)*architectures(k,10);
     nodeMultipliers(1,2) = architectures(k,16)*architectures(k,18)*architectures(k,20);
     nodeMultipliers(1,3) = architectures(k,26)*architectures(k,28)*architectures(k,30);
     
     % Calculate TCO for each Node
     totalCost(k,1) = calculateNodeCost(architectures(k,1),...
                                        architectures(k,2),...
                                        architectures(k,3),...
                                        periodOfTimeForCostModel,...
                                        nodeMultipliers(1,1));
     
     totalCost(k,2) = calculateNodeCost(architectures(k,11),...
                                        architectures(k,12),...
                                        architectures(k,13),...
                                        periodOfTimeForCostModel,...
                                        nodeMultipliers(1,2));
                                    
     totalCost(k,3) = calculateNodeCost(architectures(k,21),...
                                        architectures(k,22),...
                                        architectures(k,23),...
                                        periodOfTimeForCostModel,...
                                        nodeMultipliers(1,3));
      
     % Sum up cost across all three nodes
     totalCost(k,4) = sum(totalCost(k,1:3));
 end
 
 %% Visualization
 
 % TODO: make sense out of the effect of 12 different decisions into link
 % margins and other figures of merit

figure
hold on
frontendMarginPlot = plot(sort(frontendLinkMargins(:,1)));
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

figure
hold on
costPlot = scatter(totalCost(:,4),frontendLinkMargins(:,1),5);
grid
set(costPlot,'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',0.2);
xlabel('Total Cost of Ownership over 15 years (USD)')
ylabel('Link Margin, dB')
title('Frontend Link Margin vs TCO')
hold off

