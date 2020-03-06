function pcdat = singleWavPca(w,fbands,pca_mode,pcview)
% pcdat = singleWavPca(w,fbands,pca_mode,pcview)
% w = input waveform
% fband = freq band of interest. (Can leave empty)
% pca_mode = 'raw','norm','shiftnorm'
% pcview   = vector of which pcs to plot - only supports 1-3 for now

fprintf('\nPCA analysis on individual traces...\n')

if nargin==1
    fbands = [];
end
if nargin<3
    pca_mode = 'raw';
end
if nargin<4
    pcview = [];
end

Nw = numel(w);
nrows = 2 + length(fbands);

% Output struct: [Nw rows by Nfbands cols]
pcdat(Nw,length(fbands)) = struct('station',[],'pxx',[],'fmt',[],'tmt',[],...
                    'fband',[],'PCs',[],'eVecs',[],'eVals',[],'tsq',[],...
                    'pcnt_var',[],'mu',[],'Nclusters',[],'my_clusters',[],...
                    'centers',[],'reconstructed_spec',[],'p90',[],'p75',[],...
                    'maxpc',[]); %length(fbands),1);

% figure('position',[100 100 Nw*250+100 600])
% pcax = []; % zeros([]);

%% Set Pxx type
if strcmp(pca_mode,'raw')
    fprintf('PCA: using Raw spectra\n')
    tstr = 'Raw spectrogram';
elseif strcmp(pca_mode,'norm')
    disp('PCA: using Normalized spectra')
    tstr = 'Normalized spectrogram';
elseif strcmp(pca_mode,'normshift')
    disp('PCA: using Normalized and Median Shifted spectra')
    tstr = 'Normalized and Median shifted spectrogram';
else
    disp('Bad PCA mode')
    flargh
end

for k = 1:Nw
    %% Run PCA
    pxx = get(w(k),'pxxmt');
    fmt = get(w(k),'fmt');
    tmt = get(w(k),'tmt');
    pn = size(pxx,1);

    %% Set Pxx type
if strcmp(pca_mode,'norm')
    pxxSum = sum(abs(pxx),1); 
    pxx   = pxx./repmat(pxxSum,[pn,1]);
elseif strcmp(pca_mode,'normshift')
    pxxSum = sum(abs(pxx),1); 
    pxx   = pxx./repmat(pxxSum,[pn,1]);
    pxx  = pxx - repmat(median(pxx,1),[pn,1]);
%         pxx  = pxdbN - repmat(median(pxdbN,1),[pn,1]);        
end

    fprintf('Station: %s\n',get(w(k),'station'))
    for j = 1:length(fbands)
        fband = fbands{j};
        % Cut out freq band
        if isempty(fband)
            fi = true(size(fmt));
            fband = [min(fmt) max(fmt)];
        else
            fi = logical((fmt>=fband(1)) .* (fmt<=fband(2)));
        end
        fmt1 = fmt(fi);
        pxx1 = pxx(fi,:);

        [eVecs, PCs, eVals, tsq, pcnt_var, mu] = pca(pxx1');
        p90 = min(find(cumsum(pcnt_var)>=90));
        p75 = min(find(cumsum(pcnt_var)>=75));

        pcdat(k,j) = struct('station',get(w(k),'station'),'pxx',pxx1',...
                    'fmt',fmt1,'tmt',tmt,'fband',fband,'PCs',PCs,'eVecs',eVecs,...
                    'eVals',eVals,'tsq',tsq,'pcnt_var',pcnt_var,'mu',mu,'Nclusters',[],...
                    'my_clusters',[],'centers',[],'reconstructed_spec',[],...
                    'p90',p90,'p75',p75,'maxpc',[]);

        %% Run Kathi's clustering and reconstruction
%         disp('Doing Kathi''s thing...')

        pcdat(k,j).Nclusters = 1; % For now
        dummy_time = linspace(1,size(PCs,1),size(PCs,1));
        [Z,pcdat(k,j).my_clusters] = cluster_pca_space(PCs,dummy_time,...
                    pcdat(k,j).Nclusters,3,'','','n');
        
        pcdat(k,j).maxpc = pcdat(k,j).p75; %10;
        % my_clusters,number_of_clusters,score,coeff,pca_mu,frequency,...
        % maxpc,time_vector,original_data,dates,savepath,savefilename,save_y_n
        [pcdat(k,j).centers,pcdat(k,j).reconstructed_spec]...
            = get_cluster_centers_and_reconstruct(pcdat(k,j).my_clusters,...
            pcdat(k,j).Nclusters,pcdat(k,j).PCs,pcdat(k,j).eVecs,pcdat(k,j).mu,...
            pcdat(k,j).fmt,pcdat(k,j).maxpc,dummy_time,pcdat(k,j).pxx,0,'','','n');

    end
end

if ~isempty(pcview)
    singlePcaPlot(w,pcdat,pcview)
end
end

function singlePcaPlot(w,pcd,pcview)
% singlePcaPlot(w,pcdat,pcview)
% pcdat = [m channels x n freq bands] structure of PCA info
Nb = size(pcd,2);
Nw = size(pcd,1);

nrows = 3;
for j = 1:Nb
    
    f1 = figure('position',[100 100 Nw*100+100 600]);
    f2 = figure;
    myleg = cell([Nw 1]);
    for k = 1:Nw
        %% Initial plot of spectrogram
        figure(f1)
        tightSubplot(nrows,Nw,k,0);
        imagesc(pcd(k,j).tmt,pcd(k,j).fmt,pcd(k,j).pxx'); set(gca,'YDir','Normal')
        colormap('hot')
        datetick('x','HH:MM','keeplimits')
    %     xlabel('Time')
        if k==1; ylabel('Freq'); else; set(gca,'YTickLabel',[]); end
        title(string(get(w(k),'station')))
    %         caxis(caxis*1.05)
    %         caxis(caxis*1.1)

        %% Plot percent variance
        tightSubplot(nrows,Nw,k+Nw,0);
%         lbls = cell(length(fbands),1);
%         for j = 1:length(fbands)
        plot(pcd(k,j).pcnt_var,'.-')
        hold on
%         lbls{j} = sprintf('%.1f - %.1f Hz, p90=%i',pcd(j).fband(1),pcd(j).fband(2),p90);
%         end
    %     xlabel('mode')
        if k==1; ylabel('% Variance'); else; set(gca,'YTickLabel',[]); end
        title(sprintf('p90 = %i, p70 = %i',pcd(k,j).p90,pcd(k,j).p75))
        xlim([0 20])
        ylim([0 100])
%         legend(lbls)

  
    
    %% Plot PC space   
    % PC space fig
% figure
% scatter3(score(:,1),score(:,2),score(:,3),6,my_clusters,'filled')
% colormap(jet)
% xlabel('component 1')
% ylabel('component 2')
% zlabel('component 3')
% colorbar
% axis equal
        ax = tightSubplot(nrows,Nw,k+(2)*Nw);
    %     pcax = [pcax ax];
        pcs = pcd(k,j).PCs;
        if numel(pcview)==1
            plot(pcs(:,pcview))
        elseif numel(pcview)==2
            scatter(pcs(:,pcview(1)),pcs(:,pcview(2)),8,pcd(k,j).my_clusters,'filled','Marker','o')
            xlabel('PC 1')
            ylabel('PC 2')
        elseif numel(pcview)==3
            scatter3(pcs(:,pcview(1)),pcs(:,pcview(2)),pcs(:,pcview(3)),8,pcd(k,j).my_clusters,'filled','Marker','o')
            xlabel('PC 1')
            ylabel('PC 2')
            zlabel('PC 3')
        end
        title(sprintf('%.1f - %.1f Hz',pcd(k,j).fband(1),pcd(k,j).fband(2)))
        axis equal tight
        xlim([-1 1]*max(abs(xlim)))
        ylim([-1 1]*max(abs(ylim)))
        
        figure(f2)
        hold on
        myleg{k} = sprintf('%s, %i PCs',pcd(k,j).station,pcd(k,j).maxpc);
        plot(pcd(k,j).fmt,pcd(k,j).reconstructed_spec)
    end
    %     linkaxes(pcax,'xy')
        nom1 = sprintf('%i - %i',pcd(k,j).fband(1),pcd(k,j).fband(2));
        set(f1,'name',nom1)
        
        figure(f2)
        xlabel('Frequency (Hz)')
        ylabel('Reconstructed Amplitude (dB)')
        grid on
        legend(myleg)
        set(f2,'name',nom1)
        
        
end
end