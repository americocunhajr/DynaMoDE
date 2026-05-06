% Author: Lucas Simon Araujo
% Last Modified: 13/04/2024

% Avaliation of the truncation influence into the similarity between
% original and DMD reconstruction
% Input:
%           *dynamic field
%           *truncation
% Output:
%           *similarity, truncation files
clear; close all; clc;
%----------------------------------------------
% User's entries
load ..\Dynamic_Field_Generator\grie_dyn_field.mat field

% name of the similarity file
name = "grie_sim_trunc.mat";

% range of truncation to verify similarity
% R = 1:25;   % ackley
% R = 1:12;       % rastrigin
% R = 1:5;         % schaffer
R = 1:5;         % griewank
%----------------------------------------------
% recovering dimensions
[m,n, snaps] = size(field);

% prealocating cossine
cos_theta = zeros(1,length(R));

% Pre-processing
Y = pre_proc(field, m, n);

% iterate through truncation to check similarity
for r = 1:length(R)
    % Compute DMD
    %time step
    dt = 0.001;
    [~, ~, Y_r, ~] = dmd(Y, dt, R(r));

    % stretched matrices
    v1 = reshape(Y(:,1:(snaps-1)),[],1);  % exclude last snapshot to match reconstructed field dimension
    v2 = reshape(Y_r,[],1);
    % similarity check
    cos_theta(r) = dot(v1,v2)/(norm(v1)*norm(v2));    
end

% saving the results
save(name,"R","cos_theta")