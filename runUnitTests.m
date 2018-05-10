%% Run unit tests
% This script runs all unit tests defined as part of this project


%% Clear everything
clc
clear
close all

%% Run calculateEbNoTester unit test
testCase1 = calculateEbNoTester;
res1 = run(testCase1) %#ok<NOPTS>

%% Run matrixOpsTester unit test
testCase2 = matrixOpsTester;
res2 = run(testCase2) %#ok<NOPTS>

%% Run calculatePropagationPathTester unit test
testCase3 = calculatePropagationPathTester;
res3 = run(testCase3) %#ok<NOPTS>
