% MainVideoAnalysisDMD.m
%
% DMD analysis of an MP4 video.
%
% Required files:
%   dmd.m
%   input_video.mp4
%
% The video is converted into a snapshot matrix:
%
%       X = [x_1, x_2, ..., x_N]
%
% where each x_k is a vectorized grayscale frame.
%
% Outputs:
%   1. Video snapshot matrix
%   2. DMD reconstruction of the training interval
%   3. DMD prediction beyond the training interval
%   4. Singular-value plot
%   5. DMD eigenvalue plot
%   6. Dominant spatial DMD modes
%   7. Comparison and exported videos

clear;
close all;
clc;

% ================================================================
% 1. USER PARAMETERS
% =================================================================

%videoFile = 'passaro2k.mp4';
videoFile = 'bird498p.mov';

% Fraction of frames used for DMD training.
trainingFraction = 0.75;

% Resize frames to reduce computational cost.
% Example: resizeScale = 0.50 gives half the original width and height.
resizeScale = 1.0;

% Use every frame or subsample in time.
frameStride = 1;

% DMD rank selection.
useAutomaticRank = true;

% If automatic rank selection is disabled:
manualRank = 20;

% Retained SVD energy for automatic rank selection.
energyThreshold = 0.999;

% Upper limit for the DMD rank.
maximumRank = 80;

% Number of dominant modes to display.
numberOfModesToPlot = 6;

% Remove temporal mean before DMD.
% Usually useful for video because the stationary background becomes
% separated from the dynamic content.
subtractMeanFrame = true;

% Prediction stabilization.
% Standard DMD may produce eigenvalues slightly outside the unit circle.
stabilizePrediction = true;

% Eigenvalues with magnitude below this threshold are not modified.
neutralLowerBound = 0.90;

% Output filenames.
matrixFile = 'VideoSnapshotMatrix.mat';

reconstructionVideoFile = ...
    'Video_DMD_Training_Reconstruction.mp4';

predictionVideoFile = ...
    'Video_DMD_Prediction.mp4';

comparisonVideoFile = ...
    'Video_DMD_Comparison.mp4';

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

% Effective sampling time after temporal subsampling.
effectiveFrameRate = originalFrameRate/frameStride;
dt = 1/effectiveFrameRate;

% ================================================================
% 3. READ AND VECTORIZE VIDEO FRAMES
% =================================================================
%
% Each grayscale frame F_k in R^(m x n) is reshaped into
%
%       x_k = vec(F_k) in R^(mn).
%
% The snapshot matrix is
%
%       X = [x_1 x_2 ... x_N] in R^(mn x N).

fprintf('\nReading and vectorizing video frames...\n');

videoObject.CurrentTime = 0;

frameCounter = 0;
storedFrameCounter = 0;

snapshotMatrix = [];
frameHeight = [];
frameWidth  = [];

while hasFrame(videoObject)

    rgbFrame = readFrame(videoObject);

    frameCounter = frameCounter + 1;

    if mod(frameCounter-1,frameStride) ~= 0
        continue;
    end

    % Convert RGB to grayscale without requiring Image Processing Toolbox.
    grayFrame = rgbToGrayDouble(rgbFrame);

    % Resize if requested.
    if resizeScale ~= 1
        grayFrame = resizeFrameBilinear(grayFrame,resizeScale);
    end

    if isempty(frameHeight)

        [frameHeight,frameWidth] = size(grayFrame);
        numberOfPixels = frameHeight*frameWidth;

        % Estimate the total number of stored frames for preallocation.
        estimatedOriginalFrames = ...
            max(1,floor(videoDuration*originalFrameRate));

        estimatedStoredFrames = ...
            ceil(estimatedOriginalFrames/frameStride) + 2;

        snapshotMatrix = zeros( ...
            numberOfPixels, ...
            estimatedStoredFrames, ...
            'single');
    end

    storedFrameCounter = storedFrameCounter + 1;

    if storedFrameCounter > size(snapshotMatrix,2)

        % Expand if VideoReader returns more frames than estimated.
        snapshotMatrix(:,end+100) = single(0);
    end

    snapshotMatrix(:,storedFrameCounter) = ...
        single(grayFrame(:));
end

snapshotMatrix = ...
    snapshotMatrix(:,1:storedFrameCounter);

numberOfFrames = size(snapshotMatrix,2);
numberOfPixels = size(snapshotMatrix,1);

fprintf('Processed resolution:   %d x %d\n', ...
    frameWidth,frameHeight);
fprintf('Stored video frames:    %d\n',numberOfFrames);
fprintf('Snapshot matrix size:   %d x %d\n', ...
    numberOfPixels,numberOfFrames);
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

% Ensure enough training and prediction snapshots.
numberOfTrainingFrames = max(numberOfTrainingFrames,3);
numberOfTrainingFrames = min( ...
    numberOfTrainingFrames, ...
    numberOfFrames-1);

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
% 5. REMOVE THE TEMPORAL MEAN FRAME
% =================================================================

if subtractMeanFrame

    meanFrameVector = mean(trainingMatrix,2);

else

    meanFrameVector = zeros(numberOfPixels,1);
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

singularValueEnergy = ...
    singularValues.^2;

cumulativeEnergy = ...
    cumsum(singularValueEnergy) ...
    / sum(singularValueEnergy);

if useAutomaticRank

    selectedRank = find( ...
        cumulativeEnergy >= energyThreshold, ...
        1, ...
        'first');

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
% 7. CALL THE SUPPLIED dmd.m FUNCTION
% =================================================================
%
% Your function has the interface
%
%   [Phi,lambda,Xdmd,S1] = dmd(Y,dt,r)
%
% and constructs the shifted matrices internally.

fprintf('\nRunning DMD...\n');

[Phi,lambda,XdmdTraining,S1] = ...
    dmd( ...
    centeredTrainingMatrix, ...
    dt, ...
    selectedRank);

lambda = lambda(:);

numberOfModes = numel(lambda);

fprintf('Number of DMD modes:    %d\n',numberOfModes);

% ================================================================
% 8. TRAINING RECONSTRUCTION
% =================================================================
%
% The supplied dmd.m returns N_train-1 reconstructed frames.

numberOfDMDTrainingFrames = ...
    size(XdmdTraining,2);

reconstructedTrainingMatrix = ...
    real(XdmdTraining) ...
    + meanFrameVector;

reconstructedTrainingMatrix = ...
    clipVideoIntensity(reconstructedTrainingMatrix);

% ================================================================
% 9. DMD EXTRAPOLATION
% =================================================================
%
% Recompute the modal amplitudes from the first centered frame:
%
%       b = Phi \ x_1.
%
% Then evaluate the modal expansion beyond the training interval.

initialCenteredFrame = ...
    centeredTrainingMatrix(:,1);

modalAmplitudes = ...
    Phi\initialCenteredFrame;

lambdaPrediction = lambda;

if stabilizePrediction

    eigenvalueMagnitude = abs(lambdaPrediction);

    % Project nearly neutral modes onto the unit circle.
    nearlyNeutral = ...
        eigenvalueMagnitude >= neutralLowerBound ...
        & eigenvalueMagnitude > eps;

    lambdaPrediction(nearlyNeutral) = ...
        lambdaPrediction(nearlyNeutral) ...
        ./ eigenvalueMagnitude(nearlyNeutral);

    % Prevent remaining unstable modes from growing.
    unstableModes = ...
        abs(lambdaPrediction) > 1;

    lambdaPrediction(unstableModes) = ...
        lambdaPrediction(unstableModes) ...
        ./ abs(lambdaPrediction(unstableModes));
end

% Predict all frames from the initial frame, including training and future.
allPredictedCenteredFrames = ...
    zeros(numberOfPixels,numberOfFrames);

for k = 1:numberOfFrames

    modalEvolution = ...
        lambdaPrediction.^(k-1);

    allPredictedCenteredFrames(:,k) = ...
        real(Phi*(modalEvolution.*modalAmplitudes));
end

allPredictedFrames = ...
    allPredictedCenteredFrames ...
    + meanFrameVector;

allPredictedFrames = ...
    clipVideoIntensity(allPredictedFrames);

predictedForecastMatrix = ...
    allPredictedFrames(:, ...
    numberOfTrainingFrames+1:end);

% ================================================================
% 10. RECONSTRUCTION AND FORECAST ERRORS
% =================================================================

trainingTruthForComparison = ...
    trainingMatrix(:,1:numberOfDMDTrainingFrames);

trainingRelativeError = ...
    norm( ...
    trainingTruthForComparison ...
    - reconstructedTrainingMatrix, ...
    'fro') ...
    / max( ...
    norm(trainingTruthForComparison,'fro'), ...
    eps);

if numberOfForecastFrames > 0

    forecastRelativeError = ...
        norm( ...
        forecastTruthMatrix ...
        - predictedForecastMatrix, ...
        'fro') ...
        / max( ...
        norm(forecastTruthMatrix,'fro'), ...
        eps);

else

    forecastRelativeError = NaN;
end

fprintf('\nRelative training reconstruction error: %.6e\n', ...
    trainingRelativeError);

fprintf('Relative forecast error:                %.6e\n', ...
    forecastRelativeError);

% Framewise errors.
framewiseRelativeError = zeros(1,numberOfFrames);

for k = 1:numberOfFrames

    trueFrame = double(snapshotMatrix(:,k));
    modelFrame = allPredictedFrames(:,k);

    framewiseRelativeError(k) = ...
        norm(trueFrame-modelFrame,2) ...
        / max(norm(trueFrame,2),eps);
end

% ================================================================
% 11. CONTINUOUS-TIME EIGENVALUES
% =================================================================

continuousEigenvalues = ...
    log(lambda)/dt;

growthRates = ...
    real(continuousEigenvalues);

angularFrequencies = ...
    imag(continuousEigenvalues);

frequenciesHz = ...
    angularFrequencies/(2*pi);

% ================================================================
% 12. RANK DMD MODES FOR DIAGNOSIS
% =================================================================
%
% Mode importance combines:
%
%       |b_j| ||phi_j||_2.
%
% This measures the contribution of each mode to the initial video state.

modeNorms = ...
    vecnorm(Phi,2,1).';

modeImportance = ...
    abs(modalAmplitudes).*modeNorms;

[~,modeOrder] = ...
    sort(modeImportance,'descend');

numberOfModesToPlot = min([
    numberOfModesToPlot
    numberOfModes
]);

selectedModes = ...
    modeOrder(1:numberOfModesToPlot);

% ================================================================
% 13. SAVE SNAPSHOT MATRIX AND DMD RESULTS
% =================================================================

save( ...
    matrixFile, ...
    'snapshotMatrix', ...
    'trainingMatrix', ...
    'meanFrameVector', ...
    'frameHeight', ...
    'frameWidth', ...
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
% 14. DISPLAY EXAMPLE VIDEO FRAMES
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
        frameHeight,frameWidth);

    imagesc(ax,currentFrame,[0 1]);

    axis(ax,'image');
    axis(ax,'off');

    title( ...
        ax, ...
        sprintf('Frame %d, t = %.2f s', ...
        k,(k-1)*dt), ...
        'Color','w', ...
        'FontSize',12);
end

colormap(gcf,gray);

title( ...
    layoutFrames, ...
    'Video Snapshots Used in the DMD Analysis', ...
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
    ax, ...
    selectedRank, ...
    '--', ...
    sprintf('r = %d',selectedRank), ...
    'LineWidth',1.5);

xlabel(ax,'Singular-value index');
ylabel(ax,'\sigma_j/\sigma_1');
title(ax,'Singular Values of the Video Snapshot Matrix');

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
% 17. DMD MODE DIAGNOSIS
% =================================================================
%
% For complex modes:
%
%   real(phi_j) displays one spatial phase;
%   abs(phi_j) displays spatial modal magnitude.
%
% The magnitude is used here for robust visualization.

numberOfColumns = 3;
numberOfRows = ...
    ceil(numberOfModesToPlot/numberOfColumns);

figure( ...
    'Color','k', ...
    'Position',[60 50 1450 800]);

layoutModes = tiledlayout( ...
    numberOfRows,numberOfColumns, ...
    'Padding','compact', ...
    'TileSpacing','compact');

for j = 1:numberOfModesToPlot

    modeIndex = selectedModes(j);

    spatialModeMagnitude = reshape( ...
        abs(Phi(:,modeIndex)), ...
        frameHeight,frameWidth);

    ax = nexttile(layoutModes);

    imagesc(ax,spatialModeMagnitude);

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
        ax, ...
        titleText, ...
        'Color','w', ...
        'FontSize',11);
end

colormap(layoutModes.Parent,turbo);

title( ...
    layoutModes, ...
    'Dominant Dynamic Modes: Spatial Structures and Time Scales', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

% ================================================================
% 18. FRAMEWISE PREDICTION ERROR
% =================================================================

timeVector = ...
    (0:numberOfFrames-1)*dt;

trainingEndTime = ...
    (numberOfTrainingFrames-1)*dt;

figure( ...
    'Color','k', ...
    'Position',[100 100 1000 460]);

ax = axes;
hold(ax,'on');

semilogy( ...
    ax, ...
    timeVector, ...
    framewiseRelativeError, ...
    'LineWidth',1.8);

xline( ...
    ax, ...
    trainingEndTime, ...
    'r--', ...
    'End of training', ...
    'LineWidth',1.5, ...
    'LabelVerticalAlignment','bottom');

xlabel(ax,'Time [s]');
ylabel(ax,'Relative frame error');
title(ax,'DMD Reconstruction and Forecast Error');

grid(ax,'on');
styleDarkAxes(ax);

% ================================================================
% 19. SELECTED TRUE, RECONSTRUCTED, AND PREDICTED FRAMES
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
        frameHeight,frameWidth);

    predictedFrame = reshape( ...
        allPredictedFrames(:,k), ...
        frameHeight,frameWidth);

    differenceFrame = ...
        abs(trueFrame-predictedFrame);

    ax1 = nexttile(layoutComparison,j);

    imagesc(ax1,trueFrame,[0 1]);
    axis(ax1,'image');
    axis(ax1,'off');

    title( ...
        ax1, ...
        sprintf('True, frame %d',k), ...
        'Color','w');

    ax2 = nexttile( ...
        layoutComparison, ...
        numel(selectedComparisonFrames)+j);

    imagesc(ax2,predictedFrame,[0 1]);
    axis(ax2,'image');
    axis(ax2,'off');

    if k <= numberOfTrainingFrames
        intervalName = 'training';
    else
        intervalName = 'forecast';
    end

    title( ...
        ax2, ...
        sprintf('DMD (%s)',intervalName), ...
        'Color','w');

    ax3 = nexttile( ...
        layoutComparison, ...
        2*numel(selectedComparisonFrames)+j);

    imagesc(ax3,differenceFrame);
    axis(ax3,'image');
    axis(ax3,'off');

    title( ...
        ax3, ...
        sprintf('Error = %.2e', ...
        framewiseRelativeError(k)), ...
        'Color','w');
end

colormap(layoutComparison.Parent,gray);

title( ...
    layoutComparison, ...
    'Video Reconstruction and Prediction with DMD', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

% ================================================================
% 20. EXPORT TRAINING RECONSTRUCTION VIDEO
% =================================================================

fprintf('\nWriting training reconstruction video...\n');

trainingWriter = VideoWriter( ...
    reconstructionVideoFile, ...
    'MPEG-4');

trainingWriter.FrameRate = effectiveFrameRate;
trainingWriter.Quality = 95;

open(trainingWriter);

for k = 1:numberOfDMDTrainingFrames

    reconstructedFrame = reshape( ...
        reconstructedTrainingMatrix(:,k), ...
        frameHeight,frameWidth);

    outputFrame = uint8( ...
        255*reconstructedFrame);

    writeVideo(trainingWriter,outputFrame);
end

close(trainingWriter);

% ================================================================
% 21. EXPORT FORECAST VIDEO
% =================================================================

if numberOfForecastFrames > 0

    fprintf('Writing DMD prediction video...\n');

    predictionWriter = VideoWriter( ...
        predictionVideoFile, ...
        'MPEG-4');

    predictionWriter.FrameRate = effectiveFrameRate;
    predictionWriter.Quality = 95;

    open(predictionWriter);

    for k = 1:numberOfForecastFrames

        predictedFrame = reshape( ...
            predictedForecastMatrix(:,k), ...
            frameHeight,frameWidth);

        outputFrame = uint8( ...
            255*predictedFrame);

        writeVideo(predictionWriter,outputFrame);
    end

    close(predictionWriter);
end

% ================================================================
% 22. EXPORT TRUE-VERSUS-DMD COMPARISON VIDEO
% =================================================================

fprintf('Writing true-versus-DMD comparison video...\n');

comparisonWriter = VideoWriter( ...
    comparisonVideoFile, ...
    'MPEG-4');

comparisonWriter.FrameRate = effectiveFrameRate;
comparisonWriter.Quality = 95;

open(comparisonWriter);

comparisonFigure = figure( ...
    'Color','k', ...
    'Position',[100 100 1200 520], ...
    'Visible','off');

comparisonLayout = tiledlayout( ...
    comparisonFigure, ...
    1,2, ...
    'Padding','compact', ...
    'TileSpacing','compact');

axTrue = nexttile(comparisonLayout);
axDMD  = nexttile(comparisonLayout);

colormap(comparisonFigure,gray);

for k = 1:numberOfFrames

    trueFrame = reshape( ...
        double(snapshotMatrix(:,k)), ...
        frameHeight,frameWidth);

    predictedFrame = reshape( ...
        allPredictedFrames(:,k), ...
        frameHeight,frameWidth);

    imagesc(axTrue,trueFrame,[0 1]);
    axis(axTrue,'image');
    axis(axTrue,'off');

    title( ...
        axTrue, ...
        sprintf('Original video, t = %.2f s', ...
        (k-1)*dt), ...
        'Color','w', ...
        'FontSize',15);

    imagesc(axDMD,predictedFrame,[0 1]);
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
        intervalName, ...
        framewiseRelativeError(k)), ...
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

function grayFrame = rgbToGrayDouble(rgbFrame)
%RGBTOGRAYDOUBLE Convert RGB or grayscale uint8 frame to double [0,1].
%
% This implementation avoids a dependency on rgb2gray.

    frameDouble = double(rgbFrame);

    if ndims(frameDouble) == 3

        grayFrame = ...
            0.2989*frameDouble(:,:,1) ...
            + 0.5870*frameDouble(:,:,2) ...
            + 0.1140*frameDouble(:,:,3);

    else

        grayFrame = frameDouble;
    end

    if max(grayFrame,[],'all') > 1
        grayFrame = grayFrame/255;
    end
end

function resizedFrame = resizeFrameBilinear(frame,scale)
%RESIZEFRAMEBILINEAR Resize a grayscale frame using interp2.
%
% This avoids a dependency on imresize.

    if scale <= 0
        error('resizeScale must be positive.');
    end

    [oldHeight,oldWidth] = size(frame);

    newHeight = max(1,round(scale*oldHeight));
    newWidth  = max(1,round(scale*oldWidth));

    [oldX,oldY] = meshgrid( ...
        1:oldWidth, ...
        1:oldHeight);

    [newX,newY] = meshgrid( ...
        linspace(1,oldWidth,newWidth), ...
        linspace(1,oldHeight,newHeight));

    resizedFrame = interp2( ...
        oldX,oldY,frame,newX,newY,'linear');

    resizedFrame(isnan(resizedFrame)) = 0;
end

function videoMatrix = clipVideoIntensity(videoMatrix)
%CLIPVIDEOINTENSITY Restrict reconstructed intensities to [0,1].

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