% GISMO get data - test on the Spurr Network for Redoubt 2
clear; close all
%% Get input
global homedir
homedir = activate_base;

ds = datasource('irisdmcws');
% ds = datasource('uaf_continuous');
stations = {'BGL'}; %,...
% 			'BKG',...
% 			'CGL',...
% 			'CKL',...
% 			'CKN',...
% 			'CKT',...
% 			'CP2',...
% 			'CRP',...
% ...			'SPBG',...
% ...			'SPCG',...
% 			'SPNW',...
% 			'SPU',...
% 			'SPWE',...
% ...			'SPCR',...
% ...         'STLK',...
%             };


starttime = '2009/03/23 07:01:52';
endtime  = '2009/03/23 07:10:12';

datadir = fullfile(homedir,'data/alaska-gca/waveforms/');
ofile   = fullfile(datadir,'Red_2_spurrNW.mat');
dl_data = true;

%% Processing params
% Response Filtering
resplims = [0.5 20];
npoles   = 4;

% Analysis filtering
filtlims = [8 20];


% Spectrogram
nfft = 512;
foverlap = 0.9;
maxf = 20;

%##################################################################
%% Load data
ctag = ChannelTag.array('AV',stations,'--','EHZ');

if dl_data
    w_raw = waveform(ds,ctag,starttime,endtime);
    save(ofile,'w_raw');
else
    load(ofile);
end

% Combine and clean data
w = combine(w_raw);
w = medfilt1(w,3); % remove any spikes of sample length 1
w = fillgaps(w,'interp');
w = demean(w);
w = detrend(w);

%% Downsample to a common sampling frequency - lowpass first?
% minfreq = min(get(w,'freq'));
% for c=1:numel(w)
%     current_fsamp = round(get(w(c),'freq'));
%     w(c) = resample(w(c), 'mean', current_fsamp/minfreq );
% end

%% Remove response
filtObj = filterobject('b',resplims,npoles);
wf       = filtfilt(filtObj,w);
% wR      = response_apply(w,filtObj,SOURCE??


% plot_panels(w);

%%
filtObj2 = filterobject('b',filtlims,npoles);
wf = filtfilt(filtObj2,wf);

%                                 %max freq, [dbmin dbmax]
s = spectralobject(nfft,nfft*foverlap,20,[20 80]);
% figure
% plot_panels(wf);
% figure
% spectrogram(w,s);

%
% BGL_PCA