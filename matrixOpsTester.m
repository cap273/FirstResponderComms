classdef matrixOpsTester < matlab.unittest.TestCase
    % matrixOpsTester Tests matrix operations using the following
    % functions:
    %   C = crossJoin(A,B)
    %   D = recursiveCrossJoin(vargin)
    %   archMatrix,archTable] = enumNodeArchitectures(nodeStructure,gainType)

    
    methods (Test)
        function testCrossJoin(testCase)
            
            A = [1,2;3,4];
            B = [5,6,7;8,9,10];
            
            % Expected cross join of A and B
            expC = [1,2,5,6,7;
                 1,2,8,9,10;
                 3,4,5,6,7;
                 3,4,8,9,10];
           
            % Computed cross join of A and B
            actC = crossJoin(A,B);
            
            % Sort the rows of the actual and expected resulting matrices
            % (because the order of the rows in the computed vs expected
            % matrix might be different, which does not affect the accuracy
            % of the result)
            expC = sortrows(expC);
            actC = sortrows(actC);
            
            % Verify that the expected and computed matrix is the same
            testCase.verifyEqual(actC,expC);
            
        end
        
        function testRecursiveCrossJoin(testCase)
            A = [1,2;3,4];
            B = [5,6,7;8,9,10];
            C = [100,101;102,103];
            
            % Define the expected matrix that is the cross join of A, B,
            % and C
            expD = [1,2,5,6,7,100,101;
                    1,2,8,9,10,100,101;
                    3,4,5,6,7,100,101;
                    3,4,8,9,10,100,101;
                    1,2,5,6,7,102,103;
                    1,2,8,9,10,102,103;
                    3,4,5,6,7,102,103;
                    3,4,8,9,10,102,103];
                
           % Computed cross join of A, B, and C, using recursive function
            actD = recursiveCrossJoin(A,B,C);
            
            % Sort the rows of the actual and expected resulting matrices
            % of the result)
            expD = sortrows(expD);
            actD = sortrows(actD);
            
            % Verify that the expected and computed matrix is the same
            testCase.verifyEqual(actD,expD);
            
        end
        
        function testEnumNodeArchitectures(testCase)
            
            %%%%%%%%%%%%%%%
            % Define test inputs for one option of one node type
            %%%%%%%%%%%%%%%%
            
            thisOptionName = "Regular Handheld Radio";
            thisOptionPurchaseCost = 1800;
            thisOptionMaintenanceCostPerYear = 90;
            thisOptionExpectedUsableLifeInYears = 7;
            verticalHeight = 0;

            % Receiver (Rx) Gain values (as linear factors) and cost multipliers
            % Since this is a WIRE antenna, use gain values (instead of antenna sizes)
            rxGainValuesArray = [convertToLinearFromdb(1),... % 10 dB
                                 convertToLinearFromdb(2)];   % 25 dB
            rxGainCostMultiplierArray = [4,5.3];

            % Transmitter (Tx) Gain values (as linear factors) and cost multipliers
            % Since this is a WIRE antenna, use gain values (instead of antenna sizes)
            txGainValuesArray = [convertToLinearFromdb(10),... % 10 dB
                                 convertToLinearFromdb(25)];   % 25 dB
            txGainCostMultiplierArray = [3,0.5];

            % Transmitter (Tx) Power values (as Watts) and cost multipliers
            txPowerValuesArray = [6,25,45]; %6W, 25W, 45W
            txPowerCostMultiplierArray = [1,1.25,1.5];

            thisPortableRadioType = struct('Name',thisOptionName,...
                    'PurchaseCost',thisOptionPurchaseCost,...
                    'MaintenanceCostPerYear',thisOptionMaintenanceCostPerYear,...
                    'ExpectedUsableLifeInYears',thisOptionExpectedUsableLifeInYears,...
                    'RxGainValues',rxGainValuesArray,...
                    'RxGainCostMultiplier',rxGainCostMultiplierArray,...
                    'TxGainValues',txGainValuesArray,...
                    'TxGainCostMultiplier',txGainCostMultiplierArray,...
                    'TxPowerValues',txPowerValuesArray,...
                    'TxPowerCostMultiplier',txPowerCostMultiplierArray,...
                    'VerticalHeight',verticalHeight);
                
            %%%%%%%%%%%%%%%
            % Get results from enumNodeArchitectures
            %%%%%%%%%%%%%%%%
            
            [archMatrix,archTable] = enumNodeArchitectures(...
                                thisPortableRadioType,"linearGain");
            
            [actNr,actNc] = size(archTable); % Dimensions of actual table
            
            %%%%%%%%%%%%%%%
            % Assertions
            %%%%%%%%%%%%%%%%
            
            % There should be 10 columns, one for each numeric value (i.e.
            % excluding name of the option for this node type)
            testCase.verifyEqual(actNc,10);
            
            % There should be 12 rows, which is the number of possible
            % architectures in this option for this node type, given all
            % dependencies (i.e. 2*2*3)
            testCase.verifyEqual(actNr,12);
            
            % There should only be one purchase cost for all rows in this
            % matrix, and it should be in the 1st column
            testCase.verifyEqual(unique(archMatrix(:,1)),thisOptionPurchaseCost);
            
            % There should only be one maintenance cost for all rows in this
            % matrix, and it should be in the 2nd column
            testCase.verifyEqual(unique(archMatrix(:,2)),thisOptionMaintenanceCostPerYear);
            
            % There should only be one ExpectedUsableLifeInYears for all 
            % rows in this matrix, and it should be in the 3rd column
            testCase.verifyEqual(unique(archMatrix(:,3)),thisOptionExpectedUsableLifeInYears);
            
            % There should only be one verticalHeight for all 
            % rows in this matrix, and it should be in the 4th column
            testCase.verifyEqual(unique(archMatrix(:,4)),verticalHeight);
            
            % Get table header names, and get this node's name without
            % spaces
            tableHeaderNames = archTable.Properties.VariableNames;
            
            % Verify table column names (first 4)
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'PurchaseCost')),tableHeaderNames{1});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'MaintenanceCostPerYear')),tableHeaderNames{2});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'ExpectedUsableLifeInYears')),tableHeaderNames{3});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'VerticalHeight')),tableHeaderNames{4});
                        
            % Verify table column names (last 6, corresponding to antenna
            % and gains-related columns)
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'RxGainValues')),tableHeaderNames{5});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'RxGainCostMultiplier')),tableHeaderNames{6});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'TxGainValues')),tableHeaderNames{7});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'TxGainCostMultiplier')),tableHeaderNames{8});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'TxPowerValues')),tableHeaderNames{9});
            testCase.verifyEqual(char(strcat("RegularHandheldRadio",...
                            'TxPowerCostMultiplier')),tableHeaderNames{10});
                        
            % Column 5 should contain linear Rx gain values
            testCase.verifyEqual(unique(transpose(archMatrix(:,5))),...
                sort(rxGainValuesArray));
            
            % Column 6 should contain cost multipliers for Rx gain values
            testCase.verifyEqual(unique(transpose(archMatrix(:,6))),...
                sort(rxGainCostMultiplierArray));
            
            % Column 7 should contain linear Tx gain values
            testCase.verifyEqual(unique(transpose(archMatrix(:,7))),...
                sort(txGainValuesArray));
            
            % Column 8 should contain Tx power values
            testCase.verifyEqual(unique(transpose(archMatrix(:,8))),...
                sort(txGainCostMultiplierArray));
            
            % Column 9 should contain cost multipliers for Tx power values
            testCase.verifyEqual(unique(transpose(archMatrix(:,9))),...
                sort(txPowerValuesArray));
            
            % Column 10 should contain cost multipliers for Tx gain values
            testCase.verifyEqual(unique(transpose(archMatrix(:,10))),...
                sort(txPowerCostMultiplierArray));
        end
    end
    
end 


