function measurements = setMeasurements(diffData, illumPos)
measurements.diffAmplitude = fftshift(fftshift(sqrt(abs(diffData)),1),2);
measurements.exceptionIdx  = fftshift(fftshift(    diffData < 0     ,1),2);
measurements.illumPos = illumPos;
end