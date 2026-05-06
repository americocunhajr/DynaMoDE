% Author: Lucas Simon Araújo
% Last modified: 13/04/2024

% Generate the DMD prediction of the dynamic fields  
% Ackley, Rastrigin, Schaffer, Griewank test functions
% Input: 
%       dynamic fields
% Output:
%      reconstructed dynamic fields
clear; close all; clc;
%---------------------------------------------------
% User's entries
% load data
load ..\Dynamic_Field_Generator\grie_dyn_field.mat field

% region of truncation
% r = 19;     % Ackley
% r = 7;       % Rastrigin
% r = 1;       % Schaffer
r = 2;       % Griewank

% reconstruction file name
name = 'grie_pred_field.mat';
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
[Phi, lambda, Y_p, S1] = dmd_pred(Y, dt, r);

%% 3rd step: Post-processing
field_p = post_proc(Y_p, m, n);
Phi_p = post_proc(Phi, m, n);

%% Save the results
save(name, "r", "Phi_p", "lambda", "S1", "field_p","-v7.3");    %"-v7.3" is used for store big data