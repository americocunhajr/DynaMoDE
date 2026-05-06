%Author: Lucas Simon Araújo
% Last modified: 06/03/2024

% Post-processing
% Ackley test function, Rastrigin test function
% Input: 
%           Y_r -> augmented matrix containing each time step in one column
%           m, n -> dimensions of the matrix
% Output:
%            field_r -> dynamic field stack of snapshots

%How it works?
%dettach each time step collumn into a snapshot vector
%Y=[col1, col2, col3,...]  <-  col=[|;|;|;...;|]
%rearranging the vector as a snapshot matrix by splitting at each 'm' elements
%y=[|,|,|,...,|]   <-  col=[|;|;|;...;|]

function field_r = post_proc(Y_r, m ,n) 

    %initializing stack of snapshots matrices
    snaps_r = size(Y_r,2);  %1 less than the original due to shift
    field_r = zeros(m,n,snaps_r);
    
    %iterate through collumns 
    % 'k-ith' column = 'tstep'
    for k = 1:snaps_r
        %separate each column   
        col = Y_r(:,k); 
        %convert the column into snapshot    
        field_r(:,:,k) = reshape(col,m,n);
    end

end