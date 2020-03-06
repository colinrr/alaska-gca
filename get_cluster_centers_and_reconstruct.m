function [centers,reconstructed_spectrum] = get_cluster_centers_and_reconstruct(my_clusters,number_of_clusters,score,coeff,pca_mu,frequency,maxpc,time_vector,original_data,dates,savepath,savefilename,save_y_n)
% [centers,reconstructed_spectrum,projected_spectra] = get_cluster_centers_and_reconstruct(my_clusters,number_of_clusters,score,coeff,pca_mu,frequency,maxpc,time_vector,original_data,dates,savepath,savefilename,save_y_n)
%GET cluster centers for hierarchical clusters and reconstruct spectra
%   input: cluster membership my_clusters, score and coeff from PCA,
%   frequency vector for spectrum, maximum number of principal components
%   to be used, time vector, original_data, dates for plotting, 
%   string save_y_n 'y' or 'n' for saving of figures
%   output: figure with reconstructed spectra, variables centers and
%   reconstructed_spectrum, projections of observations onto reconstr.
%   spectra

% Kathi Unglert, Oct 2015

%% get cluster centers

centers = zeros(number_of_clusters,maxpc);

for cluster = 1:number_of_clusters
    centers(cluster,:) = median(score(my_clusters == cluster,1:maxpc),1);
end

%% reconstruct spectra based on cluster centers

for cluster_index = 1:number_of_clusters
    summed_spectrum = zeros(size(frequency));
    for pc_index = 1:maxpc
        temp_spectrum = coeff(:,pc_index).*centers(cluster_index,pc_index);
        summed_spectrum = summed_spectrum + temp_spectrum;
    end
    reconstructed_spectrum(:,cluster_index) = summed_spectrum + pca_mu';
end

% mylegend = [];
% cm = colormap(jet(number_of_clusters));
% figure
% hold on
% for ii =1:number_of_clusters
%     mylegend = [mylegend {strcat('cluster ',num2str(ii))}];
%     plot(frequency,reconstructed_spectrum(:,ii),'Color',cm(ii,:))
% end
% xlabel('frequency (Hz)')
% grid on
% legend(mylegend)
if save_y_n == 'y'
    saveas(gcf,strcat(savepath,savefilename,'reconstructed_spectra.fig'),'fig')
end

%% get projection of observations onto reconstructed spectra


% [projected_spectra] = project_best_spectra(reconstructed_spectrum,my_clusters,...
%     original_data,time_vector,dates,savepath,savefilename,save_y_n);