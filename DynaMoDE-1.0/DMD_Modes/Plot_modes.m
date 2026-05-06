%Author: Lucas Simon Araújo
% Last modified: 13/04/2024

% Plot modes
% Ackley, Rastrigin, Schaffer, Griewank test functions
% Input: 
%            dynamic field data
% Output:
%           modes plot
%           frequency plot

clear; close all; clc;
%-------------------------------------------------
% User's entries
%load data
load ..\Dynamic_Field_Generator\ack_dyn_field.mat x1 x2
load ack_modes.mat r Phi lambda 

%function name for figure files
name = "ack";

%record charts? (yes/no)
rec = 'yes';

%which charts?  (yes/no)
Mode = "yes";    % mode by mode
Modes = "no";  % collection of modes
modes = [1,5,7,9,11,14];    % 6 main modes used in the previous collection of modes
Frequencies = "no";   % frequency plot
%-------------------------------------------------

% recover field dimensions 
% using reconstructed, once it's 1 snap smaller
m = size(Phi,1);
n = size(Phi,2);

% compute field limits
mag_Phi = mag_com(Phi);
min_Phi = min(mag_Phi,[],"all");
max_Phi = max(mag_Phi,[],"all");


%% Mode by Mode
%initiallizing figures
if Mode == "yes"
    a = figure;
    a.Position = [314    42   762   642];
    
    for mode = 1: r
        %Plot mode by mode
        figure(a)    
        colormap("turbo")
        contourf(x1,x2,mag_Phi(:,:,mode));
        colorbar;     %clim([min_Phi max_Phi]);    
        xlabel('x_1');    ylabel('x_2');
        box on;
        axis equal
        ax = gca;    ax.FontSize = 20;
        axis([x1(1) x1(end) x2(1) x2(end)])
        % set(gcf, 'color', 'none');    
        % set(gca, 'color', 'none');
    
        % saving the figure
        if (rec == "yes") 
            saveas(a,strcat(name,'_mode_',num2str(mode)),'png')
        end    
    end
end

%% Plot all modes
if Modes == "yes"
    %initiallizing figures
    b = figure;
    b.Position = [144     42    1078   642];
    figure(b)
    t = tiledlayout(2, 3, 'Padding', 'none', 'TileSpacing', 'compact');
    
    plot_mode(x1,x2,mag_Phi,modes(1),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(1))));
    ax = gca; 
    ax.XTick = []; 

    plot_mode(x1,x2,mag_Phi,modes(2),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(2))));
    ax = gca; 
    ax.XTick = [];  ax.YTick = [];

    plot_mode(x1,x2,mag_Phi,modes(3),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(3))));
    ax = gca; 
    ax.XTick = [];   ax.YTick = [];
    colorbar
    %------------------------------------------------
    plot_mode(x1,x2,mag_Phi,modes(4),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(4))));
    ax = gca; 

    plot_mode(x1,x2,mag_Phi,modes(5),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(5))));
    ax = gca; 
    ax.YTick = [];;

    plot_mode(x1,x2,mag_Phi,modes(6),min_Phi,max_Phi)
    title(strcat('r = ',num2str(modes(6))));
    ax = gca;
    ax.YTick = [];
    colorbar

    xlabel(t, 'x_1', 'FontSize', 20)
    ylabel(t, 'x_2', 'FontSize', 20)
    
    % set(gcf, 'color', 'none');    

    % saving the figure
    if (rec == "yes") 
        saveas(b,strcat(name,'_modes'),'epsc')
    end   
end

%% Plot frequencies
if Frequencies == "yes"
    c = figure;
    figure(c);
    plot(real(lambda),imag(lambda),'ok','MarkerSize',10,'LineWidth',2)
    %plot unit circle
    hold on
    fplot(@(t) sin(t), @(t) cos(t), 'r','LineWidth',2);
    grid on;
    axis equal;
    box on;
    ax = gca;    ax.FontSize = 20;
    % set(gcf, 'color', 'none');    
    % set(gca, 'color', 'none');

    % saving the figure
    if (rec == "yes") 
        saveas(c,strcat(name,'_freqs'),'epsc')
    end   
end

%% Acessory function
function plot_mode(x1,x2,Phi,r,min_Phi,max_Phi)
    nexttile
    colormap("turbo")
    contourf(x1,x2,Phi(:,:,r));
    %colorbar;     
    clim([min_Phi max_Phi]);    
    %xlabel('x_1');    ylabel('x_2');
    box on;
    axis equal
    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])
end

function magnitude = mag_com(field)
    magnitude = sqrt(real(field).^2 + imag(field).^2);
end