clear
clc

testCase = calculateLinearEbNoTester;
res = run(testCase)

EbNoDb = convertTodBFromLinear(EbNo)

%EbNoMin = calculateLinearMinEbNo(dataRate,bandwidth)

%EbNoMinDb = convertTodBFromLinear(EbNoMin)