% Author: Lucas Simon Araujo
% Last Modified: 13/04/2024

% Avaliation of the truncation influence into the similarity between
% original and DMD reconstruction
% Input:
%           *dynamic field
%           *truncation
% Output:
%           *similarity vs truncation plot
clear; close all; clc;
%----------------------------------------------
% User's entries
load grie_sim_trunc.mat R cos_theta

% name of the similarity file
name = "grie_sim_trunc.mat";

% region of truncation
% r = 19;     % Ackley
% r = 7;       % Rastrigin
% r = 1;       % Schaffer
r = 2;       % Griewank
%----------------------------------------------

figure
hold on
xregion(0,r,'FaceColor',[0.65 0.65 0.65])
%yline(1,'k','LineWidth',3)
stem(R,real(cos_theta),'filled','--','Color','k','LineWidth',1,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',10)
%stem(R,real(cos_theta),'filled',':r','MarkerSize',6,'LineWidth',3)
hold off
xlabel('Truncation threshold')
xticks(R)
xtickangle(0)
ylabel('Similarity measure')
xlim([R(1)-1 R(end)+1])
% xlim([0 26])
% ylim([0.999*min(real(cos_theta)) 1.001*max(real(cos_theta))])
ylim([0.9 1])
%axis([R(1) R(end) 0.9*min(real(cos_theta)) 1.1*max(real(cos_theta))] )
% axis square
box on
% grid on
ax = gca;
ax.FontSize = 20;