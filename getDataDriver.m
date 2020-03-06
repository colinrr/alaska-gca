%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Driver to get volcano event data
% -------------------------------------
clear; close all;
global homedir
homedir = activate_base;
% homedir = '/Users/crrowell/';
% global homedir
project

% USER INPUT
% datadir = fullfile(homedir,'data/alaska-gca/');
% invdir  = fullfile(paths.data, 'station-inventories/');

%------ Event and network information ------
volcano  = 'Cleveland';
event    = 2;

% Waveform fetching and detection
radius   = 300; %250; % km
minC     = 200; % m/s
maxC     = 360;

subnet = ''; % Pick a specific network, see "group_select.m". 
             % This will overwrite any station selection above
customstr = ''; % append this is a custom modifier to saved data and figs

network  = '*';
station  = '*'; %{'OK*','KO*'}; %{'OKWR','OKWE','OKTU','OKRE','OKER'}; %
location = '*';
channel = {'EH*','BH*'};

%------ Processing params -----------------
resampFreq = 50; % Downsample to this frequency. [] to use auto

response.lims = [0.01 25]; % Range of freq's to filter over when applying response correction
response.filtpoles = 4;

% Multi-taper Spectrogram properties
MTnw        = 3; % Time-bandwidth product
MTwlen      = 256;
MTnfft      = 256;
MTfoverlap  = 0.9;
MTtlims     = [];
MTfband     = [0.1 25];

% Filtering
filtlims  = [2 10];
npoles    = 4;

% -------- JUST LIKE A WAVING FLAG -----------
% Flags for doing the thing
forceDLch    = true; % Force download and rewrite of channel inventory?
wPreProcess  = true; % Apply pre-processing
responseFlag = false; % Remove response? 
mtSpecFlag   = true; % Run multi-taper spectrogram
filterFlag   = false; % Filter waveforms

savchans     = true; % Save channel response info (only if downloaded)
savspecs     = true; % Save spectrogram information

% Plot flags
mapChannelArray = 0; % 0 = no map, 1 = stations only, 2 = stations plus event location
mapDataArray    = 2; % Same as above, but only maps stations with data for event - will overwrite files for above
plotRawWavs     = 0; % Plot raw waveforms
plotPreProc     = 0; % Plot waveforms after initial processing
plotResponse    = 0; % Plot channel responses
plotWavResponse = 0; % Plot waveforms after response removal
plotMTspecs     = 1; % Plot multitaper spectrograms
plotFiltered    = 0; % Plot filtered waveforms
plotRecord      = 1;
% ---------------------------------------

%% DO THE THING
fprintf('Volcano:\t%s\nEvent:\t\t%s\n',volcano,num2str(event))
% Prep a few names and tags
if ~isempty(subnet)
    station = group_select(subnet);
    sn_str = sprintf('_%s-NW',subnet);
    bs_map = sprintf('ak_basemap%s.grd',sn_str);
    grdfile = fullfile(paths.mapDat,bs_map);
    fprintf('Subnet:\t%s\n',subnet)    
else
    sn_str = '';
    bs_map = sprintf('ak_basemap_%s.grd',volcano);
    grdfile = fullfile(paths.mapDat,bs_map);
end
fname = sprintf('%s_%i_r%i_c%i%s%s',volcano,event,radius,minC,sn_str,customstr);
oMat = fullfile(paths.wav,[fname '.mat']);
oPs  = fullfile(paths.mapImg,[fname '.ps']);


%% Get Station/Response information
if or(~exist(oMat,'file'),forceDLch)
%     station_params = {{network},{station},{location},{channel}};
    station_params = {network,station,location,channel};
    [chantags,E,ss] = getStationsArea(volcano,event,station_params,radius,minC,maxC);
    % Save files?
    if savchans
%         ofile = fullfile(invdir,fname);
        fprintf('\nSaving Channel Inventory to mat:\n\t%s\n',oMat);
        save(oMat,'chantags','E','ss');
    end
else
    fprintf('Loading Channel Inventory:\n\t%s\n',oMat);
    load(oMat)
end

% PLOT: Output map of all Stations?
if mapChannelArray==2
    stationmap(ss,oPs,[E.lat,E.lon],grdfile);
elseif mapChannelArray==1
    stationmap(ss,oPs);
end


%% Get waveforms

if or(~exist('w_raw','var'),forceDLch) % If previously downloaded, should have loaded waveform data already
    disp('Fetching data source and downloading waveform data...')
    ds = datasource('irisdmcws');
    w_raw = waveform(ds,chantags,E.tStart,E.tEnd);
    if savchans
        fprintf('\nSaving Raw Waveform data to mat:\n\t%s\n',oMat);
        save(oMat,'w_raw','-append');
    end
else
    disp('Waveform data already stored.')
end

% PLOT: Raw waveforms
if plotRawWavs
    plot_panelsSmart(w_raw,'Raw waveforms')
end
% Clean up a bit
clear channel event volcano station station_params radius minC
%% Waveform pre-processing
if wPreProcess
    w = preprocW(w_raw,E,resampFreq);
    
    % Calc time range of expected arrivals
    travelt = [get(w,'EventDistance')*1e3 ];
    
    % PLOT: map of all stations WITH data
    if mapDataArray==2
        stationmap(w,oPs,[E.lat,E.lon],grdfile);
    elseif mapDataArray==1
        stationmap(ss,oPs);
    end    
    if plotPreProc
        plot_panelsSmart(w,false,'Pre-processed waveforms')
%         plot_spectrum(w)
%         set(gcf,'name','Pre-processed spectrum')
    end
end
if responseFlag
    w_noR = w;
    w = removeResponse(w,ss,response,plotResponse);
    
    if plotWavResponse
        plot_panelsSmart(w,false,'Response removed')
%         plot_spectrum(w)
%         set(gcf,'name','Response removed spectrum')
    end
    
end

if savchans
    fprintf('\nSaving Pre-processed Waveform data to mat:\n\t%s\n',oMat);
    save(oMat,'w','-append');
end

%% Spectral analysis
if mtSpecFlag
    w = wavMTspec(w,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);
    if savspecs
       fprintf('\nSaving Spectrogram data to waveform in:\n\t%s\n',oMat);
       save(oMat,'w','-append')
    end    
end
if filterFlag
    filtObj  = filterobject('b',filtlims,npoles);
    w        = filtfilt(filtObj,w);
    if plotFiltered
        plot_panelsSmart(w,'false',sprintf('Filtered: %.1f - %.1f Hz',filtlims(1),filtlims(2)))
    end
end


%%
% 
% if plotRecord
%     plotWrecSec(w,1,0);
% end
%% Plotting
% fprintf('\nGenerating plots.\n')
% NOTE - maps don't actually plot right now, just prints out a shell
% command to copy and paste for gmt. Paths aren't working when calling
% directly from matlab.



% Plot station responses
