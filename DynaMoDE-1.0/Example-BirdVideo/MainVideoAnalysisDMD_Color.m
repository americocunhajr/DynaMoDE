% MainVideoAnalysisDMD_Color.m
%
% DMD analysis of an RGB MP4/MOV video.
%
% Required files:
%   dmd.m
%   input video file
%
% Each RGB frame F_k in R^(m x n x 3) is vectorized as
%
%   x_k = [vec(R_k); vec(G_k); vec(B_k)] in R^(3mn)
%
% and the video snapshot matrix is
%
%   X = [x_1, x_2, ..., x_N] in R^(3mn x N).
%
% Outputs:
%   1. RGB video snapshot matrix
%   2. DMD reconstruction of the training interval
%   3. DMD prediction beyond the training interval
%   4. Singular-value plot
%   5. DMD eigenvalue plot
%   6. Dominant RGB DMD modes
%   7. Comparison and exported videos

clear;
close all;
clc;

% ================================================================
% 1. USER PARAMETERS
% =================================================================

videoFile = 'bird498p.mov';

trainingFraction = 0.9;

% Spatial resizing. Use 0.25--0.50 for large videos.
resizeScale = 1.0;

% Temporal subsampling.
frameStride = 5;

% Rank selection.
useAutomaticRank = true;
manualRank = 20;
energyThreshold = 0.95;
maximumRank = 150;

numberOfModesToPlot = 6;

% Remove the temporal RGB mean frame before DMD.
subtractMeanFrame = true;

% Optional prediction stabilization.
stabilizePrediction = true;
neutralLowerBound = 0.90;

% Output files.
matrixFile = 'VideoSnapshotMatrix_RGB.mat';

reconstructionVideoFile = ...
    'Video_DMD_RGB_Training_Reconstruction.mp4';

predictionVideoFile = ...
    'Video_DMD_RGB_Prediction.mp4';

comparisonVideoFile = ...
    'Video_DMD_RGB_Comparison.mp4';

% ================================================================
% 2. READ VIDEO INFORMATION
% =================================================================

if ~isfile(videoFile)
    error('Video file not found: %s',videoFile);
end

videoObject = VideoReader(videoFile);

originalFrameRate = videoObject.FrameRate;
originalHeight    = videoObject.Height;
originalWidth     = videoObject.Width;
videoDuration     = videoObject.Duration;

fprintf('Video file:             %s\n',videoFile);
fprintf('Original resolution:    %d x %d\n', ...
    originalWidth,originalHeight);
fprintf('Original frame rate:    %.4f frames/s\n', ...
    originalFrameRate);
fprintf('Duration:               %.4f s\n', ...
    videoDuration);

effectiveFrameRate = originalFrameRate/frameStride;
dt = 1/effectiveFrameRate;

% ================================================================
% 3. READ AND VECTORIZE RGB VIDEO FRAMES
% =================================================================
%
% MATLAB's linear indexing of an m x n x 3 array stores the complete
% red plane, followed by green, followed by blue. Thus frame(:) gives
%
%   [vec(R); vec(G); vec(B)].

fprintf('\nReading and vectorizing RGB video frames...\n');

videoObject.CurrentTime = 0;

frameCounter = 0;
storedFrameCounter = 0;

snapshotMatrix = [];
frameHeight = [];
frameWidth = [];
numberOfChannels = 3;

while hasFrame(videoObject)

    rgbFrame = readFrame(videoObject);
    frameCounter = frameCounter + 1;

    if mod(frameCounter-1,frameStride) ~= 0
        continue;
    end

    colorFrame = rgbFrameToDouble(rgbFrame);

    if resizeScale ~= 1
        colorFrame = resizeColorFrameBilinear( ...
            colorFrame,resizeScale);
    end

    if isempty(frameHeight)

        [frameHeight,frameWidth,numberOfChannels] = ...
            size(colorFrame);

        if numberOfChannels ~= 3
            error('The processed video frame is not RGB.');
        end

        numberOfStateVariables = ...
            frameHeight*frameWidth*numberOfChannels;

        estimatedOriginalFrames = ...
            max(1,floor(videoDuration*originalFrameRate));

        estimatedStoredFrames = ...
            ceil(estimatedOriginalFrames/frameStride)+2;

        snapshotMatrix = zeros( ...
            numberOfStateVariables, ...
            estimatedStoredFrames, ...
            'single');
    end

    storedFrameCounter = storedFrameCounter + 1;

    if storedFrameCounter > size(snapshotMatrix,2)
        snapshotMatrix(:,end+100) = single(0);
    end

    snapshotMatrix(:,storedFrameCounter) = ...
        single(colorFrame(:));
end

snapshotMatrix = ...
    snapshotMatrix(:,1:storedFrameCounter);

numberOfFrames = size(snapshotMatrix,2);
numberOfStateVariables = size(snapshotMatrix,1);

fprintf('Processed resolution:   %d x %d x %d\n', ...
    frameWidth,frameHeight,numberOfChannels);
fprintf('Stored video frames:    %d\n',numberOfFrames);
fprintf('Snapshot matrix size:   %d x %d\n', ...
    numberOfStateVariables,numberOfFrames);
fprintf('Effective frame rate:   %.4f frames/s\n', ...
    effectiveFrameRate);
fprintf('Time step dt:           %.6f s\n',dt);

if numberOfFrames < 4
    error('At least four video frames are required for DMD.');
end

% ================================================================
% 4. SPLIT INTO TRAINING AND FORECAST INTERVALS
% =================================================================

numberOfTrainingFrames = ...
    floor(trainingFraction*numberOfFrames);

numberOfTrainingFrames = max(numberOfTrainingFrames,3);
numberOfTrainingFrames = min( ...
    numberOfTrainingFrames,numberOfFrames-1);

numberOfForecastFrames = ...
    numberOfFrames-numberOfTrainingFrames;

trainingMatrix = ...
    double(snapshotMatrix(:,1:numberOfTrainingFrames));

forecastTruthMatrix = ...
    double(snapshotMatrix(:,numberOfTrainingFrames+1:end));

fprintf('\nTraining frames:        %d\n', ...
    numberOfTrainingFrames);
fprintf('Forecast frames:        %d\n', ...
    numberOfForecastFrames);

% ================================================================
% 5. REMOVE THE TEMPORAL MEAN RGB FRAME
% =================================================================

if subtractMeanFrame
    meanFrameVector = mean(trainingMatrix,2);
else
    meanFrameVector = zeros(numberOfStateVariables,1);
end

centeredTrainingMatrix = ...
    trainingMatrix-meanFrameVector;

% ================================================================
% 6. SELECT THE DMD RANK
% =================================================================

fprintf('\nComputing singular values for rank selection...\n');

[~,singularValueMatrix,~] = ...
    svd(centeredTrainingMatrix(:,1:end-1),'econ');

singularValues = diag(singularValueMatrix);

cumulativeEnergy = ...
    cumsum(singularValues.^2) ...
    / sum(singularValues.^2);

if useAutomaticRank

    selectedRank = find( ...
        cumulativeEnergy >= energyThreshold, ...
        1,'first');

    if isempty(selectedRank)
        selectedRank = numel(singularValues);
    end

else
    selectedRank = manualRank;
end

selectedRank = min([
    selectedRank
    maximumRank
    size(centeredTrainingMatrix,2)-1
    size(centeredTrainingMatrix,1)
]);

selectedRank = max(selectedRank,1);

fprintf('Selected DMD rank:      %d\n',selectedRank);
fprintf('Retained SVD energy:    %.8f\n', ...
    cumulativeEnergy(selectedRank));

% ================================================================
% 7. CALL dmd.m
% =================================================================

fprintf('\nRunning DMD...\n');

[Phi,lambda,XdmdTraining,S1] = ...
    dmd(centeredTrainingMatrix,dt,selectedRank);

lambda = lambda(:);
numberOfModes = numel(lambda);

fprintf('Number of DMD modes:    %d\n',numberOfModes);

% ================================================================
% 8. TRAINING RECONSTRUCTION
% =================================================================

numberOfDMDTrainingFrames = ...
    size(XdmdTraining,2);

reconstructedTrainingMatrix = ...
    real(XdmdTraining)+meanFrameVector;

reconstructedTrainingMatrix = ...
    clipVideoIntensity(reconstructedTrainingMatrix);

% ================================================================
% 9. DMD EXTRAPOLATION
% =================================================================

initialCenteredFrame = centeredTrainingMatrix(:,1);

modalAmplitudes = ...
    Phi\initialCenteredFrame;

lambdaPrediction = lambda;

if stabilizePrediction

    eigenvalueMagnitude = abs(lambdaPrediction);

    nearlyNeutral = ...
        eigenvalueMagnitude >= neutralLowerBound ...
        & eigenvalueMagnitude > eps;

    lambdaPrediction(nearlyNeutral) = ...
        lambdaPrediction(nearlyNeutral) ...
        ./ eigenvalueMagnitude(nearlyNeutral);

    unstableModes = abs(lambdaPrediction) > 1;

    lambdaPrediction(unstableModes) = ...
        lambdaPrediction(unstableModes) ...
        ./ abs(lambdaPrediction(unstableModes));
end

allPredictedCenteredFrames = ...
    zeros(numberOfStateVariables,numberOfFrames);

for k = 1:numberOfFrames

    modalEvolution = lambdaPrediction.^(k-1);

    allPredictedCenteredFrames(:,k) = ...
        real(Phi*(modalEvolution.*modalAmplitudes));
end

allPredictedFrames = ...
    allPredictedCenteredFrames+meanFrameVector;

allPredictedFrames = ...
    clipVideoIntensity(allPredictedFrames);

predictedForecastMatrix = ...
    allPredictedFrames(:,numberOfTrainingFrames+1:end);

% ================================================================
% 10. ERRORS
% =================================================================

trainingTruthForComparison = ...
    trainingMatrix(:,1:numberOfDMDTrainingFrames);

trainingRelativeError = ...
    norm(trainingTruthForComparison ...
    - reconstructedTrainingMatrix,'fro') ...
    / max(norm(trainingTruthForComparison,'fro'),eps);

if numberOfForecastFrames > 0

    forecastRelativeError = ...
        norm(forecastTruthMatrix ...
        - predictedForecastMatrix,'fro') ...
        / max(norm(forecastTruthMatrix,'fro'),eps);

else
    forecastRelativeError = NaN;
end

fprintf('\nRelative training reconstruction error: %.6e\n', ...
    trainingRelativeError);
fprintf('Relative forecast error:                %.6e\n', ...
    forecastRelativeError);

framewiseRelativeError = zeros(1,numberOfFrames);

for k = 1:numberOfFrames

    trueFrame = double(snapshotMatrix(:,k));
    modelFrame = allPredictedFrames(:,k);

    framewiseRelativeError(k) = ...
        norm(trueFrame-modelFrame,2) ...
        / max(norm(trueFrame,2),eps);
end

% ================================================================
% 11. DMD TIME SCALES
% =================================================================

continuousEigenvalues = log(lambda)/dt;

growthRates = real(continuousEigenvalues);
angularFrequencies = imag(continuousEigenvalues);
frequenciesHz = angularFrequencies/(2*pi);

% ================================================================
% 12. RANK MODES FOR DIAGNOSIS
% =================================================================

modeNorms = vecnorm(Phi,2,1).';

modeImportance = ...
    abs(modalAmplitudes).*modeNorms;

[~,modeOrder] = sort(modeImportance,'descend');

numberOfModesToPlot = min([
    numberOfModesToPlot
    numberOfModes
]);

selectedModes = modeOrder(1:numberOfModesToPlot);

% ================================================================
% 13. SAVE DATA AND DMD RESULTS
% =================================================================

save( ...
    matrixFile, ...
    'snapshotMatrix', ...
    'trainingMatrix', ...
    'meanFrameVector', ...
    'frameHeight', ...
    'frameWidth', ...
    'numberOfChannels', ...
    'effectiveFrameRate', ...
    'dt', ...
    'numberOfTrainingFrames', ...
    'Phi', ...
    'lambda', ...
    'modalAmplitudes', ...
    'singularValues', ...
    'selectedRank', ...
    '-v7.3');

fprintf('\nSaved matrix and DMD results to:\n%s\n', ...
    matrixFile);

% ================================================================
% 14. DISPLAY EXAMPLE RGB FRAMES
% =================================================================

exampleFrameIndices = unique(round(linspace( ...
    1,numberOfFrames,6)));

figure( ...
    'Color','k', ...
    'Position',[60 100 1450 500]);

layoutFrames = tiledlayout( ...
    1,numel(exampleFrameIndices), ...
    'Padding','compact', ...
    'TileSpacing','compact');

for j = 1:numel(exampleFrameIndices)

    k = exampleFrameIndices(j);
    ax = nexttile(layoutFrames);

    currentFrame = reshape( ...
        double(snapshotMatrix(:,k)), ...
        frameHeight,frameWidth,3);

    image(ax,currentFrame);

    axis(ax,'image');
    axis(ax,'off');

    title( ...
        ax, ...
        sprintf('Frame %d, t = %.2f s', ...
        k,(k-1)*dt), ...
        'Color','w', ...
        'FontSize',12);
end

title( ...
    layoutFrames, ...
    'RGB Video Snapshots Used in the DMD Analysis', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

% ================================================================
% 15. SINGULAR VALUES
% =================================================================

figure( ...
    'Color','k', ...
    'Position',[100 100 850 480]);

ax = axes;
hold(ax,'on');

semilogy( ...
    ax, ...
    1:numel(singularValues), ...
    singularValues/singularValues(1), ...
    'o-', ...
    'LineWidth',1.5, ...
    'MarkerSize',4);

xline( ...
    ax,selectedRank,'--', ...
    sprintf('r = %d',selectedRank), ...
    'LineWidth',1.5);

xlabel(ax,'Singular-value index');
ylabel(ax,'\sigma_j/\sigma_1');
title(ax,'Singular Values of the RGB Snapshot Matrix');

grid(ax,'on');
styleDarkAxes(ax);

% ================================================================
% 16. DMD EIGENVALUES
% =================================================================

figure( ...
    'Color','k', ...
    'Position',[100 100 650 600]);

ax = axes;
hold(ax,'on');

unitCircleAngle = linspace(0,2*pi,500);

plot( ...
    ax, ...
    cos(unitCircleAngle), ...
    sin(unitCircleAngle), ...
    'w--', ...
    'LineWidth',1.2);

scatter( ...
    ax, ...
    real(lambda), ...
    imag(lambda), ...
    70, ...
    log10(modeImportance+eps), ...
    'filled');

axis(ax,'equal');
grid(ax,'on');

xlabel(ax,'Re(\lambda)');
ylabel(ax,'Im(\lambda)');
title(ax,'DMD Eigenvalues');

colorbarHandle = colorbar(ax);
colorbarHandle.Color = 'w';
colorbarHandle.Label.String = ...
    'log_{10} modal importance';
colorbarHandle.Label.Color = 'w';

styleDarkAxes(ax);

% ================================================================
% 17. RGB DMD MODE DIAGNOSIS
% =================================================================
%
% Each color mode is reshaped to m x n x 3. Since DMD modes are usually
% complex, abs(Phi) is used here to show the spatial magnitude in each
% RGB channel. Each mode is normalized independently for display.

numberOfColumns = 3;
numberOfRows = ceil(numberOfModesToPlot/numberOfColumns);

figure( ...
    'Color','k', ...
    'Position',[60 50 1450 800]);

layoutModes = tiledlayout( ...
    numberOfRows,numberOfColumns, ...
    'Padding','compact', ...
    'TileSpacing','compact');

for j = 1:numberOfModesToPlot

    modeIndex = selectedModes(j);

    modeRGB = reshape( ...
        abs(Phi(:,modeIndex)), ...
        frameHeight,frameWidth,3);

    modeMaximum = max(modeRGB,[],'all');

    if modeMaximum > eps
        modeRGB = modeRGB/modeMaximum;
    end

    ax = nexttile(layoutModes);

    image(ax,modeRGB);

    axis(ax,'image');
    axis(ax,'off');

    titleText = {
        sprintf('Mode %d',modeIndex)
        sprintf('|\\lambda| = %.4f', ...
            abs(lambda(modeIndex)))
        sprintf('f = %.3f Hz, growth = %.3e', ...
            abs(frequenciesHz(modeIndex)), ...
            growthRates(modeIndex))
    };

    title( ...
        ax,titleText, ...
        'Color','w', ...
        'FontSize',11);
end

title( ...
    layoutModes, ...
    'Dominant RGB Dynamic Modes', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

% ================================================================
% 18. FRAMEWISE ERROR
% =================================================================

timeVector = (0:numberOfFrames-1)*dt;

trainingEndTime = ...
    (numberOfTrainingFrames-1)*dt;

figure( ...
    'Color','k', ...
    'Position',[100 100 1000 460]);

ax = axes;
hold(ax,'on');

semilogy( ...
    ax,timeVector,framewiseRelativeError, ...
    'LineWidth',1.8);

xline( ...
    ax,trainingEndTime,'r--', ...
    'End of training', ...
    'LineWidth',1.5, ...
    'LabelVerticalAlignment','bottom');

xlabel(ax,'Time [s]');
ylabel(ax,'Relative RGB-frame error');
title(ax,'DMD Reconstruction and Forecast Error');

grid(ax,'on');
styleDarkAxes(ax);

% ================================================================
% 19. SELECTED TRUE, DMD, AND ERROR FRAMES
% =================================================================

selectedComparisonFrames = unique([
    1
    max(2,round(numberOfTrainingFrames/2))
    numberOfTrainingFrames
    min(numberOfFrames,numberOfTrainingFrames+1)
    numberOfFrames
]);

figure( ...
    'Color','k', ...
    'Position',[40 50 1500 760]);

layoutComparison = tiledlayout( ...
    3,numel(selectedComparisonFrames), ...
    'Padding','compact', ...
    'TileSpacing','compact');

for j = 1:numel(selectedComparisonFrames)

    k = selectedComparisonFrames(j);

    trueFrame = reshape( ...
        double(snapshotMatrix(:,k)), ...
        frameHeight,frameWidth,3);

    predictedFrame = reshape( ...
        allPredictedFrames(:,k), ...
        frameHeight,frameWidth,3);

    differenceFrameRGB = abs(trueFrame-predictedFrame);

    % Convert RGB error to a scalar intensity map for display.
    differenceFrame = sqrt( ...
        mean(differenceFrameRGB.^2,3));

    ax1 = nexttile(layoutComparison,j);

    image(ax1,trueFrame);
    axis(ax1,'image');
    axis(ax1,'off');

    title( ...
        ax1,sprintf('True, frame %d',k), ...
        'Color','w');

    ax2 = nexttile( ...
        layoutComparison, ...
        numel(selectedComparisonFrames)+j);

    image(ax2,predictedFrame);
    axis(ax2,'image');
    axis(ax2,'off');

    if k <= numberOfTrainingFrames
        intervalName = 'training';
    else
        intervalName = 'forecast';
    end

    title( ...
        ax2,sprintf('DMD (%s)',intervalName), ...
        'Color','w');

    ax3 = nexttile( ...
        layoutComparison, ...
        2*numel(selectedComparisonFrames)+j);

    imagesc(ax3,differenceFrame,[0 1]);
    axis(ax3,'image');
    axis(ax3,'off');

    title( ...
        ax3, ...
        sprintf('Error = %.2e', ...
        framewiseRelativeError(k)), ...
        'Color','w');
end

% Apply grayscale only to the error-row axes.
for j = 1:numel(selectedComparisonFrames)
    axError = nexttile( ...
        layoutComparison, ...
        2*numel(selectedComparisonFrames)+j);
    colormap(axError,gray);
end

title( ...
    layoutComparison, ...
    'RGB Video Reconstruction and Prediction with DMD', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

% ================================================================
% 20. EXPORT TRAINING RECONSTRUCTION VIDEO
% =================================================================

fprintf('\nWriting RGB training reconstruction video...\n');

trainingWriter = VideoWriter( ...
    reconstructionVideoFile,'MPEG-4');

trainingWriter.FrameRate = effectiveFrameRate;
trainingWriter.Quality = 95;

open(trainingWriter);

for k = 1:numberOfDMDTrainingFrames

    reconstructedFrame = reshape( ...
        reconstructedTrainingMatrix(:,k), ...
        frameHeight,frameWidth,3);

    outputFrame = uint8(255*reconstructedFrame);

    writeVideo(trainingWriter,outputFrame);
end

close(trainingWriter);

% ================================================================
% 21. EXPORT RGB FORECAST VIDEO
% =================================================================

if numberOfForecastFrames > 0

    fprintf('Writing RGB DMD prediction video...\n');

    predictionWriter = VideoWriter( ...
        predictionVideoFile,'MPEG-4');

    predictionWriter.FrameRate = effectiveFrameRate;
    predictionWriter.Quality = 95;

    open(predictionWriter);

    for k = 1:numberOfForecastFrames

        predictedFrame = reshape( ...
            predictedForecastMatrix(:,k), ...
            frameHeight,frameWidth,3);

        outputFrame = uint8(255*predictedFrame);

        writeVideo(predictionWriter,outputFrame);
    end

    close(predictionWriter);
end

% ================================================================
% 22. EXPORT TRUE-VERSUS-DMD RGB COMPARISON VIDEO
% =================================================================

fprintf('Writing true-versus-DMD RGB comparison video...\n');

comparisonWriter = VideoWriter( ...
    comparisonVideoFile,'MPEG-4');

comparisonWriter.FrameRate = effectiveFrameRate;
comparisonWriter.Quality = 95;

open(comparisonWriter);

comparisonFigure = figure( ...
    'Color','k', ...
    'Position',[100 100 1200 520], ...
    'Visible','off');

comparisonLayout = tiledlayout( ...
    comparisonFigure,1,2, ...
    'Padding','compact', ...
    'TileSpacing','compact');

axTrue = nexttile(comparisonLayout);
axDMD = nexttile(comparisonLayout);

for k = 1:numberOfFrames

    trueFrame = reshape( ...
        double(snapshotMatrix(:,k)), ...
        frameHeight,frameWidth,3);

    predictedFrame = reshape( ...
        allPredictedFrames(:,k), ...
        frameHeight,frameWidth,3);

    image(axTrue,trueFrame);
    axis(axTrue,'image');
    axis(axTrue,'off');

    title( ...
        axTrue, ...
        sprintf('Original video, t = %.2f s',(k-1)*dt), ...
        'Color','w', ...
        'FontSize',15);

    image(axDMD,predictedFrame);
    axis(axDMD,'image');
    axis(axDMD,'off');

    if k <= numberOfTrainingFrames
        intervalName = 'reconstruction';
    else
        intervalName = 'prediction';
    end

    title( ...
        axDMD, ...
        sprintf('DMD %s, error = %.2e', ...
        intervalName,framewiseRelativeError(k)), ...
        'Color','w', ...
        'FontSize',15);

    drawnow;

    figureFrame = getframe(comparisonFigure);
    writeVideo(comparisonWriter,figureFrame);
end

close(comparisonWriter);
close(comparisonFigure);

fprintf('\nGenerated files:\n');
fprintf('  %s\n',matrixFile);
fprintf('  %s\n',reconstructionVideoFile);

if numberOfForecastFrames > 0
    fprintf('  %s\n',predictionVideoFile);
end

fprintf('  %s\n',comparisonVideoFile);

% ================================================================
% LOCAL FUNCTIONS
% =================================================================

function colorFrame = rgbFrameToDouble(rgbFrame)
%RGBFRAMETODOUBLE Convert a video frame to RGB double values in [0,1].

    frameDouble = double(rgbFrame);

    if ndims(frameDouble) == 2
        % Replicate grayscale data into three RGB channels.
        frameDouble = repmat(frameDouble,1,1,3);
    end

    if size(frameDouble,3) ~= 3
        error('Video frame must have one or three channels.');
    end

    if max(frameDouble,[],'all') > 1
        frameDouble = frameDouble/255;
    end

    colorFrame = min(max(frameDouble,0),1);
end

function resizedFrame = resizeColorFrameBilinear(frame,scale)
%RESIZECOLORFRAMEBILINEAR Resize an RGB frame using interp2.

    if scale <= 0
        error('resizeScale must be positive.');
    end

    [oldHeight,oldWidth,numberOfChannels] = size(frame);

    newHeight = max(1,round(scale*oldHeight));
    newWidth  = max(1,round(scale*oldWidth));

    [oldX,oldY] = meshgrid(1:oldWidth,1:oldHeight);

    [newX,newY] = meshgrid( ...
        linspace(1,oldWidth,newWidth), ...
        linspace(1,oldHeight,newHeight));

    resizedFrame = zeros( ...
        newHeight,newWidth,numberOfChannels);

    for channel = 1:numberOfChannels

        resizedFrame(:,:,channel) = interp2( ...
            oldX,oldY,frame(:,:,channel), ...
            newX,newY,'linear');
    end

    resizedFrame(isnan(resizedFrame)) = 0;
    resizedFrame = min(max(resizedFrame,0),1);
end

function videoMatrix = clipVideoIntensity(videoMatrix)
%CLIPVIDEOINTENSITY Restrict reconstructed RGB intensities to [0,1].

    videoMatrix = min(max(real(videoMatrix),0),1);
end

function styleDarkAxes(ax)
%STYLEDARKAXES Apply a dark visual style.

    ax.Color = [0.03 0.03 0.04];

    ax.XColor = [0.88 0.88 0.90];
    ax.YColor = [0.88 0.88 0.90];
    ax.ZColor = [0.88 0.88 0.90];

    ax.GridColor = [0.50 0.50 0.55];
    ax.GridAlpha = 0.22;

    ax.FontSize = 13;
    ax.LineWidth = 1.0;
    ax.Box = 'on';
end
