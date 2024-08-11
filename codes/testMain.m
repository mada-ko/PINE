function testMain()

% clc, clear, close all;
addpath(genpath("functions/"));

%%
diffFileName = '../data/diffraction_dose08.tif';
posFileName = '../data/position.csv';

% load data 
[diffData,illumPos] = loadData(diffFileName, posFileName);

% initialize measurements
measurements = setMeasurements(diffData,illumPos);


% initialize parameters
params.pbsize = size(diffData,1);
params.imsize = 770;
params_ePIE = setParams("ePIE", params);
params_PINE = setParams("PINE", params);

% initialize variables
probeInit = initializeProbe(params.pbsize);

% reconstruct object and probe
[object_ePIE, probe_ePIE] = ePIE(measurements, probeInit, params_ePIE);
[object_PINE, probe_PINE] = PINE(measurements, probeInit, params_PINE);

% visualize amplitude and phase of object
tile_ePIE = visualizeObject(object_ePIE);
title(tile_ePIE, "ePIE");

tile_PINE = visualizeObject(object_PINE);
title(tile_PINE, "PINE");


%% Local functions
function params = setParams(methodName, params)
params.drawFigures = true;
params.iterNum = 20;
if methodName == "ePIE"
    params.alpha = 1;
    params.beta  = 0.2;
elseif methodName == "PINE"
    params.alpha = 1;
    params.beta = 0.2;
    params.tau = 0.49;
    params.denoiseCoord = "cartesian";
else
    error('The PIE type does not exist.')
end
end

end

function tile = visualizeObject(object)

baseRefPoint = [452, 346];
ampClimRange = [0.95, 1.01];
phaseClimRange = [-0.4 0.1];
xRange = [100 680];
yRange = [110 690];

fig = figure;
fig.Position = [300 300 1200 500];
tile = tiledlayout(1,2,"TileSpacing","compact",'Padding','none');

% visualize amplitude image
amp = abs(object);
amp = amp / amp(baseRefPoint(1), baseRefPoint(2));

nexttile;
imagesc(amp); 
axis image; colormap gray; clim(ampClimRange);
xlim(xRange); ylim(yRange);
axis off;
title('amplitude')

% visualize pahse image
obj_phase = angle(object);

nexttile;
imagesc(obj_phase); 
axis image; colormap gray; clim(phaseClimRange);
xlim(xRange); ylim(yRange);
axis off; 
title('phase')
end