function pcaplot(w,fbands,pca_mode)
% w = input waveform
% fband = freq band of interest. (Can leave empty)
% pca_mode = 'raw','norm','shiftnorm'

Nw = numel(w);
nrows = 2 + length(fbands);

figure('position',[100 100 Nw*250+100 600])
pcax = []; % zeros([]);

for k = 1:Nw;
    pxx = get(w(k),'pxxmt');
    fmt = get(w(k),'fmt');
    tmt = get(w(k),'tmt');
    pn = size(pxx,1);
    
    % Set up pxx type
    if strcmp(pca_mode,'raw')
        disp('PCA: using Raw spectra')
        tstr = 'Raw spectrogram';
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
        disp('Bad PCA mode')
        flargh
    end
    
    pca_bands(length(fbands)) = struct('fband',[],'PCs',[],'eVecs',[],...
                        'eVals',[],'tsq',[],'pcnt_var',[],'mu',[]); %length(fbands),1);

    % Initial plot of full spectrogram
    tightSubplot(nrows,Nw,k);
    imagesc(tmt,fmt,pxx); set(gca,'YDir','Normal')
    colormap('hot')
    datetick('x','HH:MM:SS','keeplimits')
%     xlabel('Time')
    ylabel('Freq')
    title(string(get(w(k),'channeltag')))
    caxis(caxis*1.05)
    caxis(caxis*1.1)
    
    for j = 1:length(fbands)
        fband = fbands{j};
        % Cut out freq band
        if isempty(fband)
            fi = true(size(fmt));
            fband = [min(fmt) max(fmt)];
        else
            fi = logical((fmt>=fband(1)) .* (fmt<=fband(2)));
        end
%         fmt1 = fmt(fi);
        pxx1 = pxx(fi,:);

        [eVecs, PCs, eVals, tsq, pcnt_var, mu] = pca(pxx1');
        pca_bands(j) = struct('fband',fband,'PCs',PCs,'eVecs',eVecs,...
                        'eVals',eVals,'tsq',tsq,'pcnt_var',pcnt_var,'mu',mu);
    end

       
    tightSubplot(nrows,Nw,k+Nw);
    lbls = cell(length(fbands),1);
    for j = 1:length(fbands)
        p90 = min(find(cumsum(pca_bands(j).pcnt_var)>=90));
        plot(pca_bands(j).pcnt_var,'.-')
        hold on
        lbls{j} = sprintf('%.1f - %.1f Hz, p90=%i',pca_bands(j).fband(1),pca_bands(j).fband(2),p90);
    end
    xlabel('mode')
    ylabel('% variance')
%     title(sprintf('p90 = %i',p90))
    xlim([0 20])
    ylim([0 100])
    legend(lbls)
    
    for j = 1:length(pca_bands)
        ax = tightSubplot(nrows,Nw,k+(1+j)*Nw);
        pcax = [pcax ax];
        pcs = pca_bands(j).PCs;
%         plot(pcs(:,1),pcs(:,2),'.')
        scatter3(pcs(:,1),pcs(:,2),pcs(:,3),5,'Marker','.')
        xlabel('PC 1')
        ylabel('PC 2')
        zlabel('PC 3')
        title(sprintf('%.1f - %.1f Hz',pca_bands(j).fband(1),pca_bands(j).fband(2)))
        axis equal
    %     xlim([-1 1]*max(abs(xlim)))
    %     ylim([-1 1]*max(abs(ylim)))

        % This will be the one
    end
end
linkaxes(pcax,'xy')
nom = sprintf('%i - %i, %s',fband(1),fband(2),tstr);
set(gcf,'name',nom)