 function[w] = preprocW(w_raw,E,resampFreq) %,ss,response_flag,resp)
% Run some basic pre-processing to clean up the data
%   E = event meta data structure
%   resampFreq = manual entry for frequency resampling

if nargin<3
    resampFreq=[];
end

%% Initial cleaning and setting parameters
w = w_raw;
Nraw = numel(w_raw);
% Clean out empty entries
remove_list = [];
for k = 1:Nraw
    if isempty(get(w(k),'data'))
        remove_list = [remove_list k];
    end
end
w(remove_list) = [];

%% Run basic pre-processing
fprintf('Waveform pre-processing:\n\tCombining...\n')
w = combine(w);
fprintf('\tDe-spiking...\n')
w = medfilt1(w,3); % remove any spikes of sample length 1
fprintf('\tInterpolating gaps...\n')
w = fillgaps(w,'interp');
fprintf('\tDemean and detrend...\n')
w = demean(w);
w = detrend(w);

N = numel(w);

%% Downsample to a common sampling frequency - lowpass first?

% Check sample rates > if any different, resample to lowest common denom.
freqs   = get(w,'freq');
minfreq = min(freqs);
if or(minfreq<mean(freqs),resampFreq)
    if resampFreq
        minfreq = resampFreq;
    end
    fprintf('Downsampling waveforms to common frequency: %.1f Hz\n',minfreq)
    for c=1:N
        current_fsamp = round(get(w(c),'freq'));
        if current_fsamp>minfreq % ONLY RESAMPLE CHANNELS WITH HIGH FREQUENCY
            w(c) = resample(w(c), 'mean', current_fsamp/minfreq );
        end
    end
end


%% Use lat/lon info to set distance to event, then sort by distance
% [arclen,az] = distance(E.lat,E.lon,get(w,'Latitude'),get(w,'Longitude'));
% dist = deg2km(arclen);

% Better dist calc
[dist,az] = vdist(repmat(E.lat,size(w)),repmat(E.lon,size(w)),get(w,'Latitude'),get(w,'Longitude'));
dist = dist/1e3; % Convert to kms
for k = 1:N
%     w(k) = addfield(w(k),'EventArcLength', arclen(k));
    w(k) = addfield(w(k),'EventAzimuth', az(k));
    w(k) = addfield(w(k),'EventDistance', dist(k));
    w(k) = addfield(w(k),'EventArrivalRange', E.t0 + time2datenum([dist(k)*1e3/E.maxC dist(k)*1e3/E.minC],'seconds'));
end
w = sortby(w,'EventDistance');