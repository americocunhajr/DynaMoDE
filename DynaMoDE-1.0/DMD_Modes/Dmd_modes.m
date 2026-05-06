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
% load data
load ..\Dynamic_Field_Generator\sch_dyn_field.mat field

% region of truncation
% r = 19;     % Ackley
% r = 7;       % Rastrigin
r = 1;       % Schaffer
% r = 2;       % Griewank

% modes file name
name = 'sch_modes.mat';
%---------------------------------------------------

%recover field variables
m = size(field,1);
n = size(field,2);
snaps = size(field,3);

%% 1st step: Pre-processing
Y = pre_proc(field, m, n);

%% 2nd step: Compute DMD
%time step
dt = 0.001;
[phi, lambda, Y_r, S1] = dmd(Y, dt, r);

%% 3rd step: Post-processing
Phi = post_proc(phi, m, n);

%% Save the results
save(name, "r", "Phi", "lambda");  