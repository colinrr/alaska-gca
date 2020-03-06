function pcdat = WavPca(w,fbands,pca_mode,pcview)
% INPUT:    pcdat   = WavPca(w,fbands,pca_mode,pcview)
%           w       = input waveform
%           fband   = cell, freq bands of interest. (Can leave empty)
%           pca_mode = 'raw','norm','shiftnorm'
%           pcview  = vector of which pcs to plot - only supports up to 3 for now
%
% OUTPUT: pcdat     = struct containing process wavs, PCA data, and meta data
%
% Requires that all waveforms have spectrograms over identical frequencies
%
% Colin Rowell, July 2017
 

if nargin==1
    fbands = {[]};
end
if nargin<3
    pca_mode = 'raw';
end
if nargin<4
    pcview = [];
end

Nw = numel(w);
nb = length(fbands);
nrows = 1 + nb;


pcs = struct(); % Politically correct structure

% Initialize combined spectral estimates
PXX = get(w,'pxxmt');
pnSingle = zeros(size(PXX)); % Initialize pxx counting array (preserved lengths of each pxx in w)
for k = 1:numel(pnSingle); pnSingle(k) = size(PXX{k},2);end
pnSingle = cumsum(pnSingle);
pxx = cat(2,PXX{:});
pn = size(pxx,1);

% Set up pxx type
if strcmp(pca_mode,'raw')
    disp('PCA: using Raw spectra')
    tstr = 'Raw spectrogram';
elseif strcmp(pca_mode,'st_dmed')
    disp('PCA: Spectra de-medianed by station')
    tstr = 'Spectrogram: station de-median';
    pn1 = [1; pnSingle(1:end-1)+1];
    for l = 1:numel(pnSingle)
        pxst = pxx(:,pn1(l):pnSingle(l));
        pxx(:,pn1(l):pnSingle(l)) = pxst - median(pxst(:));
    end
elseif strcmp(pca_mode,'st_dmednorm')
    disp('PCA: Spectra normalized and de-medianed by station')
    tstr = 'Spectrogram: station normalized and de-medianed';
    pn1 = [1; pnSingle(1:end-1)+1];
    for l = 1:numel(pnSingle)
        pxst = pxx(:,pn1(l):pnSingle(l)); % Spectrogram for this station
        pxx(:,pn1(l):pnSingle(l)) = (pxst - median(pxst(:)))/sum(abs(median(pxst,2)));
    end
elseif strcmp(pca_mode,'norm')
    disp('PCA: using Normalized spectra')
    tstr = 'Normalized spectrogram';
    pxxSum = sum(abs(pxx),1); 
    pxx   = pxx./repmat(pxxSum,[pn,1]);
elseif strcmp(pca_mode,'normshift')
    disp('PCA: using Normalized and Median Shifted spectra')
    tstr = 'Normalized and Median shifted spectrogram';
    pxxSum = sum(abs(pxx),1); 
    pxx   = pxx./repmat(pxxSum,[pn,1]);
    pxx  = pxx - repmat(median(pxx,1),[pn,1]);
%         pxx  = pxdbN - repmat(median(pxdbN,1),[pn,1]);
else
    error('Bad PCA mode')
end

fmt = get(w(1),'fmt');

pcdat(length(fbands)) = struct('pxx',[],'fmt',[],'fband',[],'PCs',[],'eVecs',[],...
                    'eVals',[],'tsq',[],'pcnt_var',[],'mu',[]); %length(fbands),1);

    
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

    % eVecs    = coeff     = PC weights...?
    % PCs      = score     = Representation of pxx in PC space
    % eVals    = latent    = PC variances (eigenvals of covariance matrix)
    % tsq      = tsquared  = Hotelling's T-squared statistic, not used (or understood) at present...
    % pcnt_var = explained = percentage of total variance explained by each PC
    % mu       = mu        = estimated mean when "CENTERED" set to true, 0's otherwise
    [eVecs, PCs, eVals, tsq, pcnt_var, mu] = pca(pxx1');
    pcdat(j) = struct('pxx',pxx1','fmt',fmt1,'fband',fband,'PCs',PCs,'eVecs',eVecs,...
                    'eVals',eVals,'tsq',tsq,'pcnt_var',pcnt_var,'mu',mu);


pcdat(j).pxxi = pnSingle;
pcdat(j).Nw   = Nw;

% Run Kathi's clustering
disp('Doing Kathi''s thing...')

pcdat(j).Nclusters = Nw; % For now
dummy_time = linspace(1,size(PCs,1),size(PCs,1));
[Z,pcdat(j).my_clusters] = cluster_pca_space(PCs,dummy_time,...
                    pcdat(j).Nclusters,3,'','','n');

[pcdat(j).centers,pcdat(j).reconstructed_spec]...
    = get_cluster_centers_and_reconstruct(pcdat(j).my_clusters,...
    pcdat(j).Nclusters,pcdat(j).PCs,pcdat(j).eVecs,pcdat(j).mu,...
    pcdat(j).fmt,3,dummy_time,pcdat(j).pxx,0,'','','n');

end
if ~isempty(pcview)
    pcaPlot(w,pcdat,pcview)
end
end
% nom = sprintf('%i - %i, %s',fband(1),fband(2),tstr);
% set(gcf,'name',nom)

function pcaPlot(w,pcdat,pcview)
    % Input waveform and pca structure to output plots, pcview selects
    % which PC's to plot
    Nw = numel(w);     % Number of stations/waveforms
    nb = numel(pcdat); % Number of freq bands
    
    npc = 8; % For now
    xsz = [];
    ysz = [4 3];
    plot_dy = 0.05;  
    st = get(w,'Station');
    ch = get(w,'Channel');
    set(0,'DefaultAxesColorOrder',colors(npc))
    for j = 1:nb
        
        f1 = figure('position',[100 100 1300 900]);
        nom = sprintf('%i - %i Hz',pcdat(j).fband(1),pcdat(j).fband(1));
        set(f1,'name',nom)
    

        
        % Plot Eigenvectors
        tightSubplot(2,2,1,[0.05],plot_dy,[],xsz,ysz);
        % calculate a spacing - can try a couple here
        eVecs = pcdat(j).eVecs(:,1:npc);
        dy = [1:npc].*mean(max(eVecs,[],1)-min(eVecs,[],1));
        % plot spaced out eigenvecs
        plot(repmat([1;pcdat.fmt(end)],[1,npc]),[dy;dy],':k')
%         plot(repmat([1;size(eVecs,1)],[1,npc]),[dy;dy],':k')
        hold on
        plot(pcdat.fmt,eVecs+repmat(dy,[size(eVecs,1),1]))
%         plot(eVecs+repmat(dy,[size(eVecs,1),1]))
        set(gca,'YTick',dy,'YTickLabel',[1:npc])
        title('Eigenvectors (frequency weights)')
        xlim([1 pcdat.fmt(end)])
        ylim([dy(1)*0.5 dy(end)+dy(1)*0.5])
        xlabel('Hz')
        
        % Plot PC's
        tightSubplot(2,2,2,[0.05],plot_dy,[],xsz,ysz);
        % calculate a spacing - can try a couple here
        PCs = pcdat(j).PCs(:,1:npc);
        dy = [1:npc].*mean(max(PCs,[],1)-min(PCs,[],1));
        % plot spaced out eigenvecs
%         set(gca,'ColorOrder',colors(npc))
        plot(repmat([1;size(PCs,1)],[1,npc]),[dy;dy],'--','color',[0.7 0.7 0.7])
        hold on
        plot((pcdat(j).pxxi*[1 1])', repmat([0;dy(end)+diff(dy(1:2))],...
            [1, numel(pcdat(j).pxxi)]),':','color',[0.5 0.5 0.5])
        set(gca,'ColorOrder',colors(npc))
        plot(PCs+repmat(dy,[size(PCs,1),1]))
%         plot(PCs(:,1)+dy(1))
        set(gca,'YTick',dy,'YTickLabel',[1:npc])
        xlabel('Input sample')
        title('Principal Components')
        axis tight

        % Plot percent variance
        tightSubplot(2,2,3,[],[],[],[1 2],ysz);
        lbls = cell(nb,1);
%         for j = 1:nb
        p90 = find(cumsum(pcdat(j).pcnt_var)>=90, 1 );
        plot(pcdat(j).pcnt_var,'.-')
        hold on
        lbls{j} = sprintf('%.1f - %.1f Hz, p90=%i',pcdat(j).fband(1),pcdat(j).fband(2),p90);
%         end
        xlabel('mode')
        ylabel('% variance')
        title(sprintf('p90 = %i, nPC = %i',p90,numel(pcdat(j).pcnt_var)))
        xlim([0 20])
        ylim([0 100])
        legend(lbls)
        
        % Plot median spectra for each station
        tightSubplot(2,2,4,[],[],[],[1 2],ysz);
        pxxi = pcdat(j).pxxi;
        median_specs = zeros(size(pcdat(j).fmt,1),Nw);
        old_i = 1;
        for k = 1:numel(pxxi)
            median_specs(:,k) = median(pcdat(j).pxx(old_i:pxxi(k),:),1)';
            old_i = pxxi(k)+1;
        end
%         set(gca,'ColorOrder',colors(npc))
        plot(pcdat(j).fmt,median_specs,'LineWidth',1.5)
        title('Station median spectra')
        xlabel('Frequency (Hz)')
        legend(strcat(st(:),'.',ch(:)))
    end
    
    %% Plot modified and appended spectrograms
    f2 = figure('position', [100 100 800 400]);
    spax = tightSubplot(3,1,1,[],0,[],[1 2]);
    dummy_time = linspace(1,size(pcdat.pxx,1),size(pcdat.pxx,1));
    imagesc(dummy_time,pcdat.fmt,pcdat.pxx')
    set(gca,'YDir','normal')
    hold on
    colormap(spax,jet)
    for k = 1:numel(pcdat.pxxi)-1
        plot([1 1]*pcdat.pxxi(k)+0.5,ylim,'w')
    end
    station = get(w,'channeltag');
    text( pcdat.pxxi - round(diff([0; pcdat.pxxi])/2),...
        ones(size(pcdat.pxxi))*1.1*max(pcdat.fmt),...
        {station.station},'HorizontalAlignment','center')%,'units','normalized');
    
    for j = 1:length(pcdat)
        %% Plot PC space - should add coloring option
        pcax = []; % zeros([]);
    
        pcs = pcdat(j).PCs;
        f3 = figure('position',[100 100 750 500]);

        if numel(pcview)==1
            ax = tightSubplot(1,1,1);
            plot(pcs(:,pcview))
            ylabel(sprintf('PC %i',pcview))
        elseif numel(pcview)==2
            ax = tightSubplot(1,1,1,[],[],[],[],[1 3]);
            scatter(pcs(:,pcview(1)),pcs(:,pcview(2)),8,pcdat(j).my_clusters,'filled','Marker','o')
            hold on
            lims = [-1;1]* max(max(abs(pcs(:,pcview))));
            cross=plot([lims [0; 0]],[[0; 0] lims],'--','color',[0.7 0.7 0.7],'LineWidth',0.3);
            uistack(cross,'bottom')
            xlabel(sprintf('PC %i',pcview(1)))
            ylabel(sprintf('PC %i',pcview(2)))
            axis equal
        elseif numel(pcview)==3
            ax = tightSubplot(1,1,1,[],[],[],[],[1 3]);
            scatter3(pcs(:,pcview(1)),pcs(:,pcview(2)),pcs(:,pcview(3)),8,pcdat(j).my_clusters,'filled','Marker','o')
            xlabel(sprintf('PC %i',pcview(1)))
            ylabel(sprintf('PC %i',pcview(2)))
            zlabel(sprintf('PC %i',pcview(3)))
            axis equal
        end
        pcax = [pcax ax];
        colormap(jet)
        title(sprintf('%i channels, %.1f - %.1f Hz',Nw,pcdat(j).fband(1),pcdat(j).fband(2)))
        axis tight

        %% Plot clusters with time
        figure(f2)
%         dummy_time = linspace(1,size(pcdat.pxx',1),size(pcdat.pxx',1));
        cluster_time = tightSubplot(3,1,2,[],0,[],[1 2]);
        cm = colormap(cluster_time,jet(pcdat(j).Nclusters));
        cvec = cm(pcdat(j).my_clusters,:);
        scatter(dummy_time,pcdat(j).my_clusters,8,cvec,'Marker','o')
        grid on
        set(gca,'yticklabel',[1:pcdat(j).Nclusters],'ytick',[1:pcdat(j).Nclusters])
        
        xlabel('samples')
        axis tight
        linkaxes([spax cluster_time],'x')
        if numel(pcview)==2
        linkaxes(pcax,'xy')
        end
        
        %% Plot reconstructed spectra
        f4 = figure;
        mylegend = [];
        cm = colormap(f4,jet(pcdat(j).Nclusters));
        hold on
        nom = sprintf('%i - %i Hz',pcdat(j).fband(1),pcdat(j).fband(1));
        for ii = 1:pcdat(j).Nclusters
            mylegend = [mylegend {strcat('c- ',num2str(ii))}];
            plot(pcdat(j).fmt,pcdat(j).reconstructed_spec(:,ii),'Color',cm(ii,:),'LineWidth',1.5)
        end
        xlabel('frequency (Hz)')
        grid on
        legend(mylegend)
        set(f4,'name',nom)
        title('Spectra reconstructed from clusters')

    end
end
