% by Jonathon Shlens (Salk Institute for Biological Sciences)

%This second version follows Section 6 computing PCA through SVD.
function [signals,PC,Variance] = pca_SVD(data)
% PCA2: Perform PCA using SVD.
% data - MxN matrix of input data
% (M dimensions, N trials)
% signals - MxN matrix of projected data
% PC - each column is a PC
% V - Mx1 matrix of variances
[M,N] = size(data);
% subtract off the mean for each dimension
mn = mean(data,2); %gives column vector of means for each row
data = data - repmat(mn,1,N);
% construct the matrix Y
Y = data' / sqrt(N-1);
% SVD does it all
[u,S,PC] = svd(Y);
% calculate the variances
S = diag(S);
V = S .* S;
Variance=V;
% project the original data
signals = PC' * data;
