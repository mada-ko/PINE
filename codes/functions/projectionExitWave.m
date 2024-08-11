function exitWaveProj = projectionExitWave(exitWave, diffAmp, errorIdx, F, Ft)
diffTemp = F(exitWave);
temp = diffAmp .* sign(diffTemp);
temp(errorIdx) = diffTemp(errorIdx);
exitWaveProj = Ft(temp);
end