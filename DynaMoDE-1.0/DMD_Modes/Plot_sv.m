% Author: Lucas Simon Araújo
% Last modified: 12/04/2024
%----------------------------------------------------------
% Plot singular values from the dynamic field
% Input: 
%            dynamic field data
% Output:
%           singular values plot with truncation indication
%           file with the SVD components 
%----------------------------------------------------------

clear; close all; clc;
%----------------------------------------------------------
% User's entries
% load data
load grie_svd S1

% region of truncation
% r = 19;     % Ackley
% r = 7;       % Rastrigin
% r = 1;       % Schaffer
r = 2;       % Griewank

%----------------------------------------------------------

% verifying how many modes to truncate trough the diagonal matrix S relevance
a = figure;     a.Position = [3 42 1362 642];
hold on
xregion(0,r,'FaceColor',[0.65 0.65 0.65])
S2 = diag(S1);
Smax = max(S2);
Smin = min(S2);
deltaS = Smax - Smin;
stem(1:25,S2(1:25),'filled','--','Color','k','LineWidth',1,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',10)  %or
xlim([0 26]);   ylim([0 (Smax+0.75*deltaS)]);
xticks(1:25);   xtickangle(0);
hold off
ax = gca;   ax.FontSize = 20;
set(ax,'yscal','log')
box on
% axis square   %grid on;
ylabel('Singular Value');    xlabel('Singular Value Index');