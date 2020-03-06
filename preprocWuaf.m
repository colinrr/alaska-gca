function[w,E,ss] = preprocWuaf(w_raw,E,ss,resampFreq,fparams) %,ss,response_flag,resp)
% Run some basic pre-processing to clean up the data
%   E = event meta data structure
%   ss = station inventory infoss
%   resampFreq = manual entry for frequency resampling
%
%   fparams = Nx2 cell array:
%   {ftype,param} = type of filter to use to subset waveform and subset
%   params. Can use multiple filter criteria
%           opts:   {'EventDistance', dist} (km)
%                   {'EventAzimuth', [az_min az_max]} -> If azmin>azmin,
%                   wraps around 360
%                   {'ChannelTag', {network,station,location,channel} }
%                                   - can leave empty fields ''  - glob?
%                                   - each entry can be multi-cell {network}
%                   [],[] - no subset [default]
%
% Colin Rowell, July 2017


if nargin<4
    resampFreq=[];
end
if nargin<4
    fparams = {};
end
if nargin==4
    warning('Not enough input args: ftype requires paired parameter. No subsetting will occur.')
    fparams = {};
end

E.tstring = '_prep';

%% Initial setting parameters
w = w_raw;
Nraw = numel(w_raw);
%% Re-assign network/location values, add missing meta data fields (stupid uaf_continuous)
chtags = get(w,'ChannelTag');
wS = join([{chtags.station}' {chtags.channel}'],'.',2); 
% Strip networks
% w_strings = join(w_strings(:,2:4),'.',2);

sS = join([{ss.StationCode}', {ss.ChannelCode}'], '.', 2);

[~,~,Is] = intersect(wS,sS,'stable');

if length(Is)==length(w)
    ss = ss(Is);
    [chtags.network] = deal(ss.NetworkCode);
    [chtags.location] = deal(ss.LocationCode);
else
    error('Could not uniquely re-assign network/location codes!')
end

for k = 1:Nraw
    w(k) = set(w(k),'ChannelTag',chtags(k));
    w(k) = addfield(w(k),'Azimuth'              ,ss(k).Azimuth);            % 'AZIMUTH'    
    w(k) = addfield(w(k),'DEPTH'                ,ss(k).Depth);              % 'DEPTH'
    w(k) = addfield(w(k),'DIP'                  ,ss(k).Dip);                % 'DIP'
    w(k) = addfield(w(k),'ELEVATION'            ,ss(k).Elevation);          % 'ELEVATION'
%     w(k) = addfield(w(k),'INSTRUMENT',ss(k).Azimuth);                     % 'INSTRUMENT'
    w(k) = addfield(w(k),'LATITUDE'             ,ss(k).Latitude);           % 'LATITUDE'
    w(k) = addfield(w(k),'LONGITUDE'            ,ss(k).Longitude);          % 'LONGITUDE'
    w(k) = addfield(w(k),'SENSITIVITY'          ,ss(k).SensitivityValue);   % 'SENSITIVITY'
    w(k) = addfield(w(k),'SENSITIVITYFREQUENCY' ,ss(k).SensitivityFrequency); % 'SENSITIVITYFREQUENCY'
    w(k) = addfield(w(k),'SENSITIVITYUNITS'     ,ss(k).SensitivityUnits);
end

%% Clean out empty entries
remove_list = [];
for k = 1:Nraw
    if isempty(get(w(k),'data'))
        remove_list = [remove_list k];
    end
end
w(remove_list) = [];
ss(remove_list) = [];
N = numel(w);
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

%% Subset waveform
disp('Filtering to subset of waveforms...')
[w,E,ss,subset] = subsetW(w,E,ss,fparams);
N = numel(w);


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
if or(minfreq<mean(freqs),~isempty(resampFreq))
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
E = updateE(E,ss);
E.tstring = [subset E.tstring];
w = sortby(w,'EventDistance');

end

function[w,E,ss,subset] = subsetW(w,E,ss,fparams)

if ~isempty(fparams) && size(fparams,2)~=2
    error('Input "fparams" must be [Nx2] cell array')
else
    subset = '';
    chsubset  = '';
end
for k = 1:size(fparams,1)
    ftype  = fparams{k,1};
    fparam = fparams{k,2};
    if ~isempty(fparam)
        switch ftype
            case 'EventDistance'
                if isscalar(fparam)
                    idx = get(w,ftype)<=fparam;
                    E.radius = fparam;
                    subset = [subset sprintf('_r%i',fparam)];
                    fprintf('\t%s: %i\n',ftype,fparam)
                elseif length(fparam)==2
                    idx = (get(w,ftype)<=max(fparam)).*(get(w,ftype)>=min(fparam));
                    fprintf('\t%s: %i %i\n',ftype, min(fparam), max(fparam))
                else
                    error('subsetW: fparam must be scalar for ftype: ''EventDistance''')
                end

            case 'EventAzimuth'
                if length(fparam)==2 && all(fparam<360) && all(fparam>=0)
                    if fparam(1)<=fparam(2)
                        idx = and( get(w,ftype)>=fparam(1) ,  get(w,ftype)<=fparam(2) ) ;
                    else
                        idx = or( and(get(w,ftype)>=fparam(1) ,  get(w,ftype)<=360),...
                                and(get(w,ftype)>=0 ,  get(w,ftype)<=fparam(2)) ) ;
                    end
                    E.azRange = fparam;
                    subset = [subset sprintf('_az%i-%i',fparam(1),fparam(2))];
                    fprintf('\t%s: %i %i\n',ftype, min(fparam), max(fparam))
                else    
                    error('subsetW: fparam must be vector of length 2 in interval [0 360) for ftype: ''EventAzimuth''')
                end

            case 'ChannelTag'
                % Forget wildcards for now
    %             error('wtf do I do with this, fucking wildcards?') % System call?
        %         E.station_params = fparam;
                fprintf('\tFiltered by new station parameters.\n')
                chantags = get(w,ftype);
                nw = fparam{1};
                st = fparam{2};
                lo = fparam{3};
                ch = fparam{4};
                if ~isempty(nw)
                    nwi = ismember({chantags.network},nw);
                    chsubset = [chsubset '_nw'];
                else
                    nwi = ones(size(chantags))';
                end
                if ~isempty(st)
                    sti = ismember({chantags.station},st);
                    chsubset = [chsubset '_st'];
                else
                    sti = ones(size(chantags))';
                end
                if ~isempty(lo)
                    loi = ismember({chantags.location},lo);
                    chsubset = [chsubset '_lo'];
                else
                    loi = ones(size(chantags))';
                end
                if ~isempty(ch)
                    chi = ismember({chantags.channel},ch);
                    chsubset = [chsubset '_ch'];
                else
                    chi = ones(size(chantags))';
                end
                idx = nwi & sti & loi & chi;
                E.station_params = fparam;

        end
        w = w(idx);
        ss = ss(idx);
    end
end
subset = [subset chsubset];
end
