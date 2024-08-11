function [diffData,illumPos] = loadData(diffName, posName)

diffData = double(tiffreadVolume(diffName));
illumPos = readmatrix(posName);
end