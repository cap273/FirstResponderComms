classdef calculateEbNoTester < matlab.unittest.TestCase
    % calculateLinearEbNoTester tests solutions to the calculation of Eb/No
    % for the following functions:
    %   calculateLinearEbNo
    %   calculateLinearMinEbNo
    % The inputs and outputs are known from a previously-provided Excel
    % spreadsheet
    
    methods (Test)
        function testEbNoCalculation(testCase)
            
            %%%%%%%%%%%%%%%
            % Define known inputs
            %%%%%%%%%%%%%%%%
            
            Ptx = 300; % Transmitter Power, in Watts
            Gtx =  22381.15509176170; % Transmitter Gain, linear value
            Grx =   3218428.647173230; % Receiver Gain, linear value
            slantRange = 500*10^3; % 500km
            radioFreq = 38.50*10^9; % 38.50 GHz
            Tr = 200; % Kelvin
            dataRate = 100*10^9; % 100 Gbps
            
            % losses of 10.0, converted to linear value
            atmLoss = convertToLinearFromdb(-10); 
            
            %%%%%%%%%%%%%%%%
  
            % Call function to calculate Eb/No
            actSolution = calculateLinearEbNo(Ptx,Gtx,Grx,slantRange, ...
                            radioFreq,Tr,dataRate,atmLoss);
            
            % Define known output
            expSolution = 12019.73020040390; % Expected Eb/No
            
            % Verify that expected vs actual answer is within 0.01%
            testCase.verifyEqual(actSolution,expSolution,'RelTol',0.0001);
            
        end
        
        function test
            
            
        
    end
    
end 

