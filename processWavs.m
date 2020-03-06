% Load and process raw uaf_waveforms

%%%% CURRENT WORKFLOW %%%%
% 1) Load raw data, set event parameters (distances, azimuths, times, etc)
% 2) Run preprocWuaf: add metadata fields, clean empty entries, set event
       % structure, downsample, optionally subset waveform
% 3) Apply station responses - NOT WORKING RIGHT NOW
% 4) Calculate multi-taper spectrogram
% 5) Filter waveforms
%%%%%%%%%%%%%%%%%%%%
clear; close all
project

% ifile        = 'Redoubt_2_r500_c200.mat';
ifile        = 'Cleveland_17_r500_c200.mat';
% Big maybes: ~19, ~18 (broken OK), 17!!, 16, ~13, ~6 (OK), ~5 (OK), 4 (OK)

C17_t0 = 7.350464707735410e+05; % Corrected (still estimated, though) start time for Cleveland 17 - fix later

ofile_suffix = ''; %'Cleveland_2_brutal-PCA-bgrd.mat';
iMat = fullfile(paths.uaf,ifile);
% oMat = fullfile(paths.wav,ofile);

resampFreq = 50;

% Subsetting parameters
evDist    = 300; % single number or [1x2] distance range
evAz      = [];%[180 300];

networks  = '';
stations  = '';
locations = '';
channels  = {'EHZ','BHZ'};
station_group = 'Cleveland_17';

% Multi-taper Spectrogram properties
MTnw        = 3; % Time-bandwidth product
MTnfft      = 512;
MTwlen      = 512;
MTfoverlap  = 0.9;
MTtlims     = [];
MTfband     = [];%[2 10];

% Filtering
filtlims = [2 10];
npoles   = 4;

% PCA mode - 'raw', 'norm', 'normshift'
fbands = {[]};%,[2 10],[18 25]};% [2 10];
pca_mode = 'raw';
pcview   = [1 2 3];

% ------ SOME WAVING FLAGS -------
run_preproc  = 1;
run_response = 0;
run_MTspec   = 1;
run_filter   = 1;

save_stage   = 0; % 1 = pre-processed, 2 = response, 3 = MT spec, 4 = filtered
save_default_subset = 0; % If yes, saves any subset params as a permanent variable
load_default_subset = 0; % If yes, loads and applies saved subset params 
                         % > (overwrites current subset params unless
                         % "save_default_subset==1" also)

% Plot flags
plotraw     = 0;
plotResp    = 0; % Plot stations responses and corrected waveforms
plotproc    = 0; % Plot processed waveforms
plotMTspecs = 0;
plotfilt    = 0;
plotfMTspecs= 1; % Plot MT specs with filtered waveforms?
plotRecord  = 1;
    sFrac   = 0.2;

%% Parameter setup and load
ofile = strsplit(ifile,'_');
ofile = strjoin(ofile(1:2),'_');
% oMat = fullfile(paths.wav, [ofile(1) ofile_suffix ofile(2)]);
fprintf('Loading raw waveform file:\n\t%s\n',iMat)
load(iMat)
showEventParams(E)
if ~isempty(station_group)
    fprintf('Selecting custom group of stations: %s\n',station_group)
    stations = group_select(station_group);
end
subset    = {...
    'EventDistance', evDist;...
    'EventAzimuth',evAz;...
    'ChannelTag', {networks,stations,locations,channels}...
    };
if save_default_subset
    def_subset = subset;
    fprintf('Saving default subset parameters for:\n\t%s',iMat)
    save(iMat,'subset','-append')
end

% Temporary fix for Cleveland 17
if and(strcmp(E.volcano,'Cleveland'), E.enum==17)
    E.t0 = C17_t0;
end
%% Pre-processing
if plotraw
    plot_panelsSmart(w_raw,false,'Raw Waveforms')
end
if load_default_subset
    if exist('def_subset','var')
        disp('Loading default subset...')
        subset = def_subset;
    else
        disp('No default subset found.')
    end
end
if run_preproc
    [w,E,ss] = preprocWuaf(w_raw,E,ss,resampFreq,subset);
    if plotproc
        plot_panelsSmart(w,false,'Pre-processed Waveforms')
    end
    if save_stage==1
        ofile = [ofile E.tstring '.mat'];
        oMat  = fullfile(paths.wav, ofile);
        fprintf('\nSaving Pre-processed Waveform data to mat:\n\t%s\n',oMat);
        save(oMat,'w','E','ss');
    end
end
%% Responses
if run_response
    disp('Ha, as if...')
end

%% Multi-taper specs
if run_MTspec
    w = wavMTspec(w,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);
    E.tstring  = [E.tstring '_MT'];
    if save_stage == 3
       ofile = [ofile E.tstring '.mat'];
       oMat  = fullfile(paths.wav, ofile);
       fprintf('\nSaving Spectrogram data to waveform in:\n\t%s\n',oMat);
       save(oMat,'w','E','ss')
    end    
end
if run_filter
    filtObj  = filterobject('b',filtlims,npoles);
    w        = filtfilt(filtObj,w);
    E.tstring  = [E.tstring '_flt'];
    if plotfilt
        plot_panelsSmart(w,'false',sprintf('Filtered: %.1f - %.1f Hz',filtlims(1),filtlims(2)))
    end
    if plotfMTspecs
        plotMTspec(w)
    end
    if save_stage == 4
       ofile = [ofile E.tstring '.mat'];
       oMat  = fullfile(paths.wav, ofile);
       fprintf('\nSaving Filtered waveform in:\n\t%s\n',oMat);
       save(oMat,'w','E','ss')
    end    
end
%%
if plotRecord
    plotWrecSec(w,1,0,sFrac,E.t0,'EventAzimuth');
end