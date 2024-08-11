function [object,probe] = ePIE(measurements, probe, params)
if not(isfield(params, 'denoiseCoord')), params.denoiseCoord = "cartesian"; end

diffAmp = measurements.diffAmplitude;
errorIdx = measurements.exceptionIdx;
illumPos = measurements.illumPos;

iterNum = params.iterNum;
[M, N, numSample] = size(diffAmp);


[F,Ft,T,Tt] = initializeOperators();
subPixelShiftInRad = calcTranslationParameters(illumPos, diffAmp);

tlY = illumPos(:, 1) + 1;
tlX = illumPos(:, 2) + 1;
brY = tlY + size(probe, 1) - 1;
brX = tlX + size(probe, 2) - 1;

object = ones(params.imsize);
if params.drawFigures
    fig = figure;
    fig.Position = [300 300 1200 500];
    tile1 = tiledlayout(2,4,"TileSpacing","compact",'Padding','none');

    methodTitleName = "ePIE " + " (\alpha = " + string(params.alpha) + ", \beta = "  + string(params.beta) +  ")";

    nexttile, fig1 = imagesc(abs(object));    colormap gray; colorbar;axis image; xlabel('Object Amplitude');
    nexttile, fig2 = imagesc(angle(object)); colormap gray; colorbar; axis image; xlabel('Object Phase');
    nexttile, fig3 = imagesc(abs(probe));   colormap gray; colorbar; axis image; xlabel('Probe Amplitude');
    nexttile, fig4 = imagesc(angle(probe));   colormap gray; colorbar; axis image; xlabel('Probe Phase');
    nexttile, fig5 = animatedline; title('UpdateObj Norm') 
    nexttile, fig6 = animatedline; title('UpdatePrb Norm')
    nexttile, fig7 = animatedline; title('R_F factor')
    tile1_t = title(tile1, methodTitleName + ", iteration: 0/" + string(iterNum), 'FontSize',14);
    drawnow
end

normStepObj = zeros(numSample,1);
normStepPrb = zeros(numSample,1);
Rf = zeros(iterNum,1);

% Define the function that returns update order
getUpdateOrder = @(x) randperm(x);

for iter = 1:iterNum
    sampleNumber = getUpdateOrder(numSample);
    Rfs = 0;
    for k = 1:numSample
        m = sampleNumber(k);
        ps_ = T(probe,subPixelShiftInRad(:,:,m));
        os_ = object(tlY(m):brY(m),tlX(m):brX(m));
        exitWave = ps_ .* os_;
        exitWaveProj = projectionExitWave(exitWave, diffAmp(:,:,m), errorIdx(:,:,m), F, Ft);
        diffExitWave = (exitWaveProj-exitWave);
        % Object update
        stepObj =  conj(ps_) ./ ((max(abs(ps_), [], [1 2])).^2) .* diffExitWave;
        os = os_ + params.alpha * stepObj;
        % Probe update
        stepPrb = conj(os_) ./ ((max(abs(os_), [], [1 2])).^2) .* diffExitWave;
        ps = ps_ + params.beta * stepPrb;
        
        object(tlY(m):brY(m),tlX(m):brX(m)) = os;
        probe = Tt(ps, subPixelShiftInRad(:,:,m));

        normStepObj(m) = norm(stepObj,'fro');
        normStepPrb(m) = norm(stepPrb,'fro');
        Rfs = Rfs + sum(abs(abs(fft2(exitWave))-diffAmp(:,:,m)),'all');

    end % object sample loop

    % recentre probe/object using probe intensity centre of mass
    absP2 = abs(probe).^2;
    cp = ...
        fix([M,N]/2 - [M,N].*[mean(cumsum(sum(absP2,2))), mean((cumsum(sum(absP2,1))))]/sum(absP2,'all') + 1);

    if any(cp)
        probe = circshift(probe,-cp);
        object   = circshift(object,-cp);
    end

    medNormStepObj = median(normStepObj);
    medNormStepPrb = median(normStepPrb);
    Rf(iter) = Rfs / sum(diffAmp,'all');

    if params.drawFigures
        obj_fig = gather(object);
        prb_fig = gather(probe);
        fig1.CData = abs(obj_fig);
        fig2.CData = angle(obj_fig);
        fig3.CData = abs(prb_fig);
        fig4.CData = angle(prb_fig);
        addpoints(fig5,iter,log10(medNormStepObj));        
        addpoints(fig6,iter,log10(medNormStepPrb));
        addpoints(fig7,iter,log10(Rf(iter)));
        
        tile1_t.String = methodTitleName + ", iteration: " + string(iter) + '/' + string(iterNum);
        drawnow
    end
end % End ePIE loop
end







