%Author: Lucas Simon Araújo
% Last modified: 12/04/2024

% Plot the dynamic fields for the optimization benchmark 
% Ackley, Rastrigin, Schaffer, Griewank test functions
% Input: 
%            dynamic field data
% Output:
%           contour_plot
%           surface plot
%           instants plot
clear; close all; clc;
%-----------------------------------------------------------------
% User's entries
%choose function
opt = 'ackley';
%record charts? (yes/no)
rec = 'no';
%which charts to plot?
Cont = 'yes';   %contour
Surf = 'yes';   %surface
Insts = 'yes';  %instants
instants = [1,50,100];
%-----------------------------------------------------------------
%load data
switch opt
    case 'ackley'
        load ack_dyn_field.mat field x1 x2
    case 'rastrigin'
        load ras_dyn_field.mat field x1 x2
    case 'schaffer'
        load sch_dyn_field.mat field x1 x2
    case 'griewank'
        load grie_dyn_field.mat field x1 x2
end
%recover field data
m = size(field,1);
n = size(field,2);
snaps = size(field,3);

%compute limits
mag_field = mag_com(field);
min_field = min(mag_field,[],"all");
max_field = max(mag_field,[],"all");

%% Plotting

%initiallizing figures
a = figure;
a.Position = [ 338    42   723   642];
b = figure;
b.Position = [ 338    42   723   642];

for t = 1: snaps
    % CONTOUR
    if Cont == "yes"
        figure(a)
        plot_contour(x1,x2,mag_com(field(:,:,t)),min_field,max_field);
    end

    % SURFACE
    if Surf == "yes"
        figure(b)
        plot_surface(x1,x2,mag_com(field(:,:,t)),min_field,max_field);
    end

    if rec == "yes"
        if opt == "ackley"
            saveas(a,['ack_dyn_cont_',num2str(t),'.png'])
            saveas(b,['ack_dyn_surf_',num2str(t),'.png'])
        elseif opt == "rastrigin"
            saveas(a,['ras_dyn_cont_',num2str(t),'.png'])
            saveas(b,['ras_dyn_surf_',num2str(t),'.png'])
        elseif opt == "schaffer"
            saveas(a,['sch_dyn_cont_',num2str(t),'.png'])
            saveas(b,['sch_dyn_surf_',num2str(t),'.png'])
        elseif opt == "griewank"
            saveas(a,['grie_dyn_cont_',num2str(t),'.png'])
            saveas(b,['grie_dyn_surf_',num2str(t),'.png'])
        end
    end
end

%% INSTANTS
if Insts =="yes"
    c = figure;     c.Position = [2 135 1360 512];
    figure(c)
    plot_instants(x1,x2,mag_com(field),min_field,max_field,instants);
    if rec == "yes"
        if opt == "ackley"
            saveas(c,'ack_dyn_inst','epsc')
        elseif opt == "rastrigin"
            saveas(c,'ras_dyn_inst','epsc')
        elseif opt == "schaffer"
            saveas(c,'sch_dyn_inst','epsc')
        elseif opt == "griewank"
            saveas(c,'grie_dyn_inst','epsc')
        end
    end
end

%------------------------------------------------
% Acessory functions
%------------------------------------------------

function plot_contour(x1,x2,field,min_field,max_field)
    colormap("turbo")
    contourf(x1,x2,field);
    colorbar;    clim([min_field max_field]);
    xlabel('x_1');    ylabel('x_2');
    % xticks(-5:5);    % xticks(-16:4:16);
    % yticks(-5:5);    % yticks(-16:4:16);
    box on;    axis equal;
    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])
end

function plot_surface(x1,x2,field,min_field,max_field)
    colormap("turbo")
    s = surf(x1,x2,field);
    s.EdgeColor = 'none';    s.FaceColor = 'interp';
    colorbar;    clim([min_field max_field]);
    xlabel('x_1');    ylabel('x_2');
    % box on    % axis equal
    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])
end

function plot_instants(x1,x2,field,min_field,max_field,instants)
    t = tiledlayout(1,3, 'Padding', 'none', 'TileSpacing', 'compact');
    %storing time steps
    y1 = field(:,:,instants(1));
    y2 = field(:,:,instants(2));
    y3 = field(:,:,instants(3));

    colormap("turbo")

    nexttile
    contourf(x1,x2,y1)
    clim([min_field max_field])
    title(['t_{' num2str(instants(1)) '}'])
    ylabel('x_2')
    axis equal;    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile
    contourf(x1,x2,y2)
    clim([min_field max_field])
    title(['t_{' num2str(instants(2)) '}'])
    xlabel('x_1')
    axis equal;    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])
    
    nexttile
    contourf(x1,x2,y3)
    colorbar;    clim([min_field max_field]);
    title(['t_{' num2str(instants(3)) '}'])
    axis equal;    ax = gca;    ax.FontSize = 20;
    axis([x1(1) x1(end) x2(1) x2(end)])
end

function magnitude = mag_com(field)
    magnitude = sqrt(real(field).^2 + imag(field).^2);
end