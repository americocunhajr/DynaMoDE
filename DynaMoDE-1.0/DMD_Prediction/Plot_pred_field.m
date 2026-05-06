%Author: Lucas Simon Araújo
% Last modified: 25/03/2024

% Plot the comparison: dynamic fields and predicted ones
% Input: 
%            dynamic field data
% Output:
%           contour_plot comparison
%           surface plot comparison
%           instants plot comparison

clear; close all; clc;
%-------------------------------------------------
% User's entries
% load data
load ..\Dynamic_Field_Generator\ack_dyn_field.mat field x1 x2
load ack_pred_field.mat field_p

%function name for figure files
name = "ack";

% record charts? (yes/no)
rec = 'yes';

% which charts to plot?
Cont = 'no';   %contour
Surf = 'no';   %surface
Insts = 'yes';  %instants
instants = [1,50,100,120];  %instants you want to compare
%-------------------------------------------------

% recover field dimensions 
% using reconstructed, once it's 1 snap smaller
m = size(field_p,1);
n = size(field_p,2);
snaps = size(field_p,3);

% compute field limits
mag_field = mag_com(field);
min_field = min(mag_field,[],"all");
max_field = max(mag_field,[],"all");

mag_field_p = mag_com(field_p);
min_field_p = min(mag_field_p,[],"all");
max_field_p = max(mag_field_p,[],"all");

%% CONTOUR
% initiallizing figures
if Cont == "yes"
    a = figure;
    a.Position = [160 123 1004 473];
    for t = 1: snaps
        figure(a)
        t1 = tiledlayout(1,2, 'Padding', 'none', 'TileSpacing', 'compact');

        %Plot original field
        %plotting must be separed once original field has less instants than predicted
        
        %plot original field evolution while there is new instants 
        if t<size(mag_field,3)  
            nexttile(1)
            colormap("turbo")
            contourf(x1,x2,mag_field(:,:,t));
            clim([min_field_p max_field_p]);
            xlabel('x_1');    ylabel('x_2');
            box on;
            ax = gca;    ax.FontSize = 20;
            axis([x1(1) x1(end) x2(1) x2(end)])
        % when reach the last instant fix plotting it 
        else
            nexttile(1)
            colormap("turbo")
            contourf(x1,x2,mag_field(:,:,end));
            clim([min_field_p max_field_p]);
            xlabel('x_1');    ylabel('x_2');
            box on;
            ax = gca;    ax.FontSize = 20;
            axis([x1(1) x1(end) x2(1) x2(end)])
        end

        %Plot predicted field

        nexttile(2)
        colormap("turbo")
        contourf(x1,x2,mag_field_p(:,:,t));
        colorbar;    clim([min_field_p max_field_p]);
        xlabel('x_1');   
        box on;
        ax = gca;    ax.FontSize = 20;
        axis([x1(1) x1(end) x2(1) x2(end)])
        % saving snapshots
        if rec == "yes"
            saveas(a,strcat(name,'_or_pred_cont_',num2str(t)),'png')
        end
    end
end

%% SURFACE
if Surf == "yes"
    b = figure;
    b.Position = [160 123 1004 473];
    for t = 1: snaps
        figure(b)
        t2 = tiledlayout(1,2, 'Padding', 'none', 'TileSpacing', 'compact');

        %Plot original field
        %plotting must be separed once original field has less instants than predicted
        
        %plot original field evolution while there is new instants 
        if t<size(mag_field,3)
            nexttile(1)
            colormap("turbo");
            s = surf(x1,x2,mag_field(:,:,t));
            s.EdgeColor = 'none';    s.FaceColor = 'interp';
            clim([min_field_p max_field_p]);
            xlabel('x_1');    ylabel('x_2');
            ax = gca;    ax.FontSize = 20;
            axis([x1(1) x1(end) x2(1) x2(end) min_field_p max_field_p])
        % when reach the last instant fix plotting it 
        else
            nexttile(1)
            colormap("turbo");
            s = surf(x1,x2,mag_field(:,:,end));
            s.EdgeColor = 'none';    s.FaceColor = 'interp';
            clim([min_field_p max_field_p]);
            xlabel('x_1');    ylabel('x_2');
            ax = gca;    ax.FontSize = 20;
            axis([x1(1) x1(end) x2(1) x2(end) min_field_p max_field_p])
        end
        
        % Plot predicted field
        nexttile(2)
        colormap("turbo");
        s = surf(x1,x2,mag_field_p(:,:,t));
        s.EdgeColor = 'none';    s.FaceColor = 'interp';
        colorbar;    clim([min_field_p max_field_p]);
        xlabel('x_1');    ylabel('x_2');
        ax = gca;    ax.FontSize = 20;
        axis([x1(1) x1(end) x2(1) x2(end) min_field_p max_field_p])
        % saving snapshots
        if rec == "yes"
            saveas(b,strcat(name,'_or_pred_surf_',num2str(t)),'png')
        end
    end
end


%% INSTANTS
if Insts =="yes"
    %storing time steps
    y1 = mag_field(:,:,instants(1));
    y2 = mag_field(:,:,instants(2));
    y3 = mag_field(:,:,instants(3));

    y1_p = mag_field_p(:,:,instants(1));
    y2_p = mag_field_p(:,:,instants(2));
    y3_p = mag_field_p(:,:,instants(3));
    y4_p = mag_field_p(:,:,instants(4));

    %initiallizing figure
    c = figure;
    c.Position = [40          42        1297         642];
    figure(c)
    t3 = tiledlayout(2,4, 'Padding', 'none', 'TileSpacing', 'compact');
    colormap("turbo")
    
    % original field in the first row
    nexttile(1)
    contourf(x1,x2,y1); clim([min_field max_field]);
    title(['t_{' num2str(instants(1)) '}']);
    ylabel('x_2');  axis equal;
    ax = gca;   ax.FontSize = 20;   ax.XTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile(2)
    contourf(x1,x2,y2); clim([min_field max_field])
    title(['t_{' num2str(instants(2)) '}'])
    axis equal; ax = gca;   ax.FontSize = 20;   ax.XTick = [];  ax.YTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile(3)
    contourf(x1,x2,y3); colorbar;   clim([min_field max_field])
    title(['t_{' num2str(instants(3)) '}'])
    axis equal; ax = gca;   ax.FontSize = 20;   ax.XTick = [];  ax.YTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    % reconstructed field in the second row
    nexttile(5)
    contourf(x1,x2,y1_p); clim([min_field_p max_field_p]);
    ylabel('x_2');  axis equal;
    ax = gca;   ax.FontSize = 20;   
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile(6)
    contourf(x1,x2,y2_p); clim([min_field_p max_field_p])
    xlabel('x_1');  axis equal;
    ax = gca;   ax.FontSize = 20;   ax.YTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile(7)
    contourf(x1,x2,y3_p); clim([min_field_p max_field_p])
    axis equal; ax = gca;   ax.FontSize = 20;   ax.YTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    nexttile(8)
    contourf(x1,x2,y4_p); colorbar;   clim([min_field_p max_field_p])
    axis equal; ax = gca;   ax.FontSize = 20;   ax.YTick = [];
    axis([x1(1) x1(end) x2(1) x2(end)])

    %saving figure
    if rec == "yes"        
        saveas(c,strcat(name,'_or_recon_inst'),'epsc')
    end
end

%% Acessory function

function magnitude = mag_com(field)
    magnitude = sqrt(real(field).^2 + imag(field).^2);
end