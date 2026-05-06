%Griewank function
%Author: Lucas Simon Araújo
% Based on: https://www.sfu.ca/~ssurjano/schaffer2.html
% Last modified: 07/03/2024

% f(x) = 0.5 + (sin^2(x1^2 - x2^2) - 0.5)/(1 + 0.001(x1^2 + x2^2))^2
%Input: x = [[x_1]; [x_2]] ,
%Output: f

function f = schaffer(x)    
    x1 = x(1,:);
    x2 = x(2,:);
    [X1,X2] = meshgrid(x1,x2);
    num = (sin(X1.^2 - X2.^2)).^2 - 0.5;
    den = (1 + 0.001*(X1.^2 + X2.^2))^2;
    f = 0.5 + num./den;
end
