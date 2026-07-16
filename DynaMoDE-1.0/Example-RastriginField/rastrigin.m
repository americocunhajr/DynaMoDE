%Ratrigin function
%Author: Lucas Simon Araújo
% Based on: https://www.sfu.ca/~ssurjano/rastr.html
% Last modified: 15/02/2024

% f(x) = 10.d + sum_1^d(x_i^2 - 10.cos(2.pi.x_i))
%Input: x = [[x_1]; ...;[x_d]] , where each x_i is a vector
%Output: f

function f = rastrigin(x)    
    d = size(x,1);
    % 1st term
    f = 10*d;
    % 2nd term
    for k = 1:d
        % rotate ortogonally the vector at each loop to generate a grid
        if mod(k,2) == 1 %odd
            xi = x(k,:);
        else
            xi = transpose(x(k,:));
        end
	    f = f + (xi.^2 - 10*cos(2*pi*xi));
    end
    % x1 = x(1,:);
    % x2 = transpose(x(2,:));
    % f = 10*d + (x1.^2 - 10*cos(2*pi*x1)) + (x2.^2 - 10*cos(2*pi*x2));
end
