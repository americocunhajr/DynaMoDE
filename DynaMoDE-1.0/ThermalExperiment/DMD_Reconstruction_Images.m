clc;
clear;
close all;

%video
% =========================================================

videoPath = 'C:\Users\Maria\OneDrive\Documentos\FACULDADE\IC\chapa conducao imagens\videos\video_degradado.mp4';

if ~exist(videoPath, 'file')
    error('Video file not found at the specified path.');
end

% numero de modos r
% =========================================================

r = 1;

%carregando 
% =========================================================

vidObj = VideoReader(videoPath);

Nx = vidObj.Width;      
Ny = vidObj.Height;     
dt = 1 / vidObj.FrameRate;


%ler os frames em rgb
% =========================================================

T_red   = [];
T_green = [];
T_blue  = [];

k = 0;

while hasFrame(vidObj)

    frame = readFrame(vidObj);
    k = k + 1;

    if size(frame,3) ~= 3
        error('Frame %d does not have RGB channels.', k);
    end

    fr = single(double(frame(:,:,1)) / 255);
    fg = single(double(frame(:,:,2)) / 255);
    fb = single(double(frame(:,:,3)) / 255);

    if k == 1
        T_red   = zeros(Nx*Ny, 1, 'single');
        T_green = zeros(Nx*Ny, 1, 'single');
        T_blue  = zeros(Nx*Ny, 1, 'single');
    end

    T_red(:,k)   = fr(:);
    T_green(:,k) = fg(:);
    T_blue(:,k)  = fb(:);

end

Nt = k;

fprintf('Read %d frames (%dx%d)\n', Nt, Ny, Nx);


%aplicar dmd
% =========================================================

[Xdmd_red,   Phi_red,   ~, r_eff] = applyDMD(T_red,   r, dt);
[Xdmd_green, Phi_green, ~, ~    ] = applyDMD(T_green, r, dt);
[Xdmd_blue,  Phi_blue,  ~, ~    ] = applyDMD(T_blue,  r, dt);

fprintf('Effective rank used: r = %d\n', r_eff);


%fig. 1
%frames originais X recontruídos
% =========================================================

frames_to_plot = [1 10 20 30 40];
frames_to_plot = frames_to_plot(frames_to_plot >= 1 & ...
                                frames_to_plot <= Nt);

nF = numel(frames_to_plot);

fig1 = figure('Color','w', ...
              'Units','centimeters', ...
              'Position',[2 2 30 14]);

tiledlayout(fig1, 2, nF, ...
            'Padding','compact', ...
            'TileSpacing','compact');

for i = 1:nF

    t = frames_to_plot(i);

  
    %frames originais -----------------------------------------------------

    original_rgb = cat(3, ...
        reshape(T_red(:,t),   Ny, Nx), ...
        reshape(T_green(:,t), Ny, Nx), ...
        reshape(T_blue(:,t),  Ny, Nx));

    
    %frames reconstruídos
    % -----------------------------------------------------

    recon_rgb = cat(3, ...
        reshape(Xdmd_red(:,t),   Ny, Nx), ...
        reshape(Xdmd_green(:,t), Ny, Nx), ...
        reshape(Xdmd_blue(:,t),  Ny, Nx));

    recon_rgb = max(min(recon_rgb,1),0);


    nexttile(i);

    imshow(original_rgb, 'Border','tight');
    axis image off;

    title(sprintf('t = %d', t), ...
          'FontSize', 14, ...
          'FontName','Times New Roman');

 

    nexttile(i+nF);

    imshow(recon_rgb, 'Border','tight');
    axis image off;

    title(sprintf('Reconstructed (r = %d)', r_eff), ...
          'FontSize', 13, ...
          'FontName','Times New Roman');

end



%fig. 2
%modos
% =========================================================

num_modos = min(r_eff, size(Phi_red,2));

nCols = 5;
nRows = ceil(num_modos / nCols);

fig2 = figure('Color','w', ...
              'Units','pixels', ...
              'Position',[50 50 1800 1000]);

tiledlayout(fig2, nRows, nCols, ...
            'Padding','compact', ...
            'TileSpacing','compact');

for i = 1:num_modos

    nexttile;

    plot(abs(Phi_red(:, i)), ...
         'LineWidth', 1.2);

    grid on;
    box on;

    title(sprintf('Mode %d', i), ...
          'FontSize', 12, ...
          'FontName','Times New Roman');

    xlabel('Pixels', ...
           'FontSize', 10, ...
           'FontName','Times New Roman');

    ylabel('$|\phi_j|$', ...
           'Interpreter','latex', ...
           'FontSize', 11);

    set(gca, ...
        'FontSize', 9, ...
        'FontName','Times New Roman');

end


%função: applyDMD
% =========================================================

function [Xdmd, Phi, singular_values, r_eff] = applyDMD(X, r, dt)

%estado
    X1 = double(X(:,1:end-1));
    X2 = double(X(:,2:end));

    %svd
    [U,S,V] = svd(X1, 'econ');

    %valores singulares
    singular_values = diag(S);

    r_eff = min([r, size(U,2), numel(singular_values)]);
%truncando
    U_r = U(:,1:r_eff);
    S_r = S(1:r_eff,1:r_eff);
    V_r = V(:,1:r_eff);
%operador
    A_tilde = U_r' * X2 * V_r / S_r;
%autovalores e autovetores
    [W,Lambda] = eig(A_tilde);
%modos
    Phi = U_r * W;


    b = Phi \ double(X(:,1));


    lambda = diag(Lambda);

    omega = log(lambda) / dt;
%vetor temp
    t = (0:size(X,2)-1) * dt;

%evolução
    time_dynamics = exp(omega * t);

    %rec
    % -----------------------------------------------------

    Xdmd = real(Phi * bsxfun(@times, b, time_dynamics));

end