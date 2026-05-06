function [Phi, lambda, Xdmd,S1] = dmd(Y,dt,r)

    %% 1st step: Rearranging data
    % spliting data matrix into a portrait and a time step shifted one
    X1 = Y(:,1:end-1);
    X2 = Y(:,2:end);

    %% 2nd step: Decomposing data via SVD
    [U,S1,V] = svd(X1,'econ');    % using economic algorithm
    
    %%  3rd step: Truncating only main modes (memory and processing economy)

    %r = 5;  % in this 18 modes are suficient
    U = U(:,1:r);
    S = S1(1:r,1:r);
    V = V(:,1:r);

    %% 4th step: Projecting A matrix into orthogonal decomposition
    Atilde = U'*X2*V/S;  %using truncated matrices

    %% 5th step: Compute the eigendecomposition of the projection
    [W,eigs] = eig(Atilde); % 'W' are the eigenvectors and 'eigs' are the eigenvalues
    
    %% 6th step: Return the eigenresults from the projection of A to the original A
    %eigenvectors, modes
    Phi = X2*V/S*W;
    %eigenvalues, frequencies (remais the same as the projection)
    lambda = diag(eigs); % discrete-time eigenvalues
    omega = log(lambda)/dt; % continuous-time eigenvalues

    %% 7th step: Solve the IVP to finally reconstruct X
    % xdot = A.x -> x = b.Phi.e^(W.t) -> x(0) = b.Phi
    x0 = X1(:,1); % initial condition
    b = Phi\x0; % computing 'b' vector 
    snaps = size(X1,2);  %number of collums (snapshots)
    t = (0:snaps-1)*dt;  %time vector
    % computing the time dependent part of solution (b.e^(W.t))
    time_part = zeros(r,snaps); %prealocating matrix memory
    %runnning collumn by collumn (time steps)
    for n = 1:snaps
        time_part(:,n) = b.*exp(omega*t(n));
    end   
    % finally computinng reconstruction (x = b.Phi.e^(W.t))
    Xdmd = Phi*time_part;

end