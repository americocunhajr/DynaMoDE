%Author: Lucas Simon Araújo
% Last modified: 12/04/2024

% Generate the dynamic fields for the optimization benchmark 
% Ackley, Rastrigin, Schaffer, Griewank test functions
% Input: 
%            *'opt' -> optimization function ('ackley', 'rastrigin','schaffer','griewank')
%            *m -> number of points in x
%            *n -> number of points in y
%           *time -> time vector
% Output:
%           *field file with the points of the distribuition named (3D matrix):
%           'ack_dyn_field.mat',   'ras_dyn_field', 'sch_dyn_field', 'grie_dyn_field'

clear; close all; clc;

opt = 'griewank';
m = 1000;
n = m;
snaps = 100+1;  %always use +1 to match reconstruction size
time = linspace(0.1, pi/4-0.1, snaps); 

%% Generating dynamic field
%prealocating memory
field = zeros(m,n,snaps);

switch opt
    case 'ackley'
        for t = 1:snaps
            x1 = linspace(-32.768, 32.768, m);
            x1_t = x1*sin(time(t));
            x2 = linspace(-32.768, 32.768, n);
            x2_t = x2*sin(time(t));
            field(:,:,t) = ackley([x1_t;x2_t]); 
        end
        save ack_dyn_field.mat field x1 x2

    case 'rastrigin'
        for t = 1:snaps
            x1 = linspace(-5.12, 5.12, m); 
            x1_t = x1*sin(time(t));
            x2 = linspace(-5.12,5.12,n);
            x2_t = x2*sin(time(t));
            field(:,:,t) = rastrigin([x1_t;x2_t]);
        end
        save ras_dyn_field.mat field x1 x2

    case 'schaffer'
        for t = 1:snaps
            x1 = linspace(-50, 50, m);  
            x1_t = x1*sin(time(t));
            x2 = linspace(-50, 50,n); 
            x2_t = x2*sin(time(t));
            field(:,:,t) = schaffer([x1_t;x2_t]);
        end
        save sch_dyn_field.mat field x1 x2

    case 'griewank'
        for t = 1:snaps
            x1 = linspace(-600, 600, m);   
            x1_t = x1*sin(time(t));
            x2 = linspace(-600, 600,n);
            x2_t = x2*sin(time(t));
            field(:,:,t) = griewank([x1_t;x2_t]);
        end
        save grie_dyn_field.mat field x1 x2
end
