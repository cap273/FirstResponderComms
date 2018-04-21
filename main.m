%% main
% This script calculates the Link Budget margin for the communications link
% between:
%   1. a radio unit and a repeater
%   2. a dispatch center and a repeater
%
% The diagram for a generalized model of the network is located here:
% 

%% Clear everything
clc
clear all
close all

%% Architecture Enumeration
% This script calculates the Link Margin for a variety of architectures.
testCase = calculateEbNoTester;
res = run(testCase)

