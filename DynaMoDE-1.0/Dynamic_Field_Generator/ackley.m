%Ackley function
%Author: Lucas Simon Araújo
% Based on: https://www.sfu.ca/~ssurjano/rastr.html
% Last modified: 15/02/2024

% f(x) = -a exp(-b sqrt(1/d sum_1^d(xi^2) - exp(1/d sum_1^d(cos(c xi)))+a+e
%Input: x = [[x_1]; ...;[x_d]] , where each x_i is a vector
%Output: f

function [f,sum1,sum2] = ackley(x)    
    %parameters
    a = 20;
    b = 0.2;
    c = pi/2;

    d = size(x,1);
    %initiallize sums
    sum1 = 0;
    sum2 = 0;
    % 1st term
    for k = 1:d
        % rotate ortogonally the vector at each loop to generate a grid
        if mod(k,2) == 1 %odd
            xi = x(k,:);
        else
            xi = transpose(x(k,:));
        end
	    %1st sum
        sum1 = sum1 + xi.^2;
        %2nd sum
        sum2 = sum2 + cos(c*xi);
    end
    f = -a*exp(-b*sqrt(sum1/d)) - exp(sum2/d);
    %2nd term
    f = f + a + exp(1);
    % x1 = x(1,:);
    % x2 = transpose(x(2,:));
    % f = 10*d + (x1.^2 - 10*cos(2*pi*x1)) + (x2.^2 - 10*cos(2*pi*x2));
end
