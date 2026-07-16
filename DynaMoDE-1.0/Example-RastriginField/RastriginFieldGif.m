%% RastriginFieldGif.m
% Animated dynamic Rastrigin field
%
% Required file:
%   rastrigin.m
%
% The animation is written directly to a GIF, avoiding storage of the
% complete three-dimensional spatio-temporal field.

clear;
close all;
clc;

% User settings

m = 100;                    % Number of points along x_1
n = 100;                    % Number of points along x_2
nFrames = 100;              % Number of animation frames

time = linspace(0.1, 3*pi - 0.1, nFrames);

gifFile = 'rastrigin_dynamic_field.gif';

delayTime = 0.08;           % Time between frames [s]
numberOfLevels = 50;        % Number of contour levels

x1 = linspace(-5.12, 5.12, m);
x2 = linspace(-5.12, 5.12, n);

% First pass: determine fixed color limits

% Fixed limits are important: otherwise, every frame rescales its colors
% and the apparent dynamics become misleading.

minimumField = inf;
maximumField = -inf;

for k = 1:nFrames

    scale = sin(time(k));

    x1Dynamic = scale*x1;
    x2Dynamic = scale*x2;

    currentField = rastrigin([x1Dynamic; x2Dynamic]);

    minimumField = min(minimumField, min(currentField, [], 'all'));
    maximumField = max(maximumField, max(currentField, [], 'all'));

end

fprintf('Global field range: [%g, %g]\n', ...
        minimumField, maximumField);

% Prepare figure

fig = figure( ...
    'Color', 'k', ...
    'Position', [100, 100, 760, 680], ...
    'Renderer', 'opengl');

ax = axes(fig);

ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.FontSize = 18;
ax.LineWidth = 1.2;

colormap(ax, turbo(256));

% Second pass: generate the GIF

for k = 1:nFrames

    scale = sin(time(k));

    x1Dynamic = scale*x1;
    x2Dynamic = scale*x2;

    currentField = rastrigin([x1Dynamic; x2Dynamic]);

    cla(ax);

    contourf( ...
        ax, ...
        x1, ...
        x2, ...
        currentField, ...
        numberOfLevels, ...
        'LineColor', 'none');

    axis(ax, 'image');
    axis(ax, [x1(1), x1(end), x2(1), x2(end)]);

    clim(ax, [minimumField, maximumField]);

    xlabel(ax, '$x_1$', ...
        'Interpreter', 'latex', ...
        'Color', 'w', ...
        'FontSize', 22);

    ylabel(ax, '$x_2$', ...
        'Interpreter', 'latex', ...
        'Color', 'w', ...
        'FontSize', 22);

    title(ax, ...
        sprintf('$t_{%d}$', k), ...
        'Interpreter', 'latex', ...
        'Color', 'w', ...
        'FontSize', 24);

    colorbarHandle = colorbar(ax);
    colorbarHandle.Color = 'w';
    colorbarHandle.FontSize = 15;

    drawnow;

    %% Convert current figure to an indexed image

    frame = getframe(fig);
    rgbImage = frame2im(frame);
    [indexedImage, colorMap] = rgb2ind(rgbImage, 256);

    % Write frame

    if k == 1
        imwrite( ...
            indexedImage, ...
            colorMap, ...
            gifFile, ...
            'gif', ...
            'LoopCount', inf, ...
            'DelayTime', delayTime);
    else
        imwrite( ...
            indexedImage, ...
            colorMap, ...
            gifFile, ...
            'gif', ...
            'WriteMode', 'append', ...
            'DelayTime', delayTime);
    end

end

fprintf('GIF successfully generated:\n%s\n', ...
        fullfile(pwd, gifFile));