% Quick (for now) driver to test out new WavPCA function
clear all; close all

pcview = [2 3 4];
fbands = {[]};
pcmode = 'st_dmednorm'; %'st_dmednorm';

datdir = '~/Nextcloud/data/alaska-gca/manual-cut-waveforms/';
bgdir  = '~/Nextcloud/data/alaska-gca/background-waveforms/';

% Full signal
ifile = fullfile(datdir,'Cleveland_30_Aug17.mat');
% Background
bfile = fullfile(bgdir,'Cleveland_30.mat');



%% ----------- RUN WavPCA --------------
load(ifile)
pcdat = WavPca(w,fbands,pcmode,pcview);

% load(bfile)
% pcdatB = WavPca(wb,fbands,pcmode,pcview);