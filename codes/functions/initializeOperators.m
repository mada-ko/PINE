function [F,Ft,T,Tt] = initializeOperators()

F  = @(x)  fft2(x);
Ft = @(x) ifft2(x);

% subPixelPhase = params.subPixelShiftInRad;
T  = @(x, subPixelPhase) ifft2(exp(-1i*subPixelPhase).*fft2(x));
Tt = @(x, subPixelPhase) ifft2(sum(exp(1i*subPixelPhase).*fft2(x),3));
end

