classdef calculateEbNoTester < matlab.unittest.TestCase
    % calculateLinearEbNoTester Tests calculations of Eb/No
    % for the following functions:
    %   calculateLinearEbNo
    %   calculateLinearMinEbNo
    %   calculateGainFromAntennaDiameter
    %   findLinkMarginIndB
    % The inputs and outputs are known from a previously-provided Excel
    % spreadsheet
    
    methods (Test)
        function testEbNoCalculation(testCase)
            
            %%%%%%%%%%%%%%%
            % Define known inputs
            %%%%%%%%%%%%%%%%
            
            Ptx = 300; % Transmitter Power, in Watts
            Gtx = 22381.15509176170; % Transmitter Gain, linear value
            Grx = 3222886.333213680; % Receiver Gain, linear value
            slantRange = 500*10^3; % 500km
            radioFreq = 38.50*10^9; % 38.50 GHz
            Tr = 200; % Kelvin
            dataRate = 100*10^9; % 100 Gbps
            
            % losses of 10.0, converted to linear value
            atmLoss = convertToLinearFromdb(-10); 
            
            %%%%%%%%%%%%%%%%
  
            % Call function to calculate Eb/No
            actEbNo = calculateLinearEbNo(Ptx,Gtx,Grx,slantRange, ...
                            radioFreq,Tr,dataRate,atmLoss);
            
            % Define known output
            expEbNo = 12036.37813310590; % Expected Eb/No
            
            % Verify that expected vs actual answer is within 0.001%
            testCase.verifyEqual(actEbNo,expEbNo,'RelTol',0.00001);
            
            % Convert calculated Eb/No from linear factor to deciBel
            dbActEbNo = convertTodBFromLinear(actEbNo);
            
            % Define known output in dB
            dbExpEbNo = 40.80496;
            
            % Verify that expected vs actual answer is within 0.001%
            testCase.verifyEqual(dbActEbNo,dbExpEbNo, ...
                'RelTol',0.00001);
            
        end
        
        function testMinEbNoCalc(testCase)
            
            %%%%%%%%%%%%%%%
            % Define known inputs
            %%%%%%%%%%%%%%%%
            
            dataRate = 100*10^9; % 100 Gbps
            bandwidth = 10*10^9; % 10 Ghz
            
            %%%%%%%%%%%%%%%%
            
            % Call function to calculate minimum required Eb/No according 
            % to Shannon lower bound (plus 3 dB of additional margin as a
            % safety factor). Function returns a linear (not dB) factor
            actEbNoMin = calculateLinearMinEbNo(dataRate,bandwidth);
            
            % Convert linear factor to deciBels
            dbActEbNoMin = convertTodBFromLinear(actEbNoMin);
            
            % Define expected minimum Eb/No, in deciBels
            dBExpEbNoMin = 23.09876;
            
            % Verify that expected vs actual answer is within 0.001%
            testCase.verifyEqual(dbActEbNoMin,dBExpEbNoMin, ...
                'RelTol',0.00001);
            
        end
        
        function testAntennaGain(testCase)
            
            %%%%%%%%%%%%%%%
            % Define known inputs
            %%%%%%%%%%%%%%%%
            
            txApertureDiameter = 0.5; % transmitter aperture, in meters
            rxApertureDiameter = 6; % transmitter aperture, in meters
            apertureEfficiency = 0.55;
            radioFreq = 38.50*10^9; % 38.50 GHz
            
            %%%%%%%%%%%%%%%%
            
            % Calculate antenna gain for receiver and transmitter
            txActGain = calculateGainFromAntennaDiameter(... 
                apertureEfficiency,txApertureDiameter,radioFreq);
            rxActGain = calculateGainFromAntennaDiameter(... 
                apertureEfficiency,rxApertureDiameter,radioFreq);
            
            % Define expected gain (as linear value)
            txExpGain =  22381.15509176170;
            rxExpGain =  3222886.333213680;

            % Verify Tx and Rx gains
            testCase.verifyEqual(txActGain,txExpGain, ...
                'RelTol',0.00001);
            
            testCase.verifyEqual(rxActGain,rxExpGain, ...
                'RelTol',0.00001);
        end
        
        function testLinkMargin(testCase)
            
            %%%%%%%%%%%%%%%
            % Define known inputs
            %%%%%%%%%%%%%%%%
            
            Ptx = 300; % Transmitter Power, in Watts
            Gtx = 22381.15509176170; % Transmitter Gain, linear value
            Grx = 3222886.333213680; % Receiver Gain, linear value
            slantRange = 500*10^3; % 500km
            radioFreq = 38.50*10^9; % 38.50 GHz
            Tr = 200; % Kelvin
            dataRate = 100*10^9; % 100 Gbps
            bandwidth = 10*10^9; % 10 Ghz
             
            % losses of 10.0, converted to linear value
            atmLoss = convertToLinearFromdb(-10); 
            
            %%%%%%%%%%%%%%%%
            
            % Call function to calculate Eb/No (as a linear factor)
            EbNo = calculateLinearEbNo(Ptx,Gtx,Grx,slantRange, ...
                            radioFreq,Tr,dataRate,atmLoss);
                        
            % Call function to calculate minimum required Eb/No according 
            % to Shannon limit, as a linear factor
            EbNoMin = calculateLinearMinEbNo(dataRate,bandwidth);

            % Calculate actual link margin by calling function
            actLinkMargindB = findLinkMarginIndB(EbNo, ...
                                                 EbNoMin);

            % Define expected link margin
            expLinkMargindB = 17.70620189;
            
            % Verify link margin
            testCase.verifyEqual(actLinkMargindB,expLinkMargindB, ...
                'RelTol',0.00001);
            
        end 
    end
    
end 

