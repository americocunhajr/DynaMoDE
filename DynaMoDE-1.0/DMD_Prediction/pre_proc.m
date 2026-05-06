%Author: Lucas Simon Araújo
% Last modified: 06/03/2024

% Pre-processing
% Ackley test function, Rastrigin test function
% Input: 
%            field -> dynamic field stack of snapshots
%           m, n -> dimensions of the matrix
% Output:
%           Y -> augmented matrix containing each time step in one column

%How it works?
%rearranging y matrix into a single vector of collumns attached
%y=[|,|,|,...,|]   ->  col=[|;|;|;...;|]
%attach each time step collumn besides the previous one
%col=[|;|;|;...;|]  ->  Y=[col1, col2, col3,...]

function Y = pre_proc(field, m, n)
    %recover number of snaps
    snaps = size(field,3);
    
    % Initializing the DMD data matrix
    Y=[];
    for t = 1: snaps
        %transform each snapshot matrix (mxn) into a single vector(m.nx1)
        col = reshape(field(:,:,t),[m*n,1]);
        %attach all resulted snapshot vectors side by side
        Y = [Y, col];
    end
end