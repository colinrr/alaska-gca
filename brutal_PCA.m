% Brutal PCA for Cleveland May 4 2013 event (E2)
clear; close all

project
ifile    = 'Cleveland_2_r300_c200.mat';
ofile    = 'Cleveland_2_brutal-PCA-bgrd.mat';
iMat = fullfile(paths.wav,ifile);
oMat = fullfile(paths.wav,ofile);

station_list = {'OKWR','OKWE','OKER','KOFP','KOKL','KOWE'};

% Multi-taper Spectrogram properties
MTnw        = 3; % Time-bandwidth product
MTnfft      = 512;
MTwlen      = 512;
MTfoverlap  = 0.9;
MTtlims     = [];
MTfband     = [];%[2 10];

% PCA mode - 'raw', 'norm', 'normshift'
fbands = {[]};%,[2 10],[18 25]};% [2 10];
pca_mode = 'raw';
pcview   = [1 2 3];

noise_calc = 0;
plotMTspecs = 1;
timeseriesPCA = 0;
%% Load up and run multi-taper
% load(iMat)
% showEventParams(E,w)

%% Manual signal picker
% w = wavMTspec(w,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);
% w = quickgrab(w,station_list,'spec');
% % 
% fprintf('Saving %s...\n',oMat)
% save(oMat,'w','E')

%%
load(oMat)
showEventParams(E,w)

% plotMTspec(w,MTtlims,MTfband)
% wpca = wavMTspec(w,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);

% save(oMat,'wpca','-append')
% w=wpca(1:6);
%% Noise assessment - use 'Cleveland_2_brutal-PCA-bgrd.mat'
if noise_calc
    % Stack up waveforms
    wbg = w;
    wavN = zeros(size(w));
    for k=1:numel(wavN); wavN(k) = length(get(w(k),'data')); end
    wavN = min(wavN);
    
    % stack waveforms
    stack_dat = zeros(wavN,1);
    for k = 1:numel(w)
        wdat = get(w(k),'data');
        stack_dat = stack_dat + wdat(1:wavN);
    end
    stack_dat = stack_dat/numel(w);
%     stackt0   = get(w(1),'Start');
    
    wbg = set(w(k),'data',stack_dat);
    wbg = wavMTspec(wbg,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);
    % OR stack specgrams
    w = wbg;
end
%% Chug some PCA
% pca_mode = 'norm';
% flargh
% pcaplot(w,fbands,pca_mode)
singleWavPca(w,fbands,pca_mode,pcview)
WavPca(w,fbands,pca_mode,pcview)
%% Ugly time series PCA
if timeseriesPCA
    n=14177;
    w = extract(w,'INDEX',1,n);
    X = get(w,'data');
    [x1,x2,x3,x4,x5,x6] = deal(X{:});
    XX = [x1 x2 x3 x4 x5 x6];
    [eVecs, PCs, eVals, tsq, pcnt_var, mu] = pca(XX);

    figure
    tightSubplot(2,2,1);
    plot(pcnt_var,'.-');
    
    ax1=subplot(2,2,2);
    plot(PCs(:,1),PCs(:,2),'.')
    xlabel('PC 1'); ylabel('PC 2')
    axis equal
    
    ax2=subplot(2,2,3);
    plot(PCs(:,2),PCs(:,3),'.')
    xlabel('PC 2'); ylabel('PC 3')
    axis equal
    
    ax3=subplot(2,2,4);
    plot(PCs(:,1),PCs(:,3),'.')
    xlabel('PC 1'); ylabel('PC 3')
    axis equal
    
    linkaxes([ax1 ax2 ax3],'xy')

    figure('name','Input data')
    for k=1:6; tightSubplot(6,1,k,[],0);plot(get(w(k),'data'));end

    figure('name','PCs')
    for k=1:6; tightSubplot(6,1,k,[],0);plot(PCs(:,k));end
end