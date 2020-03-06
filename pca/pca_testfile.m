clear all
close all

%This testfile is based on the tutorial by john schlens, 2003.

numdata=500; %should be even

%Generate a dataset with a big change in it that is what we are trying to
%characterize
x1=rand(numdata/2,1);
y1=rand(numdata/2,1);
x2=3*rand(numdata/2,1)+3;
y2=3*rand(numdata/2,1)+3;

x=[x1;x2];
y=[y1;y2];


figure(1),subplot(3,1,1);
plot(x,y, 'o');
title('Original Data');

%Find and remove mean (this could be done with a moving window)
xmean=mean(x);
ymean=mean(y);
xnew=x-xmean*ones(numdata,1);
ynew=y-ymean*ones(numdata,1);

figure(1),subplot(3,1,2);
plot(xnew,ynew, 'o');
title('De-meaned Data');

%Find covariance matrix
data=[xnew ynew]; %data m X n where m = 2 dimensions (x,y) and n = numdata trials
covariancematrix=cov(data);  %uses 1/N-1 normalization; covariance = (1/N-1)*data*data'

%Find eigenvectors and eigenvalues of covariance matrix (rotate into new
%principal basis); find max eig value for classification

[eigvector,eigvalue] = eig(covariancematrix); %D is a diagonal matrix of eigenvalues; V is a matrix of eigenvectors
D=eigvalue; V = eigvector;
D=diag(D);  %diagonal part as a vector-- eigenvalues 
maxeigval=V(:,find(D==max(D))); %find the eigenvector (column) with biggest eigenvalue = Principal component; 
%If more than 2 dimensions, would next order the eigenvectors from big to
%small to define a feature vector in terms of the components that capture
%the variance best.  This is what the scripts at the bottom do.

figure(2),plot(V),hold on

plot(xnew,ynew,'o')
quiver(0,0,V(1,1),V(2,1),'r');
hold on;
quiver(0,0,V(1,2),V(2,2),'b');

% plot(V(:,1),'m')
% hold on
% plot(V(:,2),'y')

%Deriving the new data set: Find projection onto the eigenvectors

%finaldata=maxeigval'*[xnew,ynew]';
finaldata=maxeigval'*data';  %for numdata=10: [1 x 2 ]  X  [2 X 10] = [1 X 10] vector. Scaled to principal component
figure(3),subplot(3,1,2);
stem(finaldata);

%stem(finaldata, 'DisplayName', 'finaldata', 'YDataSource', 'finaldata');
title('PCA 1D output: Scaling data with one PC ')

%Classify data somehow
subplot(3,1,3);
title('Final Classification')
hold on
for i=1:size(finaldata,2)
    if  finaldata(i)>=0
        plot(x(i),y(i),'o')
        plot(x(i),y(i),'r*')
        
    else
        plot(x(i),y(i),'o')
        plot(x(i),y(i),'g*')
    end
    
end









%Compare with PCA calculated using Schlens' functions

break
%[signals,PC3,Variancesvd] = pca_SVD(data);
[signals2,PC4,Variancecov] = pca_cov(data);

figure(2),plot(signals)
