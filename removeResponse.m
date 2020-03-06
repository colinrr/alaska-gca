function[w] = removeResponse(w,ss,resp,plotflag)
    % ss = channel info
    % resp = stucture with fields:
    %       lims: [2x1] vector of frequency limits for response filter
    %       filtpoles : number of poles for the filter  

if nargin<3
    resp.lims = [0 20];
    resp.filtpoles = 2;
end
N = numel(w);
%% Remove response

% Create response struct
% Try a default frequency space for now - could cap at nyquist?
frequencies = logspace(-2,2,100);
resp_polezero = struct( 'scnl',[],'time',[],'frequencies',[],'values',[],...
            'calib', cell(N,1), 'units',[],'sampleRate',[],'source',[],...
            'status',[]);

% Prefilter
filtObj = filterobject('b',resp.lims,resp.filtpoles);
w       = filtfilt(filtObj,w);    
fprintf('\nApplying response correction...\n')
for k = 1:N
    % get the right channel
    chan = get(w(k),'ChannelTag');

    ssR = ss( strcmp({ss.NetworkCode},chan.network) & ...
               strcmp({ss.StationCode},chan.station) & ...
               strcmp({ss.LocationCode},chan.location) & ...
               strcmp({ss.ChannelCode},chan.channel) ...
               ); 
    chanResponse = ssR.Response.Stage(1).PolesZeros; 

    polezero = struct(...
        'poles'         , chanResponse.Pole, ...
        'zeros'         , chanResponse.Zero, ...
        'normalization' , chanResponse.NormalizationFactor ...
        );

    w(k) = response_apply(w(k),filtObj,'polezero',polezero);
    if plotflag
        resp_polezero(k) = response_get_from_polezero(frequencies, polezero);
    end
end

if plotflag
    response_plot(resp_polezero)
end
%     filtObj = filterobject('b',resp.lims,resp.filtpoles);
%     wf       = filtfilt(filtObj,w);
%     w       = response_apply(wf,filtObj,'polezero',resp_polezero);
end
