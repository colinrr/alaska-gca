function [Z,my_clusters]=cluster_pca_space(score,time,number_of_clusters,number_of_components,savepath,savefilename,save_y_n)
%GET hierarchical clustering from PCA
%   input: PCA score, time vector, desired number of clusters, 
%   number of components to be used, string
%   for path to save figure, string for saving filename, string 'y' or 'n'
%   for saving of figures
%   output: dendrogram Z and cluster membership my_clusters

% NOTE: tested both fuzzy c-means and hierarchical, but especially for
% large datasets (Hawaii) hierarchical seems to work better

% Kathi Unglert, Oct 2015

% normalize data - non-normalized generally better
% norm_score = score(:,1:3)/std(score(:,1:3),1);
norm_score = score(:,1:number_of_components);


%% hierarchical clustering


% get cluster structure
Z = linkage(norm_score,'ward','euclidean');

% Dendrogram fig
% figure
% dendrogram(Z);
% if save_y_n == 'y'
%     saveas(gcf,strcat(savepath,savefilename,'dendrogram.fig'),'fig')
% end

% get clusters for given number of clusters
my_clusters = cluster(Z,'maxclust',number_of_clusters);

% cm = colormap(jet(number_of_clusters));

% % PC space fig
% figure
% scatter3(score(:,1),score(:,2),score(:,3),6,my_clusters,'filled')
% colormap(jet)
% xlabel('component 1')
% ylabel('component 2')
% zlabel('component 3')
% colorbar
% axis equal
if save_y_n == 'y'
    saveas(gcf,strcat(savepath,savefilename,'clusters.fig'),'fig')
end

% Clusters with time fig
% figure,
% hold on
% for ii = 1:length(time)
% plot(time(ii),my_clusters(ii),'o','Color',cm(my_clusters(ii),:))
% end
% xlabel('time')
% datetick('x')
% set(gca,'yticklabel',[1:number_of_clusters],'ytick',[1:number_of_clusters])
% grid on
if save_y_n == 'y'
    saveas(gcf,strcat(savepath,savefilename,'clusters_temporal_evolution.fig'),'fig')
end



% %% fuzzy c-means clustering
% 
% [centers,likelihood_matrix] = fcm(norm_score,number_of_clusters);
% % each row of centers is one cluster, each column a dimension
% 
% [max_likelihood_value,max_likelihood_index] = max(likelihood_matrix,[],1);
% 
% figure
% scatter3(score(:,1),score(:,2),score(:,3),20,max_likelihood_index,'filled')
% xlabel('component 1')
% ylabel('component 2')
% zlabel('component 3')
% colorbar
% saveas(gcf,strcat(savepath,'clusters_pcaspace_',savefilename,'.fig'),'fig')
% 
% 
% mylegend = [];
% 
% figure,
% hold on
% for ii = 1:number_of_clusters
%     mylegend = [mylegend {strcat('cluster ',num2str(ii))}];
%     plot(time,likelihood_matrix(ii,:).*100,'o')
% end
% legend(mylegend)
% ylabel('probability of cluster membership')
% xlabel('time')
% datetick('x')
% saveas(gcf,strcat(savepath,'clusters_temporal_evolution_',savefilename,'.fig'),'fig')

