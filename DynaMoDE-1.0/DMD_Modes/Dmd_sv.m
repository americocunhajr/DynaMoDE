% Author: Lucas Simon Araújo
% Last modified: 13/04/2024
%----------------------------------------------------------
% Plot singular values from the dynamic field
% Input: 
%            dynamic field data
% Output:
%           singular values plot with truncation indication
%           file with the SVD components 
%----------------------------------------------------------

clear; close all; clc;
%----------------------------------------------------------
% User's entries
% load data
load ..\Dynamic_Field_Generator\grie_dyn_field.mat field

% SVD file name
name = "grie_svd";
%----------------------------------------------------------
% Recovering field dimensions
m = size(field,1);
n = size(field,2);
% Preprocessing
Y = pre_proc(field, m, n);

%separate data matrix
X1 = Y(:,1:end-1);
X2 = Y(:,2:end);
%compute SVD
[U,S1,V] = svd(X1,'econ');

%save data
save(name, "U", "S1", "V")