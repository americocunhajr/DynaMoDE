% Author: Lucas Simon Araújo
% Based on: https://www.sfu.ca/~ssurjano/optimization.html
% Last modified: 12/04/2024

% Generate the static fields for the optimization benchmark 
% Ackley, Rastrigin, Schaffer, Griewank test functions
% Input: 
%            *'opt' -> optimization function ('ackley', 'rastrigin', 'schaffer', 'griewank')
%            *m -> number of points in x
%            *n -> number of points in y
% Output:
%           *field file with the points of the distribuition named:
%           'ack_stat_field.mat', 'ras_stat_field.mat',
%           'sch_stat_field.mat', 'grie_stat_field.mat'
clear; close all; clc;

opt = 'griewank';
m = 1000;
n = m;

%Generating static field
switch opt
    case 'ackley'
        x1 = linspace(-32.768, 32.768, m);
        x2 = linspace(-32.768, 32.768, n);
        field = ackley([x1;x2]);
        save ack_stat_field.mat field x1 x2
    case 'rastrigin'
        x1 = linspace(-5.12, 5.12, m); 
        x2 = linspace(-5.12,5.12,n);  
        field = rastrigin([x1;x2]);
        save ras_stat_field.mat field x1 x2
    case 'schaffer'
        x1 = linspace(-50, 50, m); 
        x2 = linspace(-50, 50,n);  
        field = schaffer([x1;x2]);
        save sch_stat_field.mat field x1 x2
    case 'griewank'
        x1 = linspace(-600, 600, m); 
        x2 = linspace(-600, 600,n);  
        field = griewank([x1;x2]);
        save grie_stat_field.mat field x1 x2
end

