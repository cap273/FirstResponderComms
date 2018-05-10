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

% Parent front algorithm runs in quadratic time. Very slow for large number
% of possible architectures. Runs in quadratic time O(N^2), where N is the 
% number of architectures. Set 1 to run Pareto front analysis, 0
% otherwise.
runParetoFrontAnalysis = 0;

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
thisOptionName = 'Regular Handheld Radio';
thisOptionPurchaseCost = 1800;
thisOptionMaintenanceCostPerYear = 90;
thisOptionExpectedUsableLifeInYears = 7;
verticalHeight = 0;

% Receiver (Rx) Gain values (as linear factors) and cost multipliers
% Since this is a WIRE antenna, use gain values (instead of antenna sizes)
rxGainValuesArray = [convertToLinearFromdb(0),... % 0 dB
                     convertToLinearFromdb(3)];   % 3 dB
rxGainCostMultiplierArray = [1,1.25];

% Transmitter (Tx) Gain values (as linear factors) and cost multipliers
% Since this is a WIRE antenna, use gain values (instead of antenna sizes)
txGainValuesArray = [convertToLinearFromdb(0),... % 0 dB
                     convertToLinearFromdb(3)];   % 3 dB
txGainCostMultiplierArray = [1,1.25];

% Transmitter (Tx) Power values (as Watts) and cost multipliers
txPowerValuesArray = [1,3,6]; %1W,3W,6W
txPowerCostMultiplierArray = [1,1.5,2];

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
txGainCostMultiplierArray = [1,1.2,1.5];

% Repeater Antenna Aperture for Rx (in meters)
diaRepeaterRx = [0.1,0.2,0.5];
rxGainCostMultiplierArray = [1,1.2,1.5];

% Repeater Tx Power Options (in Watts)
txPowerRepeater = [45,100,200];
txPowerCostMultiplierArray = [1,1.4,1.8];

%%% INTERMEDIATE VARIABLES:
repeaterTypes = cell(1,numberOfRepeaterTypes);
repeaterTypesMatrices = cell(1,numberOfRepeaterTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 1 Repeaters (Node 2)

%%%% USER INPUT:
thisOptionName = 'Portable Repeater On Ground';
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
thisOptionName = 'Portable Repeater On UAS';
thisOptionPurchaseCost = 9300;
thisOptionMaintenanceCostPerYear = 2270;
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
thisOptionName = 'Tower Mounted Repeater Low';
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
thisOptionName = 'Tower Mounted Repeater High';
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
thisOptionName = 'Satellite Constellation Repeater Low';
thisOptionPurchaseCost = 0; % No CapEx in renting satellites
thisOptionMaintenanceCostPerYear = 66120; % Annual use and percenatge of annual maintenance
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
thisOptionName = 'Satellite Constellation Repeater High';
thisOptionPurchaseCost = 0; % No CapEx in renting satellites
thisOptionMaintenanceCostPerYear = 66120; %Annual use and percenatge of annual maintenanc
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
diaDispatchTx = [0.5,1,2]; 
txGainCostMultiplierArray = [1,2,4];

% Dispatch Center Antenna Apeture for Rx (in meters)
diaDispatchRx = [0.5,1,2]; 
rxGainCostMultiplierArray = [1,2,4];

%%% INTERMEDIATE VARIABLES:
dispatchTypes = cell(1,numberOfDispatchTypes);
dispatchTypesMatrices = cell(1,numberOfDispatchTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option 1 Dispatch (Node 3)

%%%% USER INPUT:
thisOptionName = 'Dispatch Low Transmit Power';
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
thisOptionName = 'Dispatch Medium Transmit Power';
thisOptionPurchaseCost = 181400;
thisOptionMaintenanceCostPerYear = 52767;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 0; % (in meters)

% Dispatch Center Tx Power Options (in Watts)
powerDispatch = 100;
txPowerCostMultiplierArray = 1;

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
thisOptionName = 'Dispatch High Transmit Power';
thisOptionPurchaseCost = 464400;
thisOptionMaintenanceCostPerYear = 69660;
thisOptionExpectedUsableLifeInYears = 20;
verticalHeight = 0; % (in meters)

% Dispatch Center Tx Power Options (in Watts)
powerDispatch = 200;
txPowerCostMultiplierArray = 1;

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
frontDataRate = 5000; % 5kbps

% Backhaul Carrier Data Rate (between repeater and dispatch center)
backhaulDataRate = 100000; % 100kbps

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

 fprintf('Enumerating possible architectures...\n');
 
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
        enumNodeArchitectures(portableRadioTypes{1,k},'linearGain');
end

% Once all architecture matrices for each option has been retrieved,
% vertically concatenate these matrices to produce a single matrix. This
% single matrix now enumerates all possible architectures for this node
% type.
% Diagram for this process: 
% https://github.com/cap273/FirstResponderComms/blob/master/verticalConcatOptionsAcrossNodeType.png
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
        enumNodeArchitectures(repeaterTypes{1,k},'antennaDiameter');
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
        enumNodeArchitectures(dispatchTypes{1,k},'antennaDiameter');
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
 
 fprintf('Evaluating possible architectures against Figures of Merit...\n');
 
 %%%%%%%%%%%%%%%%%%%%
 % Make general assumptions
 %%%%%%%%%%%%%%%%%%%%
 
 % Antenna aperture efficiency (for both dispatch and repeater)
 eff = 0.55;

 % Horizontal distance to repeater, for radio unit and for dispatch
 hozDistanceRadio2Repeater = 10000; %10km
 hozDistanceDispatch2Repeater = 3000; %3km
 
 % Define some amount of atmospheric loss under best-case conditions (i.e.
 % without considering propagation losses through fire/smoke or foliage)
 bestCaseAtmLoss = convertToLinearFromdb(0);
 
 % Maximum height of foliage cover (in meters)
 % Reference: https://github.com/cap273/FirstResponderComms/blob/master/foliageLossModel.png
 foliageCoverHeight = 12.5; %12.5 meters
 
 % Maximum height of smoke/fire cover (in meters)
 % Reference: https://github.com/cap273/FirstResponderComms/blob/master/fireLossModel.png
 fireCoverHeight = 100; %100m
 
 % Maximum horizontal distance of foliage cover, and of fire/smoke cover
 % (in meters) from spoke
 % References:
 % https://github.com/cap273/FirstResponderComms/blob/master/foliageLossModel.png
 % https://github.com/cap273/FirstResponderComms/blob/master/fireLossModel.png
 maxFoliageHorizontalCoverFromRadio = hozDistanceRadio2Repeater*0.05;
 maxFireHorizontalCoverFromRadio = hozDistanceRadio2Repeater*0.05;
 maxFoliageHorizontalCoverFromDispatch = hozDistanceDispatch2Repeater*0.05;
 maxFireHorizontalCoverFromDispatch = hozDistanceDispatch2Repeater*0.05;
 
 
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
 % These are BEST CASE scenarios (i.e. without taking into account
 % propagation path losses due to smoke/fire or foliage)
 bestCaseFrontendLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 bestCaseBackhaulLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 
 
  % Initialize matrix for frontend and backend link margins, where:
 %  - Each row corresponds to one possible architecture
 %  - Column 2 is the link margin from a "spoke" (i.e. radio unit or 
 %              dispatch center links) to a "hub" (i.e. the repeater)
 %  - Column 3 is the link margin from the repeater (i.e. the "hub") to one
 %              of the "spokes" (i.e. radio unit or dispatch center)
 %  - Column 1 is the minimum of column 2 and column 3
 % These are WORST CASE scenarios (i.e. including propagation path losses 
 % due to smoke/fire or foliage)
 worstCaseFrontendLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 worstCaseBackhaulLinkMargins = zeros(NUM_POSSIBLE_ARCHS,3);
 
 
 % Initialize matrix for propagation path losses 
 % (for possible future analysis), where:
 %  - Each row corresponds to one possible architecture
 %  - Column 1 is worst-case propagation path loss due to smoke/fire for
 %              portable radio to repeater
 %  - Column 2 is worst-case propagation path loss due to foliage for
 %              portable radio to repeater
 %  - Column 3 is worst-case propagation path loss due to smoke/fire for
 %              dispatch center to repeater
 %  - Column 4 is worst-case propagation path loss due to foliage for
 %              dispatch center to repeater
 propagationPathLosses = zeros(NUM_POSSIBLE_ARCHS,4);
 
 % Initialize matrix for propagation path length
 % (for possible future analysis), where:
 %  - Each row corresponds to one possible architecture
 %  - Column 1 is worst-case propagation path lenght due to smoke/fire for
 %              portable radio to repeater
 %  - Column 2 is worst-case propagation path lenght due to foliage for
 %              portable radio to repeater
 %  - Column 3 is worst-case propagation path lenght due to smoke/fire for
 %              dispatch center to repeater
 %  - Column 4 is worst-case propagation path lenght due to foliage for
 %              dispatch center to repeater
 propagationPathLengths = zeros(NUM_POSSIBLE_ARCHS,4);
 
 % Iterate through each possible architecture 
 for k = 1:1:NUM_POSSIBLE_ARCHS
     
     %%%%%%%%%%%%
     % Extract and calculate properties for this architecture
     %%%%%%%%%%% 
     
     
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
     thisHeightToRepeater = architectures(k,14); %RepeaterVerticalHeight
     
     % Temperature (in Kelvin) of receiving antenna, for all spoke (i.e.
     % non-repeater) nodes
     TrSpoke = 290;
     
     % Temperature (in Kelvin) of receiving antenna, for hub (i.e.
     % repeater) nodes. Might be dependent on whether the repeater is in the
     % atmosphere (ground-based or aerial-based repeater) or whether it is
     % a space-based repeater
     if architectures(k,24) > (160*1000)
        % If this repeater has a vertical height of more than 160km, then
        % consider it a space-based repeater.
        % From Wikipedia: "Objects below approximately 160 km (99 mi) will 
        % experience very rapid orbital decay and altitude loss due to 
        % atmospheric drag."
        % https://en.wikipedia.org/wiki/Low_Earth_orbit
        TrHub = 290;
     else
        TrHub = 290;
     end
     
     % Calculate slant range based on assumed horizontal range, and on this
     % particular architecture's vertical height to the repeater
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
     
     % Find maximum propagation path lenghts for foliage cover (in 
     % worst-case scenario)
     maxFoliagePathRadioToRepeater = calculatePropagationPath(thisSlantRangeRadioToRepeater,...
                                                              thisHeightToRepeater,...
                                                              foliageCoverHeight,...
                                                              hozDistanceRadio2Repeater,...
                                                              maxFoliageHorizontalCoverFromRadio);
     maxFoliagePathDispatchToRepeater = calculatePropagationPath(thisSlantRangeDispatchToRepeater,...
                                                              thisHeightToRepeater,...
                                                              foliageCoverHeight,...
                                                              hozDistanceDispatch2Repeater,...
                                                              maxFoliageHorizontalCoverFromDispatch);
     
     % Find maximum propagation path lenghts for fire/smoke cover 
     % (in worst-case scenario)
     maxFirePathRadioToRepeater = calculatePropagationPath(thisSlantRangeRadioToRepeater,...
                                                              thisHeightToRepeater,...
                                                              fireCoverHeight,...
                                                              hozDistanceRadio2Repeater,...
                                                              maxFireHorizontalCoverFromRadio);
     maxFirePathDispatchToRepeater = calculatePropagationPath(thisSlantRangeDispatchToRepeater,...
                                                              thisHeightToRepeater,...
                                                              fireCoverHeight,...
                                                              hozDistanceDispatch2Repeater,...
                                                              maxFireHorizontalCoverFromDispatch);
     
     % Record propagation path length 
     propagationPathLengths(k,1) = maxFirePathRadioToRepeater;
     propagationPathLengths(k,2) = maxFoliagePathRadioToRepeater;
     propagationPathLengths(k,3) = maxFirePathDispatchToRepeater;
     propagationPathLengths(k,4) = maxFoliagePathDispatchToRepeater;
     
     % Find (linear) losses in worst-case scenario for propagation through foliage
     foliageLossRadioToRepeater = calculateFoliageLoss(maxFoliagePathRadioToRepeater,thisCarrierFrequency);
     foliageLossDispatchToRepeater = calculateFoliageLoss(maxFoliagePathDispatchToRepeater,thisCarrierFrequency);                                              
     
     % Find (linear) losses in worst-case scenario for propagation through fire/smoke
     fireLossRadioToRepeater = calculateFoliageLoss(maxFirePathRadioToRepeater,thisCarrierFrequency);
     fireLossDispatchToRepeater = calculateFoliageLoss(maxFirePathDispatchToRepeater,thisCarrierFrequency);  
     
     % Record propagation path losses
     propagationPathLosses(k,1) = fireLossRadioToRepeater;
     propagationPathLosses(k,2) = foliageLossRadioToRepeater;
     propagationPathLosses(k,3) = fireLossDispatchToRepeater;
     propagationPathLosses(k,4) = foliageLossDispatchToRepeater;
     
     
     %%%%%%%%%%%%
     % Find calculated Eb/No for FRONTEND links in the
     % BEST CASE scenario (i.e. without losses due to fire/smoke or foliage
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (radio unit to repeater)
     thisBestCaseFrontendEbNoSpoke2Hub = calculateLinearEbNo(thisPowerRadio,...
                            thisGainRadioTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            TrHub,...
                            thisFrontDataRate,...
                            bestCaseAtmLoss);
     
     % Calculated Eb/No from Hub to Spoke (repeater to radio unit)
     thisBestCaseFrontendEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisDiaRepeaterTx,...
                            thisGainRadioRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            TrSpoke,...
                            thisFrontDataRate,...
                            bestCaseAtmLoss);
     
     %%%%%%%%%%%%
     % Find calculated Eb/No for FRONTEND links in the WORST CASE scenario 
     % (i.e. taking into account losses due to fire/smoke and foliage
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (radio unit to repeater)
     thisWorstCaseFrontendEbNoSpoke2Hub = calculateLinearEbNo(thisPowerRadio,...
                            thisGainRadioTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            TrHub,...
                            thisFrontDataRate,...
                            (fireLossRadioToRepeater*foliageLossRadioToRepeater));
     
     % Calculated Eb/No from Hub to Spoke (repeater to radio unit)
     thisWorstCaseFrontendEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisDiaRepeaterTx,...
                            thisGainRadioRx,...
                            thisSlantRangeRadioToRepeater,...
                            thisCarrierFrequency,...
                            TrSpoke,...
                            thisFrontDataRate,...
                            (fireLossRadioToRepeater*foliageLossRadioToRepeater));
     
     %%%%%%%%%%%%
     % Minimum required Eb/No for both directions for FRONTEND link
     % Implicit assumption: data rate bandwidth for comm. link in both 
     % directions (spoke-2-hub and hub-to-spoke) is the same
     %%%%%%%%%%% 
     thisFrontendEbNoMin = calculateLinearMinEbNo(thisFrontDataRate,...
                                                  thisFrontendBandwidth);
     
     %%%%%%%%%%%%
     % Find calculated Eb/No for BACKHAUL links in the
     % BEST CASE scenario (i.e. without losses due to fire/smoke or foliage
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (dispatch to repeater)
     thisBestCaseBackhaulEbNoSpoke2Hub = calculateLinearEbNo(thisPowerDispatch,...
                            thisGainDispatchTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            TrHub,...
                            thisBackhaulDataRate,...
                            bestCaseAtmLoss);
                        
     % Calculated Eb/No from Hub to Spoke (repeater to dispatch)
     thisBestCaseBackhaulEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisGainRepeaterTx,...
                            thisGainDispatchRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            TrSpoke,...
                            thisBackhaulDataRate,...
                            bestCaseAtmLoss);
                        
     %%%%%%%%%%%%
     % Find calculated Eb/No for BACKHAUL links in the WORST CASE scenario 
     % (i.e. taking into account losses due to fire/smoke and foliage
     %%%%%%%%%%% 
     
     % Calculated Eb/No from Spoke to Hub (dispatch to repeater)
     thisWorstCaseBackhaulEbNoSpoke2Hub = calculateLinearEbNo(thisPowerDispatch,...
                            thisGainDispatchTx,...
                            thisGainRepeaterRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            TrHub,...
                            thisBackhaulDataRate,...
                            (fireLossDispatchToRepeater*foliageLossDispatchToRepeater));
                        
     % Calculated Eb/No from Hub to Spoke (repeater to dispatch)
     thisWorstCaseBackhaulEbNoHub2Spoke = calculateLinearEbNo(thisPowerRepeater,...
                            thisGainRepeaterTx,...
                            thisGainDispatchRx,...
                            thisSlantRangeDispatchToRepeater,...
                            thisCarrierFrequency,...
                            TrSpoke,...
                            thisBackhaulDataRate,...
                            (fireLossDispatchToRepeater*foliageLossDispatchToRepeater));
     
     %%%%%%%%%%%%
     % Minimum required Eb/No for both directions for BACKHAUL link
     % Implicit assumption: data rate bandwidth for comm. link in both 
     % directions (spoke-2-hub and hub-to-spoke) is the same
     %%%%%%%%%%%                   
     thisBackhaulEbNoMin = calculateLinearMinEbNo(thisBackhaulDataRate,...
                                                  thisBackhaulBandwidth);
     
                                              
     %%%%%%%%%%%%
     % Calculate link margins for each individual comm. link
     %%%%%%%%%%% 
     
     % Frontend link margin, radio unit to repeater
     bestCaseFrontendLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisBestCaseFrontendEbNoSpoke2Hub, ...
                                        thisFrontendEbNoMin);
     worstCaseFrontendLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisWorstCaseFrontendEbNoSpoke2Hub, ...
                                        thisFrontendEbNoMin);
                                    
     
     % Frontend link margin, repeater to radio unit
     bestCaseFrontendLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisBestCaseFrontendEbNoHub2Spoke, ...
                                        thisFrontendEbNoMin);
     worstCaseFrontendLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisWorstCaseFrontendEbNoHub2Spoke, ...
                                        thisFrontendEbNoMin);
     
     % Backhaul link margin, dispatch to repeater
     bestCaseBackhaulLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisBestCaseBackhaulEbNoSpoke2Hub, ...
                                        thisBackhaulEbNoMin);
     worstCaseBackhaulLinkMargins(k,2) = findLinkMarginIndB(...
                                        thisWorstCaseBackhaulEbNoSpoke2Hub, ...
                                        thisBackhaulEbNoMin);
     
     % Backhaul link margin, repeater to dispatch
     bestCaseBackhaulLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisBestCaseBackhaulEbNoHub2Spoke, ...
                                        thisBackhaulEbNoMin);
     worstCaseBackhaulLinkMargins(k,3) = findLinkMarginIndB(...
                                        thisWorstCaseBackhaulEbNoHub2Spoke, ...
                                        thisBackhaulEbNoMin);                               
     
     %%%%%%%%%%%%
     % Compute figure of merit for link margins
     % - Minimum of frontend link margins in both directions
     % - Minimum of backhaul link margins in both directions
     %%%%%%%%%%% 

     bestCaseFrontendLinkMargins(k,1) = min(bestCaseFrontendLinkMargins(k,2),...
                                    bestCaseFrontendLinkMargins(k,3));
     worstCaseFrontendLinkMargins(k,1) = min(worstCaseFrontendLinkMargins(k,2),...
                                    worstCaseFrontendLinkMargins(k,3));
     
     bestCaseBackhaulLinkMargins(k,1) = min(bestCaseBackhaulLinkMargins(k,2),...
                                    bestCaseBackhaulLinkMargins(k,3));
     worstCaseBackhaulLinkMargins(k,1) = min(worstCaseBackhaulLinkMargins(k,2),...
                                    worstCaseBackhaulLinkMargins(k,3));
                                
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
 
 %% Pareto front
 
 if (runParetoFrontAnalysis == 1)
     % Initialize array where entry i is equal to 1 if architecture i is 
     % dominated, zero otherwise
     isDominated = false(NUM_POSSIBLE_ARCHS,1);

     fprintf('Calculating Pareto front...\n');
     tic
     % Iterate through each possible architecture 
     parfor i = 1:1:NUM_POSSIBLE_ARCHS

         % Iterate through each other possible architecture
         for j = 1:1:NUM_POSSIBLE_ARCHS
             if i ~= j

                 % Initialize 5-by-1 array, where each entry is true if
                 % architecture i is dominated by architecture j in one
                 % particular figure of merit, false otherwise
                 figuresOfMeritDominated = zeros(5,1);

                 % Compare architecture i against architecture j in all 5
                 % figures of merit
                 figuresOfMeritDominated(1,1) = bestCaseFrontendLinkMargins(j,1) > bestCaseFrontendLinkMargins(i,1);
                 figuresOfMeritDominated(2,1) = worstCaseFrontendLinkMargins(j,1) > worstCaseFrontendLinkMargins(i,1);
                 figuresOfMeritDominated(3,1) = bestCaseBackhaulLinkMargins(j,1) > bestCaseBackhaulLinkMargins(i,1);
                 figuresOfMeritDominated(4,1) = worstCaseBackhaulLinkMargins(j,1) > worstCaseBackhaulLinkMargins(i,1);
                 figuresOfMeritDominated(5,1) = totalCost(j,4) < totalCost(i,4);

                 % If architecture j is better than architecture i in all 
                 % figures of merit, mark i as being dominated
                 if prod(figuresOfMeritDominated)
                      isDominated(i,1) = 1;
                      break;
                 end              
             end
         end   
     end
     fprintf('Pareto front calculation complete.\n');
     tElapsed = toc;
     fprintf(['Elapsed time to complete Pareto front analysis (in seconds): ' int2str(round(tElapsed)) '\n']);
 end
 
 
 %% Visualization
 
 fprintf('Visualization activities...\n');
  
% Specify an architecture to highlight (by its index)
% If no architecture needs to be highlighted, set to 0
highlightArchIndex = 0;

 
%{
figure
hold on
frontendMarginPlot = plot(sort(bestCaseFrontendLinkMargins(:,1)));
grid
set(frontendMarginPlot,'LineWidth',1);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Frontend Link Margin (minimum of link margin in both directions)')
hold off

figure
hold on
frontendMarginPlot = plot(sort(bestCaseBackhaulLinkMargins(:,1)));
grid
set(frontendMarginPlot,'LineWidth',2);
xlabel('Architectures (ordered by link margin)')
ylabel('Link Margin, dB')
title('Backhaul Link Margin (minimum of link margin in both directions)')
hold off
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot link margins vs. TCO (4 graphs, best/worst case for
% frontend/backahul
% If Pareto front analysis selected, plot only architectures on the
% Pareto front
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
hold on
if (runParetoFrontAnalysis == 1)
    % Plot only non-dominated architectures on the Pareto front
    linkVsCostPlot = scatter(totalCost(~isDominated(:,1),4),...
        bestCaseFrontendLinkMargins(~isDominated(:,1),1),5);  
    title({'Pareto Front';...
           'Best Case Frontend Link Margin vs TCO'})
else
    % Plot all architectures
    linkVsCostPlot = scatter(totalCost(:,4),bestCaseFrontendLinkMargins(:,1),5);
    title('Best Case Frontend Link Margin vs TCO')
end
grid
set(linkVsCostPlot,'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',0.2);
xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
ylabel('Link Margin, dB')
% If a particular architecture (as specified by an index) needs to
% be highlighted plot it
if highlightArchIndex > 0
    selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
        bestCaseFrontendLinkMargins(highlightArchIndex,1),...
        'mo',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',15);
end
hold off

figure
hold on
if (runParetoFrontAnalysis == 1)
    % Plot only non-dominated architectures on the Pareto front
    linkVsCostPlot = scatter(totalCost(~isDominated(:,1),4),...
        bestCaseBackhaulLinkMargins(~isDominated(:,1),1),5);  
    title({'Pareto Front';...
           'Best Case Backhaul Link Margin vs TCO'})
else
    % Plot all architectures
    linkVsCostPlot = scatter(totalCost(:,4),bestCaseBackhaulLinkMargins(:,1),5);
    title('Best Case Backhaul Link Margin vs TCO')
end

grid
set(linkVsCostPlot,'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',0.2);
xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
ylabel('Link Margin, dB')
% If a particular architecture (as specified by an index) needs to
% be highlighted plot it
if highlightArchIndex > 0
     selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
        bestCaseBackhaulLinkMargins(highlightArchIndex,1),...
        'mo',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',15);
end
hold off

figure
hold on
if (runParetoFrontAnalysis == 1)
    % Plot only non-dominated architectures on the Pareto front
    linkVsCostPlot = scatter(totalCost(~isDominated(:,1),4),...
        worstCaseFrontendLinkMargins(~isDominated(:,1),1),5);  
    title({'Pareto Front';...
           'Worst Case Frontend Link Margin vs TCO'})
else
    % Plot all architectures
    linkVsCostPlot = scatter(totalCost(:,4),worstCaseFrontendLinkMargins(:,1),5);
    title('Worst Case Frontend Link Margin vs TCO')
end

grid
set(linkVsCostPlot,'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',0.2);
xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
ylabel('Link Margin, dB')
% If a particular architecture (as specified by an index) needs to
% be highlighted plot it
if highlightArchIndex > 0
     selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
        worstCaseFrontendLinkMargins(highlightArchIndex,1),...
        'mo',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',15);
end
hold off

figure
hold on
if (runParetoFrontAnalysis == 1)
    % Plot only non-dominated architectures on the Pareto front
    linkVsCostPlot = scatter(totalCost(~isDominated(:,1),4),...
        worstCaseBackhaulLinkMargins(~isDominated(:,1),1),5);  
    title({'Pareto Front';...
           'Worst Case Backhaul Link Margin vs TCO'})
else
    % Plot all architectures
    linkVsCostPlot = scatter(totalCost(:,4),worstCaseBackhaulLinkMargins(:,1),5);
    title('Worst Case Backhaul Link Margin vs TCO')
end
grid
set(linkVsCostPlot,'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',0.2);
xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
ylabel('Link Margin, dB')

% If a particular architecture (as specified by an index) needs to
% be highlighted plot it
if highlightArchIndex > 0
     selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
        worstCaseBackhaulLinkMargins(highlightArchIndex,1),...
        'mo',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',15);
end
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot link margins vs. TCO, *as grouped by certain properties*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
% Define 35-by-1 array defining the architecture properties of interest to
% plot
propertiesOfInterest = [0    %PortableRadioPurchaseCost
                        0    %PortableRadioMaintenanceCostPerYear
                        0    %PortableRadioExpectedUsableLifeInYears
                        0    %PortableRadioVerticalHeight
                        1    %PortableRadioRxGainValues
                        0    %PortableRadioRxGainCostMultiplier
                        1    %PortableRadioTxGainValues
                        0    %PortableRadioTxGainCostMultiplier
                        1    %PortableRadioTxPowerValues
                        0    %PortableRadioTxPowerCostMultiplier
                        0    %RepeaterPurchaseCost
                        0    %RepeaterMaintenanceCostPerYear
                        0    %RepeaterExpectedUsableLifeInYears
                        1    %RepeaterVerticalHeight
                        1    %RepeaterRxAntennaDiameterValues
                        0    %RepeaterRxGainCostMultiplier
                        1    %RepeaterTxAntennaDiameterValues
                        0    %RepeaterTxGainCostMultiplier
                        1    %RepeaterTxPowerValues
                        0    %RepeaterTxPowerCostMultiplier
                        0    %DispatchPurchaseCost
                        0    %DispatchMaintenanceCostPerYear
                        0    %DispatchExpectedUsableLifeInYears
                        0    %DispatchVerticalHeight
                        1    %DispatchRxAntennaDiameterValues
                        0    %DispatchRxGainCostMultiplier
                        1    %DispatchTxAntennaDiameterValues
                        0    %DispatchTxGainCostMultiplier
                        1    %DispatchTxPowerValues
                        0    %DispatchTxPowerCostMultiplier
                        1    %FrontDataRate
                        1    %BackhaulDataRate
                        1    %FrontendBandwidth
                        1    %BackhaulBandwidth
                        1];  %carrierFrequency


% Iterate through all possible properties of an architecture
% for i = 1:1:35
%    
%     % If this particular prooerty is of interest, plot it
%     if propertiesOfInterest(i)
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Plot Best Case Frontend Link Margins
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure
%         hold on
%         gscatterPlot = gscatter(totalCost(:,4),bestCaseFrontendLinkMargins(:,1),architectures(:,i));
%         xlim([0 3*10^7])
%         ylim([0 70])
%         xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
%         ylabel('Link Margin, dB')
% 
%         thisGrouping = architecturesTable.Properties.VariableNames{i};
% 
%         title({'Best Case Frontend Link Margin vs TCO';...
%                     ['ordered by ' thisGrouping]})
%                 
%         % If a particular architecture (as specified by an index) needs to
%         % be highlighted plot it
%         if highlightArchIndex > 0
%             
%             selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
%                 bestCaseFrontendLinkMargins(highlightArchIndex,1),...
%                 'mo',...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',15);
% 
%             legend(gscatterPlot); % Only display legend for gscatter plot
%         
%         end
%         
%         hold off
%     
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Plot Best Case Backhaul Link Margins
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%         figure
%         hold on
%         gscatterPlot = gscatter(totalCost(:,4),bestCaseBackhaulLinkMargins(:,1),architectures(:,i));
%         xlim([0 3*10^7])
%         ylim([0 70])
%         xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
%         ylabel('Link Margin, dB')
% 
%         thisGrouping = architecturesTable.Properties.VariableNames{i};
% 
%         title({'Best Case Backhaul Link Margin vs TCO';...
%                     ['ordered by ' thisGrouping]})
%                 
%         % If a particular architecture (as specified by an index) needs to
%         % be highlighted plot it
%         if highlightArchIndex > 0
%             
%             selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
%                 bestCaseBackhaulLinkMargins(highlightArchIndex,1),...
%                 'mo',...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',15);
% 
%             legend(gscatterPlot); % Only display legend for gscatter plot
%         
%         end
%         
%         hold off
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Plot Worst Case Frontend Link Margins
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure
%         hold on
%         gscatterPlot = gscatter(totalCost(:,4),worstCaseFrontendLinkMargins(:,1),architectures(:,i));
%         xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
%         ylabel('Link Margin, dB')
% 
%         thisGrouping = architecturesTable.Properties.VariableNames{i};
% 
%         title({'Worst Case Frontend Link Margin vs TCO';...
%                    ['ordered by ' thisGrouping]})
%         
%         % If a particular architecture (as specified by an index) needs to
%         % be highlighted plot it
%         if highlightArchIndex > 0
%             
%             selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
%                 worstCaseFrontendLinkMargins(highlightArchIndex,1),...
%                 'mo',...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',15);
% 
%             legend(gscatterPlot); % Only display legend for gscatter plot
%         
%         end
%         
%         hold off
%    
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Plot Worst Case Backhaul Link Margins
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         figure
%         hold on
%         gscatterPlot = gscatter(totalCost(:,4),worstCaseBackhaulLinkMargins(:,1),architectures(:,i));
%         xlabel(['Total Cost of Ownership over ' int2str(periodOfTimeForCostModel) ' years (USD)'])
%         ylabel('Link Margin, dB')
% 
%         thisGrouping = architecturesTable.Properties.VariableNames{i};
% 
%         title({'Worst Case Backhaul Link Margin vs TCO';...
%                    ['ordered by ' thisGrouping]})
%                
%         % If a particular architecture (as specified by an index) needs to
%         % be highlighted plot it
%         if highlightArchIndex > 0
%             
%             selectedArchPlot = plot(totalCost(highlightArchIndex,4),...
%                 worstCaseBackhaulLinkMargins(highlightArchIndex,1),...
%                 'mo',...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',15);
% 
%             legend(gscatterPlot); % Only display legend for gscatter plot
%         
%         end
%         
%         hold off
%     end
% end

fprintf('Script execution completed.\n');
