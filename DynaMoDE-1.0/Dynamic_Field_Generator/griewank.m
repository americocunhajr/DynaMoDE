%Griewank function
%Author: Lucas Simon Araújo
% Based on: https://www.sfu.ca/~ssurjano/griewank.html
% Last modified: 07/03/2024

% f(x) = sum_i=1^2 xi^2/4000 - prod_i=1^d cos(xi/sqrt(i)) +1
%Input: x = [[x_1]; [x_2]] , where each x_i is a vector
%Output: f

% function f = griewank(x)    
%     %dimensions
%     %d = size(x,1);
%     x1 = x(1,:);
%     x2 = x(2,:);
%     [X1,X2] = meshgrid(x1,x2);
%     f = (X1.^2 + X2.^2)/4000 - (cos(X1/sqrt(1)).*cos(X2/sqrt(2))) + 1;
% end

function f = griewank(x)    
    %dimensions
    d = size(x,1);
    %initiallize sum and prod with their neutral elements
    sum = 0;
    prod = 1;
    % 1st term
    for k = 1:d
        % rotate ortogonally the vector at each loop to generate a grid
        if mod(k,2) == 1 %odd
            xi = x(k,:);
        else
            xi = transpose(x(k,:));
        end
	    % sum
        sum = sum + xi.^2/4000;
        %prod 
        prod = prod.* cos(xi/sqrt(k));
    end
    f = sum - prod +1;
end

