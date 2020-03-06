function[chantags,E,ss] = getBulkStations(E,latlonfile) %volcano,event,station_params,radius,minC,maxC)
%[ch_tags] = getStationsArea(volcano,event,channels,radius,minC,mapflag)
%   Get channel tag and response arrays for a given volcano, event, radius,
%   and minimum celerity
%       volcano  = string, volcano name
%       event    = event number or string
%       channels = comma separated list or wildcards
%       radius   = get stations within this distance (km) of event
%       min_c    = minimum celerity (m/s) - dictates max time window

%
%   OUT: chantags = Channel Tag array for input into waveform
%        E        = structure with event info
%        ss       = response structure...WIP
%
%   C Rowell, July 2017



station_params = E.station_params;
radius  = E.radius;
minC    = E.minC;
maxC    = E.maxC;
t0      = E.t0;
tStart  = E.tStart;
% tEnd    = E.tEnd;

if ~and(iscell(station_params) , numel(station_params)==4)
    error('Argument "station_params" must be cell of length 4')
end

avail_flag = true;
network = station_params{1};
station = station_params{2};
location = station_params{3};
channels = station_params{4};
%% Get event location 
[~,~,volcDat] = xlsread(latlonfile);
iv = find(strcmp(volcDat(:,2),E.volcano));
lat = volcDat{iv,3};
lon = volcDat{iv,4};
% [~,t0,lat,lon] = volcEvents(volcano,event,true);

% Calc Timespan (seconds) (add seventmall buffer)
tbuff = 60;
tspan = radius*1e3/minC + tbuff; 
t1    = t0 + time2datenum(tspan,'seconds');

% t strings
% tStart = datestr(t0, 'yyyy-mm-dd HH:MM:SS');
tEnd   = datestr(t1, 'yyyy-mm-dd HH:MM:SS');

disp('Fetching channel tag and response arrays...')
%% Get channel tags/response array

% ds = datasource('irisdmcws');
ss  = irisFetch.Channels('response',network,station,location,channels,...
            'StartTime',tStart,'EndTime',tEnd, 'IncludeAvailability', avail_flag, ...
            'radialcoordinates', [lat lon km2deg(radius) 0]);

chantags = ChannelTag.array({ss.NetworkCode}, {ss.StationCode}, ...
            {ss.LocationCode}, {ss.ChannelCode});
% Quick fix for slightly broken channel tags
for k = 1:length(chantags)
    if isempty(chantags(k).location)
        chantags(k).location = '--';
    end
end
         
E.Nchannels = numel(ss);
E.Nstations = numel(unique({ss.StationCode}));
E.Nnetworks = numel(unique({ss.NetworkCode}));
fprintf('%i Channels, %i Stations, %i Networks\n',...
    E.Nchannels,...
    E.Nstations,...
    E.Nnetworks)

for k = 1:numel(station_params)
    if ~iscell(station_params{k})
        station_params{k} = {station_params{k}};
    end
end
% Keep some event stats to save for future ref
% E.volcano = volcano;
% E.enum    = event;
% E.t0      = t0;
% E.t1      = t1;
E.tspan   = tspan;
E.tStart  = strrep(tStart,'-','/');
E.tEnd    = strrep(tEnd,'-','/');
E.lat     = lat;
E.lon     = lon;
E.radius  = radius;
E.minC    = minC;
E.maxC    = maxC;
E.station_params = station_params;
