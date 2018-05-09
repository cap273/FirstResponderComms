function transposedTable = transposeTable(originalTable)
% transposeTable - Transposes a MATLAB Table
%    Refernce: https://stackoverflow.com/questions/34744544/how-to-transpose-a-matlab-table

    tempArray = table2array(originalTable);
    tempNewTable = array2table(tempArray.');
    tempNewTable.Properties.RowNames = originalTable.Properties.VariableNames;

    transposedTable = tempNewTable;
end

