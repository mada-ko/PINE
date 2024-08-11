function [initialProbe] = initializeProbe(probeSize)
center = probeSize/2 + 1/2;
x = 0:probeSize;
y = (0:probeSize)';

Z = sqrt((x-center).^2 + (y-center).^2);
R = probeSize/4;
r = probeSize/8;
% r=0;
prb = makePrb(Z(2:end,2:end), R, r);
initialProbe =  double(prb) .* exp(1i*zeros(size(prb)));
end

function y = makePrb(x,R,r)
    y = zeros(size(x));
    y(x <= r) = 1;
    z = r < x & x <= R;
    y(z) = 1/2*cos(pi*(x(z)-r)/(R-r)) + 1/2;
end