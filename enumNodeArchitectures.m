function [archMatrix,archTable] = enumNodeArchitectures(nodeStructure,gainType)
%findPossibleArchitectures Enumerate architectures for one node type.
%   Returns a matrix of all enumerated architectures for one given node
%   structure.
%   
%   OUTPUTS:
%       archMatrix:
%           A numeric m-by-n array, where m is the number of possible
%           architectures, and n is 10 (corresponding to the 10 different
%           properties that define this node as a subsystem).
%       archTable:
%           A m-by-n table. This contains the same information as the
%           output "matrix", but also contains header information on each
%           column (for sanity's sake).
%   
%   INPUT:
%       gainType:
%           either:
%               - "antennaDiameter", indicating that the input 
%                   "nodeStructure" contains the diameter of its Rx and Tx
%                   antenna, OR
%               - "linearGain", indicating that the input "nodeStructure" 
%                    contains the gain of its Rx and Tx antenna as a linear
%                    factor
%       nodeStructure:
%           must be a properly-formatted MATLAB variable (of data 
%           type "structure") that defines the properties of one node
%           a set of key-value pairs (a.k.a. field-value pairs).
%
% The fields in nodeStructure are the following:
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

%% Input error checking

% Get the name of this node type, removing all spaces
nodeName = regexprep(nodeStructure.Name, '\s+', '');

if gainType == "antennaDiameter"
    
    % Access the appropriate field of the input nodeStructure
    rxAntennaDiameterOrGainValues = nodeStructure.RxAntennaDiameterValues;
    txAntennaDiameterOrGainValues = nodeStructure.TxAntennaDiameterValues;
    
    % Define table header names appropriately
    rxAntennaTableName = 'RxAntennaDiameterValues';
    txAntennaTableName = 'TxAntennaDiameterValues';
           
elseif gainType == "linearGain"
    
    % Access the appropriate field of the input nodeStructure
    rxAntennaDiameterOrGainValues = nodeStructure.RxGainValues;
    txAntennaDiameterOrGainValues = nodeStructure.TxGainValues;
    
    % Define table header names appropriately
    rxAntennaTableName = 'RxGainValues';
    txAntennaTableName = 'TxGainValues';
    
else
    error('Input [gainType] has not been properly specified.')
end

if numel(rxAntennaDiameterOrGainValues) ~= ...
        numel(nodeStructure.RxGainCostMultiplier)
    error('Rx antenna diameters or gain values has an unequal number of associated cost multipliers')
end

if numel(txAntennaDiameterOrGainValues) ~= ...
        numel(nodeStructure.TxGainCostMultiplier)
    error('Tx antenna diameters or gain values has an unequal number of associated cost multipliers')
end

if numel(nodeStructure.TxPowerValues) ~= ...
        numel(nodeStructure.TxPowerCostMultiplier)
    error('Tx power values has an unequal number of associated cost multipliers')
end

%% Antenna Gains, or Antenna Diameters
% Align several [gain values or antenna diameter values] and Tx power values 
% with their respective cost multipliers into several N-by-2 numeric 
% matrices, where N is the number of possible [gain values or antenna 
% diameter values] and Tx power values
tmp1 = [transpose(rxAntennaDiameterOrGainValues),...
           transpose(nodeStructure.RxGainCostMultiplier)];
tmp2 = [transpose(txAntennaDiameterOrGainValues),...
           transpose(nodeStructure.TxGainCostMultiplier)];
tmp3 = [transpose(nodeStructure.TxPowerValues),...
           transpose(nodeStructure.TxPowerCostMultiplier)];

% Assertions
[r1,c1] = size(tmp1);
[r2,c2] = size(tmp2);
[r3,c3] = size(tmp3);

if c1~=2 || c2 ~=2 || c3 ~=2
    error('Error in combining antenna properties with cost multipliers. Unexpected number of columns.')
end

if r1 ~= numel(rxAntennaDiameterOrGainValues) ...
        || r2 ~= numel(txAntennaDiameterOrGainValues) ...
        || r3 ~= numel(nodeStructure.TxPowerValues)
    
    error('Error in combining antenna properties with cost multipliers. Unexpected number of rows.')
    
end

%% Purchase Cost, Maintenance Cost, Usable Life, and Vertical Height
% Find all combinations of all node properties that are:
%   (1) independent of each other, and
%   (2) not related to the Rx or Tx gains, and not related to the Tx power
% 
%  The result of this operation is an m-by-n numeric matrix, where m is the
% number of possible architectures for this subset of properties, and n is
% the number of this subset of properties (that is, 4)
subsetArchs = allcomb(nodeStructure.PurchaseCost,...
                            nodeStructure.MaintenanceCostPerYear,...
                            nodeStructure.ExpectedUsableLifeInYears,...
                            nodeStructure.VerticalHeight);

%% Enumeration of all possible architectures (for this node option)
% Now take the cross join (or the cartesian product) of all intermediary
% matrices to find the overall set of possible architectures for this node
% Now take the cross join of all the matrices
archMatrix = recursiveCrossJoin(subsetArchs,tmp1,tmp2,tmp3);

% Convert the matrix of all possible architectures into a table. This way,
% also explicitly keep track of which columns corresponds to each header.
cellArrayTableHeaders = {char(strcat(nodeName,'PurchaseCost')),...
                 char(strcat(nodeName,'MaintenanceCostPerYear')),...
                 char(strcat(nodeName,'ExpectedUsableLifeInYears')),...
                 char(strcat(nodeName,'VerticalHeight')),...
                 char(strcat(nodeName,rxAntennaTableName)),...
                 char(strcat(nodeName,'RxGainCostMultiplier')),...
                 char(strcat(nodeName,txAntennaTableName)),...
                 char(strcat(nodeName,'TxGainCostMultiplier')),...
                 char(strcat(nodeName,'TxPowerValues')),...
                 char(strcat(nodeName,'TxPowerCostMultiplier'))};
         
archTable = array2table(archMatrix,...
        'VariableNames',cellArrayTableHeaders);
    
end

