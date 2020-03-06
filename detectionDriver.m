clear; close all;
global homedir
homedir = activate_base;
project

%------ Event and network information ------

ifile    = 'Cleveland_2_r300_c200.mat';

% volcano  = 'Cleveland';
% event    = 2;
% 
% % Waveform fetching and detection
% radius   = 300; %250; % km
% minC     = 200; % m/s
% maxC     = 360;
% 
% subnet = ''; % Pick a specific network, see "group_select.m". 
%              % This will overwrite any station selection above
% customstr = ''; % append this is a custom modifier to saved data and figs
%

% Manual selection of subset of stations? Try relying on detection first 

% Multi-taper Spectrogram properties
MTnw        = 4; % Time-bandwidth product
MTnfft      = 256;
MTfoverlap  = 0.9;
MTtlims     = [];
MTfband     = [0.1 25];

% Filtering
filtlims  = [2 10];
npoles    = 4;

% STA/LTA
sta_win    = 0.5;
lta_win    = 20.0;
thresh_on  = 3.5;
thresh_off = 1.5;
min_dur    = 2.0;

% ------------  FLAGS ------------ %
mtSpecFlag   = 0;
filterFlag   = false;
detectFlag   = 0;
savechans     = true;

% Plot flags
plotPreProc     = 0; % Plot waveforms after initial processing
plotMTspecs     = 1; % Plot multitaper spectrograms
plotFiltered    = 0; % Plot filtered waveforms
plotRecord      = 1;

iMat = fullfile(paths.wav,ifile);
detection_params = [sta_win lta_win thresh_on thresh_off min_dur];


%% DO THE THING
fprintf('\nSignal Detection, waveform file:\n\t%s',iMat)
%%
load(iMat)
showEventParams(E,w)

%% Spectral analysis
if mtSpecFlag
    w = wavMTspec(w,MTnw,MTnfft,MTfoverlap,MTtlims,MTfband,plotMTspecs,6);
    if savechans
        disp('Saving waveforms with updated spectrogram info...')
        save(iMat,'w','-append')
    end
end
if filterFlag
    filtObj  = filterobject('b',filtlims,npoles);
    wf       = filtfilt(filtObj,w);
    if plotFiltered
        plot_panelsSmart(w,'false',sprintf('Filtered: %.1f - %.1f Hz',filtlims(1),filtlims(2)))
    end
    if savechans
        save(iMat,'wf','-append')
        disp('Saving filtered waveforms as new objects...')
    end
end


%% DETECTION
% Scalar function
testi = 3;

% w(testi) = scalarSTALTA(w(testi),filtlims,detection_params);

if detectFlag
    w = scalarSTALTA(w,filtlims,detection_params);
end
if plotRecord
    plotWrecSec(w,1,0);
end