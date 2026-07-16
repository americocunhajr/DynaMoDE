% RastriginFieldDMD.m
%
% Traditional DMD applied to the augmented state
%
%       z_k = [q_k ; gamma*qdot_k]
%
% Uses the supplied function:
%
%       [Phi,lambda,Xdmd,S1] = dmd(Y,dt,r)
%
% Required files:
%       rastrigin.m
%       dmd.m

clear;
close all;
clc;

% ================================================================
% 1. SPATIAL DISCRETIZATION
% =================================================================

nx = 100;
ny = 100;

x1 = linspace(-5.12,5.12,nx);
x2 = linspace(-5.12,5.12,ny);

nField = nx*ny;

% ================================================================
% 2. TIME DISCRETIZATION
% =================================================================

dt = 0.025;

% The field has period pi because the Rastrigin function is even and
% the coordinates depend on sin(t).
%
% Two periods are used for training and one period for extrapolation.

t0        = 0.10;
tTrainEnd = t0 + pi;
tFinal    = t0 + 10*pi;

time = t0:dt:tFinal;

Nt = numel(time);

nTrain = find(time <= tTrainEnd,1,'last');

timeTrain = time(1:nTrain);

fprintf('State dimension:        %d\n',nField);
fprintf('Total snapshots:        %d\n',Nt);
fprintf('Training snapshots:     %d\n',nTrain);
fprintf('Forecast snapshots:     %d\n',Nt-nTrain);

% ================================================================
% 3. GENERATE THE EXACT RASTRIGIN FIELD
% =================================================================

Q = zeros(nField,Nt);

fprintf('Generating Rastrigin snapshots...\n');

for k = 1:Nt

    scale = sin(time(k));

    x1Dynamic = scale*x1;
    x2Dynamic = scale*x2;

    field_k = rastrigin([x1Dynamic; x2Dynamic]);

    Q(:,k) = field_k(:);
end

Qtrain = Q(:,1:nTrain);

% ================================================================
% 4. COMPUTE THE TIME DERIVATIVE USING TRAINING DATA ONLY
% =================================================================
%
% The derivative is computed only from Qtrain. Thus, no information from
% the extrapolation interval enters the identified model.

QdotTrain = temporalDerivative(Qtrain,dt);

% ================================================================
% 5. CENTER THE FIELD AND ITS DERIVATIVE
% =================================================================

qMean    = mean(Qtrain,2);
qdotMean = mean(QdotTrain,2);

QcTrain    = Qtrain    - qMean;
QdotcTrain = QdotTrain - qdotMean;

% ================================================================
% 6. BALANCE THE TWO BLOCKS
% =================================================================
%
% Without scaling, either q or qdot may dominate the SVD.

normQ    = norm(QcTrain,'fro');
normQdot = norm(QdotcTrain,'fro');

if normQdot <= eps
    error('The derivative block has negligible norm.');
end

gamma = normQ/normQdot;

fprintf('Derivative scaling gamma: %.6e\n',gamma);

% ================================================================
% 7. BUILD THE AUGMENTED TRAINING STATE
% =================================================================

Ztrain = [
    QcTrain
    gamma*QdotcTrain
];

nAugmented = size(Ztrain,1);

fprintf('Augmented dimension:     %d\n',nAugmented);

% ================================================================
% 8. SELECT THE DMD RANK
% =================================================================

[~,Scheck,~] = svd(Ztrain(:,1:end-1),'econ');

singularValues = diag(Scheck);

energy = cumsum(singularValues.^2) ...
       / sum(singularValues.^2);

energyThreshold = 1 - 1e-12;

rEnergy = find(energy >= energyThreshold,1,'first');

% Limit the rank to avoid retaining numerically negligible components.
maximumRank = 100;

r = min([
    rEnergy
    maximumRank
    size(Ztrain,2)-1
]);

fprintf('Selected DMD rank:       %d\n',r);
fprintf('Retained SVD energy:      %.12f\n',energy(r));

% ================================================================
% 9. CALL THE dmd.m FUNCTION
% =================================================================
%
% Your function internally constructs
%
%       X1 = Y(:,1:end-1)
%       X2 = Y(:,2:end)
%
% and returns the exact DMD modes and discrete-time eigenvalues.

[Phi,lambda,XdmdTraining,S1] = dmd(Ztrain,dt,r);

lambda = lambda(:);

fprintf('Number of DMD modes:      %d\n',numel(lambda));

% ================================================================
% 10. RECOMPUTE THE INITIAL MODAL AMPLITUDES
% =================================================================
%
% The supplied dmd.m computes this internally, but it does not return b.
% We recompute it so that the model can be evaluated beyond training.

z0 = Ztrain(:,1);

b = Phi\z0;

% ================================================================
% 11. OPTIONAL EIGENVALUE REGULARIZATION
% =================================================================
%
% First run with stabilizeEigenvalues = false.
%
% For this bounded periodic problem, eigenvalues slightly outside the
% unit circle are usually numerical artifacts. They may be projected
% onto the unit circle after inspecting the unmodified solution.

stabilizeEigenvalues = false;

lambdaModel = lambda;

if stabilizeEigenvalues

    rho = abs(lambdaModel);

    neutralTolerance = 0.05;

    nearlyNeutral = ...
        rho >= 1-neutralTolerance & ...
        rho <= 1+neutralTolerance & ...
        rho > eps;

    lambdaModel(nearlyNeutral) = ...
        lambdaModel(nearlyNeutral)./rho(nearlyNeutral);

    % Prevent clearly unstable numerical modes from exploding.
    unstable = abs(lambdaModel) > 1;

    lambdaModel(unstable) = ...
        lambdaModel(unstable)./abs(lambdaModel(unstable));
end

% ================================================================
% 12. RECONSTRUCTION AND EXTRAPOLATION
% =================================================================
%
% Discrete-time DMD evolution:
%
%       z_k = Phi*Lambda^(k-1)*b
%
% The discrete eigenvalues are used directly. This avoids unnecessary
% logarithms and branch ambiguities in the complex logarithm.

Zdmd = zeros(nAugmented,Nt);

for k = 1:Nt

    modalEvolution = lambdaModel.^(k-1);

    Zdmd(:,k) = real(Phi*(modalEvolution.*b));
end

% ================================================================
% 13. RECOVER THE PHYSICAL FIELD
% =================================================================

QdmdCentered = Zdmd(1:nField,:);

Qdmd = qMean + QdmdCentered;

% ================================================================
% 14. ERROR MEASURES
% =================================================================

snapshotError = zeros(1,Nt);

for k = 1:Nt

    snapshotError(k) = ...
        norm(Q(:,k)-Qdmd(:,k),2) ...
        / max(norm(Q(:,k),2),eps);
end

trainingError = ...
    norm(Q(:,1:nTrain)-Qdmd(:,1:nTrain),'fro') ...
    / norm(Q(:,1:nTrain),'fro');

forecastError = ...
    norm(Q(:,nTrain+1:end)-Qdmd(:,nTrain+1:end),'fro') ...
    / norm(Q(:,nTrain+1:end),'fro');

fprintf('\n');
fprintf('Relative training error:      %.6e\n',trainingError);
fprintf('Relative extrapolation error: %.6e\n',forecastError);

% ================================================================
% 15. CHECK THE INTERNAL RECONSTRUCTION RETURNED BY dmd.m
% =================================================================
%
% Your dmd.m returns nTrain-1 reconstructed augmented snapshots.

nInternal = size(XdmdTraining,2);

internalDifference = ...
    norm( ...
        real(XdmdTraining) - Zdmd(:,1:nInternal), ...
        'fro') ...
    / max(norm(real(XdmdTraining),'fro'),eps);

fprintf('Difference from dmd.m reconstruction: %.6e\n', ...
        internalDifference);

% ================================================================
% 16. SINGULAR VALUES
% =================================================================

figure( ...
    'Color','w', ...
    'Position',[100 100 850 420]);

    set(gcf, 'Color','none');

semilogy( ...
    1:numel(singularValues), ...
    singularValues/singularValues(1), ...
    'o-', ...
    'LineWidth',1.4, ...
    'MarkerSize',4);

hold on;

xline( ...
    r, ...
    '--', ...
    sprintf('r = %d',r), ...
    'LineWidth',1.5);

grid on;
box on;

xlabel('Singular-value index');
ylabel('\sigma_j/\sigma_1');
title('Singular values');

set(gca,'FontSize',14);

% ================================================================
% 17. DMD EIGENVALUES
% =================================================================

figure( ...
    'Color','w', ...
    'Position',[100 100 620 560]);

    set(gcf, 'Color','none');

theta = linspace(0,2*pi,500);

plot( ...
    cos(theta), ...
    sin(theta), ...
    'r--', ...
    'LineWidth',1.2);

hold on;

scatter( ...
    real(lambdaModel), ...
    imag(lambdaModel), ...
    55, ...
    abs(b), ...
    'filled');

axis equal;
grid on;
box on;

xlabel('Re(\lambda)');
ylabel('Im(\lambda)');
title('DMD eigenvalues');

colorbar;

set(gca,'FontSize',14);

% ================================================================
% 18. ERROR THROUGH TIME
% =================================================================

figure( ...
    'Color','w', ...
    'Position',[100 100 900 420]);

    set(gcf, 'Color','none');

semilogy( ...
    time, ...
    snapshotError, ...
    'LineWidth',1.8);

hold on;

xline( ...
    time(nTrain), ...
    'r--', ...
    'End of training', ...
    'LineWidth',1.5, ...
    'LabelVerticalAlignment','bottom');

grid on;
box on;

xlabel('Time');
ylabel('Relative snapshot error');
title('Training reconstruction and extrapolation error');

set(gca,'FontSize',14);

% ================================================================
% 19. SELECTED SNAPSHOTS
% =================================================================

selectedTimes = [
    t0
    t0 + 0.5*pi
    tTrainEnd
    tTrainEnd + 0.5*pi
    tFinal
];

selectedIndices = zeros(size(selectedTimes));

for j = 1:numel(selectedTimes)

    [~,selectedIndices(j)] = ...
        min(abs(time-selectedTimes(j)));
end

fieldMinimum = min(Q,[],'all');
fieldMaximum = max(Q,[],'all');

figure( ...
    'Color','w', ...
    'Position',[40 80 1500 570]);

    set(gcf, 'Color','none');

layout = tiledlayout( ...
    2, ...
    numel(selectedIndices), ...
    'Padding','compact', ...
    'TileSpacing','compact');

for j = 1:numel(selectedIndices)

    k = selectedIndices(j);

    exactField = reshape(Q(:,k),ny,nx);
    dmdField   = reshape(Qdmd(:,k),ny,nx);

    nexttile(j);

    contourf( ...
        x1,x2,exactField,50, ...
        'LineColor','none');

    axis image;
    clim([fieldMinimum fieldMaximum]);

    title(sprintf('Exact: t = %.2f',time(k)));

    if j == 1
        ylabel('x_2');
    end

    nexttile(numel(selectedIndices)+j);

    contourf( ...
        x1,x2,dmdField,50, ...
        'LineColor','none');

    axis image;
    clim([fieldMinimum fieldMaximum]);

    title(sprintf('DMD: error = %.2e',snapshotError(k)));
    xlabel('x_1');

    if j == 1
        ylabel('x_2');
    end
end

colormap(layout,turbo);

cb = colorbar;
cb.Layout.Tile = 'east';

% ================================================================
% 20. ANIMATED COMPARISON
% =================================================================

makeGIF     = true;
gifFile     = 'Rastrigin_Augmented_DMD.gif';
gifDelay    = 0.06;
frameStride = 2;

if makeGIF

    fig = figure( ...
        'Color','k', ...
        'Position',[80 80 1300 570]);

    layout = tiledlayout( ...
        fig,1,2, ...
        'Padding','compact', ...
        'TileSpacing','compact');

    axExact = nexttile(layout);
    axDMD   = nexttile(layout);

    colormap(fig,turbo);

    for k = 1:frameStride:Nt

        exactField = reshape(Q(:,k),ny,nx);
        dmdField   = reshape(Qdmd(:,k),ny,nx);

        cla(axExact);
        cla(axDMD);

        contourf( ...
            axExact,x1,x2,exactField,50, ...
            'LineColor','none');

        axis(axExact,'image');

        axis( ...
            axExact, ...
            [x1(1) x1(end) x2(1) x2(end)]);

        clim(axExact,[fieldMinimum fieldMaximum]);

        title( ...
            axExact, ...
            sprintf('Exact field: t = %.2f',time(k)), ...
            'Color','w', ...
            'FontSize',18);

        xlabel(axExact,'x_1','Color','w');
        ylabel(axExact,'x_2','Color','w');

        axExact.Color    = 'k';
        axExact.XColor   = 'w';
        axExact.YColor   = 'w';
        axExact.FontSize = 14;

        contourf( ...
            axDMD,x1,x2,dmdField,50, ...
            'LineColor','none');

        axis(axDMD,'image');

        axis( ...
            axDMD, ...
            [x1(1) x1(end) x2(1) x2(end)]);

        clim(axDMD,[fieldMinimum fieldMaximum]);

        if k <= nTrain
            intervalName = 'training';
        else
            intervalName = 'forecast';
        end

        title( ...
            axDMD, ...
            sprintf( ...
                'DMD (%s): error = %.2e', ...
                intervalName,snapshotError(k)), ...
            'Color','w', ...
            'FontSize',18);

        xlabel(axDMD,'x_1','Color','w');
        ylabel(axDMD,'x_2','Color','w');

        axDMD.Color    = 'k';
        axDMD.XColor   = 'w';
        axDMD.YColor   = 'w';
        axDMD.FontSize = 14;

        drawnow;

        frame = getframe(fig);
        rgbImage = frame2im(frame);

        [indexedImage,colorMap] = ...
            rgb2ind(rgbImage,256);

        if k == 1

            imwrite( ...
                indexedImage, ...
                colorMap, ...
                gifFile, ...
                'gif', ...
                'LoopCount',inf, ...
                'DelayTime',gifDelay);

        else

            imwrite( ...
                indexedImage, ...
                colorMap, ...
                gifFile, ...
                'gif', ...
                'WriteMode','append', ...
                'DelayTime',gifDelay);
        end
    end

    fprintf('\nGIF generated:\n%s\n', ...
        fullfile(pwd,gifFile));
end

% ================================================================
% LOCAL FUNCTION
% =================================================================

function dQdt = temporalDerivative(Q,dt)
%TEMPORALDERIVATIVE Fourth-order finite-difference approximation.
%
% Q(:,k) is the state at time t_k.

    [nVariables,nTimes] = size(Q);

    if nTimes < 5
        error('At least five snapshots are required.');
    end

    dQdt = zeros(nVariables,nTimes);

    % Fourth-order centered approximation.
    dQdt(:,3:nTimes-2) = ...
        ( ...
          Q(:,1:nTimes-4) ...
        - 8*Q(:,2:nTimes-3) ...
        + 8*Q(:,4:nTimes-1) ...
        - Q(:,5:nTimes) ...
        )/(12*dt);

    % Second-order forward formulas.
    dQdt(:,1) = ...
        (-3*Q(:,1)+4*Q(:,2)-Q(:,3))/(2*dt);

    dQdt(:,2) = ...
        (-3*Q(:,2)+4*Q(:,3)-Q(:,4))/(2*dt);

    % Second-order backward formulas.
    dQdt(:,nTimes-1) = ...
        ( ...
          3*Q(:,nTimes-1) ...
        - 4*Q(:,nTimes-2) ...
        + Q(:,nTimes-3) ...
        )/(2*dt);

    dQdt(:,nTimes) = ...
        ( ...
          3*Q(:,nTimes) ...
        - 4*Q(:,nTimes-1) ...
        + Q(:,nTimes-2) ...
        )/(2*dt);
end