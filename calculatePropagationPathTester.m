classdef calculatePropagationPathTester < matlab.unittest.TestCase
    % calculatePropagationPathTester Tests propagation path calculations
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
    
    methods (Test)
        function testPropagationPathCalc1(testCase)
            
            %%%%%%%%%%%%%%%
            % Define inputs where:
            %   v2>>v1
            %   h1 == h2
            %   And therefore
            %   s1 = s2
            %%%%%%%%%%%%%%%%
            
            v1 = 5; %5m
            v2 = 1000; % 1km
            h1 = 3000; % 3km
            h2 = 3000; % 3km   
            s1 = sqrt(h1^2 + v1^2);
            
            % Expected output
            exps2 = s1;
            
            % Calculated output
            acts2 = calculatePropagationPath(s1,v1,v2,h1,h2);
            
            % Verify output
            testCase.verifyEqual(acts2,exps2);
            
        end
        
        function testPropagationPathCalc2(testCase)
            
            %%%%%%%%%%%%%%%
            % Define inputs where:
            %   v2>>v1
            %   h2 > h1 [code should run as if h2 == h1]
            %   And therefore
            %   s1 = s2
            %%%%%%%%%%%%%%%%
            
            v1 = 5; %5m
            v2 = 1000; % 1km
            h1 = 3000; % 3km
            h2 = 5000; % 3km   
            s1 = sqrt(h1^2 + v1^2);
            
            % Expected output
            exps2 = s1;
            
            % Calculated output
            acts2 = calculatePropagationPath(s1,v1,v2,h1,h2);
            
            % Verify output
            testCase.verifyEqual(acts2,exps2);
            
        end
        
        function testPropagationPathCalc3(testCase)
            
            %%%%%%%%%%%%%%%
            % Define inputs where:
            %   h2 == v2 
            %   v1 == h1
            %   We have two right triangles, and therefore
            %   s2 == sqrt(h2^ + v^2)
            %%%%%%%%%%%%%%%%
            
            v1 = 3000; %3km
            h1 = 3000; % 3km
            
            v2 = 2000; % 2km
            h2 = 2000; % 2km 
              
            s1 = sqrt(h1^2 + v1^2);
            
            % Expected output
            exps2 = sqrt(h2^2 + v2^2);
            
            % Calculated output
            acts2 = calculatePropagationPath(s1,v1,v2,h1,h2);
            
            % Verify output
            testCase.verifyEqual(acts2,exps2, ...
                'RelTol',0.00001);
            
        end
    end
    
end 

