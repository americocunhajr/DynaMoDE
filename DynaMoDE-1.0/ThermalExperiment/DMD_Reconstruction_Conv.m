clc; clear; close all;

%dados
% =========================================================
T1 = [23.12, 23.17, 23.19, 23.21, 23.23, 23.25, 23.27, 23.29, 23.31, 23.40, 23.42, 23.44, 23.46, 23.48, 23.51, 23.53, 23.57, 23.61, 23.63, 23.65, 23.68, 23.70, 23.72, 23.74, 23.76, 23.78, 23.80, 23.82, 23.85, 23.87, 23.91, 23.93, 23.95, 23.97, 23.99, 24.02, 24.04, 24.08, 24.10, 24.12, 24.14, 24.16, 24.19, 24.21, 24.23, 24.25, 24.29, 24.31, 24.33, 24.36, 24.38, 24.40, 24.42, 24.44, 24.46, 24.48, 24.50, 24.55, 24.59, 24.61, 24.63, 24.65, 24.67, 24.70, 24.72, 24.74, 24.76, 24.78, 24.82, 24.84, 24.87, 24.89, 24.91, 24.93, 24.95, 24.97, 24.99, 25.01, 25.04, 25.06, 25.08, 25.12, 25.14, 25.16, 25.18, 25.21, 25.23, 25.25, 25.27, 25.29, 25.31, 25.33, 25.36, 25.38, 25.40, 25.42, 25.44, 25.46, 25.48, 25.52, 25.55, 25.59, 25.63, 25.65, 25.67, 25.70, 25.74, 25.78, 25.80, 25.82, 25.84, 25.87, 25.89, 25.91, 25.95, 25.97, 25.99, 26.02, 26.04, 26.06, 26.08];

T2 = [22.00, 22.03, 22.06, 22.09, 22.12, 22.15, 22.18, 22.21, 22.24, 22.27, 22.30, 22.33, 22.36, 22.39, 22.42, 22.45, 22.48, 22.51, 22.54, 22.57, 22.60, 22.63, 22.66, 22.69, 22.72, 22.75, 22.78, 22.81, 22.84, 22.87, 22.90, 22.93, 22.96, 22.99, 23.02, 23.05, 23.08, 23.11, 23.14, 23.17, 23.20, 23.23, 23.26, 23.29, 23.32, 23.35, 23.38, 23.41, 23.44, 23.47, 23.50, 23.53, 23.56, 23.59, 23.62, 23.65, 23.68, 23.71, 23.74, 23.77, 23.80, 23.83, 23.86, 23.89, 23.92, 23.95, 23.98, 24.01, 24.04, 24.07, 24.10, 24.13, 24.16, 24.19, 24.22, 24.25, 24.28, 24.31, 24.34, 24.37, 24.40, 24.43, 24.46, 24.49, 24.52, 24.55, 24.58, 24.61, 24.64, 24.67, 24.70, 24.71, 24.73, 24.76, 24.79, 24.82, 24.85, 24.88, 24.91, 24.94, 24.97, 25.00, 25.02, 25.03, 25.06, 25.08, 25.09, 25.12, 25.15, 25.18, 25.21, 25.24, 25.27, 25.30, 25.33, 25.36, 25.39, 25.42, 25.45, 25.48, 25.51];

T3 = [22.70, 22.71, 22.72, 22.74, 22.76, 22.78, 22.80, 22.81, 22.82, 22.84, 22.86, 22.88, 22.90, 22.91, 22.92, 22.94, 22.96, 22.98, 23.00, 23.02, 23.03, 23.04, 23.06, 23.08, 23.10, 23.12, 23.14, 23.16, 23.18, 23.20, 23.22, 23.24, 23.26, 23.28, 23.30, 23.32, 23.34, 23.36, 23.38, 23.40, 23.42, 23.44, 23.46, 23.48, 23.50, 23.52, 23.54, 23.56, 23.58, 23.60, 23.62, 23.64, 23.66, 23.68, 23.70, 23.72, 23.74, 23.76, 23.78, 23.80, 23.82, 23.84, 23.86, 23.88, 23.90, 23.92, 23.94, 23.96, 23.98, 24.00, 24.02, 24.04, 24.06, 24.08, 24.10, 24.12, 24.14, 24.16, 24.18, 24.20, 24.22, 24.24, 24.26, 24.28, 24.30, 24.32, 24.34, 24.36, 24.38, 24.40, 24.42, 24.44, 24.46, 24.48, 24.50, 24.52, 24.54, 24.56, 24.58, 24.60, 24.62, 24.64, 24.66, 24.68, 24.70, 24.72, 24.73, 24.74, 24.76, 24.78, 24.80, 24.82, 24.84, 24.85, 24.86, 24.88, 24.90, 24.92, 24.94, 24.96, 24.98];


N = min([numel(T1), numel(T2), numel(T3)]);
T1 = T1(1:N); T2 = T2(1:N); T3 = T3(1:N);

%ruido
% =========================================================
sigma = 0.01;
T1_noise = T1 + sigma*randn(size(T1));
T2_noise = T2 + sigma*randn(size(T2));
T3_noise = T3 + sigma*randn(size(T3));
%matriz de dados
X = [T1_noise; T2_noise; T3_noise];


%svd
% =========================================================
[U,S,V] = svd(X,'econ');

num_modos_desejado = 2;                       %ajustar quantidade de modos 
num_modos = min(num_modos_desejado, size(U,2));

modes = U(:,1:num_modos);

X_reconstructed = modes * S(1:num_modos,1:num_modos) * V(:,1:num_modos)';



%plots
% =========================================================

%estilo
fontNm  = 'Times New Roman';
fsTitle = 18;
fsLab   = 16;
fsTick  = 14;

%vetor t
t = linspace(0, 30, size(X_reconstructed,2));

K = min(3, num_modos);

%p aumentar
fig = figure('Color','w','Units','centimeters','Position',[2 2 46 16]);


bottom = 0.10;
top    = 0.92;
height = top - bottom;

Lx = 0.03;  Lw = 0.48;   
Rx = 0.54;  Rw = 0.38;   


gapLR = 0.01;
Cx = Lx + Lw + gapLR;
rightLimit = Rx - 0.01;
Cw = max(0.010, rightLimit - Cx);


gap = 0.03;
h_each = (height - (K-1)*gap)/K;
clim = [min(X_reconstructed(:)) max(X_reconstructed(:))];

%esquerda o campo de temperatua
for i = 1:K
    y_i = bottom + (K-i)*(h_each + gap);

    axT = axes('Parent',fig,'Position',[Lx y_i Lw h_each]);
    imagesc(axT, t, 1, X_reconstructed(i,:));
    set(axT,'YDir','normal');
    colormap(axT, turbo);
    caxis(axT, clim);
    grid(axT,'on');

    if i == 1
        title(axT,'Reconstructed Temperature', 'FontSize',fsTitle,'FontName',fontNm);
    end

    yticks(axT,1);
    yticklabels(axT,{sprintf('T%d',i)});
    set(axT,'FontSize',fsTick,'FontName',fontNm,'LineWidth',1.2);

    if i == K
        xlabel(axT,'Time (s)','FontSize',fsLab,'FontName',fontNm);
    else
        set(axT,'XTickLabel',[]);
    end
end


axCB = axes('Parent',fig,'Position',[Lx bottom Lw height],'Visible','off');
colormap(axCB, turbo);
caxis(axCB, clim);
cb = colorbar(axCB,'Position',[Cx bottom Cw height]);
ylabel(cb,'Temperature (°C)','FontSize',fsLab,'FontName',fontNm);
set(cb,'FontSize',fsTick,'FontName',fontNm);

%esquerda modos
for i = 1:K
    y_i = bottom + (K-i)*(h_each + gap);

    axM = axes('Parent',fig,'Position',[Rx y_i Rw h_each]);
    plot(axM, modes(:,i), 'LineWidth', 2.0);
    grid(axM,'on');

    title(axM, sprintf('Dynamic Mode %d', i), 'FontSize',fsTitle-2,'FontName',fontNm);

    set(axM,'FontSize',fsTick,'FontName',fontNm,'LineWidth',1.2);

    if i == K
        xlabel(axM,'Position Index','FontSize',fsLab,'FontName',fontNm);
    else
        set(axM,'XTickLabel',[]);
    end

    set(axM,'YAxisLocation','right');
    yl = ylabel(axM,'Amplitude','FontSize',fsLab,'FontName',fontNm);
    yl.Units = 'normalized';
    yl.Position(1) = 1.08;  
end





%plot de tudo
% ==========================================================

fontNm  = 'Times New Roman';
fsTitle = 18;
fsLab   = 16;
fsTick  = 14;

t = linspace(0, 30, size(X_reconstructed,2));

K_left = 3;


K_right = num_modos;

%aumentar
fig = figure('Color','w','Units','centimeters','Position',[2 2 46 16]);

bottom = 0.10;
top    = 0.92;
height = top - bottom;

Lx = 0.03;  Lw = 0.48;   
Rx = 0.54;  Rw = 0.38;   
gapLR = 0.01;
Cx = Lx + Lw + gapLR;
rightLimit = Rx - 0.01;
Cw = max(0.010, rightLimit - Cx);


gap = 0.03;

h_left  = (height - (K_left-1)*gap)/K_left;
h_right = (height - (K_right-1)*gap)/K_right;

clim = [min(X_reconstructed(:)) max(X_reconstructed(:))];

%direita temps
% =========================================================
for i = 1:K_left
    y_i = bottom + (K_left-i)*(h_left + gap);

    axT = axes('Parent',fig,'Position',[Lx y_i Lw h_left]);
    imagesc(axT, t, 1, X_reconstructed(i,:));
    set(axT,'YDir','normal');
    colormap(axT, turbo);
    caxis(axT, clim);
    grid(axT,'on');

    if i == 1
        title(axT,'Reconstructed Temperature', ...
            'FontSize',fsTitle,'FontName',fontNm);
    end

    yticks(axT,1);
    yticklabels(axT,{sprintf('T%d',i)});
    set(axT,'FontSize',fsTick,'FontName',fontNm,'LineWidth',1.2);

    if i == K_left
        xlabel(axT,'Time (s)','FontSize',fsLab,'FontName',fontNm);
    else
        set(axT,'XTickLabel',[]);
    end
end


axCB = axes('Parent',fig,'Position',[Lx bottom Lw height],'Visible','off');
colormap(axCB, turbo);
caxis(axCB, clim);
cb = colorbar(axCB,'Position',[Cx bottom Cw height]);
ylabel(cb,'Temperature (°C)','FontSize',fsLab,'FontName',fontNm);
set(cb,'FontSize',fsTick,'FontName',fontNm);

%modos a esquerda
% =========================================================
for i = 1:K_right
    y_i = bottom + (K_right-i)*(h_right + gap);

    axM = axes('Parent',fig,'Position',[Rx y_i Rw h_right]);
    plot(axM, modes(:,i), 'LineWidth', 2.0);
    grid(axM,'on');

    title(axM, sprintf('Dynamic Mode %d', i), ...
        'FontSize',fsTitle-2,'FontName',fontNm);

    set(axM,'FontSize',fsTick,'FontName',fontNm,'LineWidth',1.2);

    if i == K_right
        xlabel(axM,'Position Index','FontSize',fsLab,'FontName',fontNm);
    else
        set(axM,'XTickLabel',[]);
    end

    set(axM,'YAxisLocation','right');
    yl = ylabel(axM,'Amplitude','FontSize',fsLab,'FontName',fontNm);
    yl.Units = 'normalized';
    yl.Position(1) = 1.08;
end


