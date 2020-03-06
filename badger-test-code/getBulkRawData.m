%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Driver to get bulk volcano event data
% ------------------------------------------

clear; close all;
global homedir
homedir = '/home/crowell/';

% USER INPUT
%------ Example Event and network information ------
volcano  = 'Okmok';
event    = 1;

% Waveform fetching and detection
radius   = 300; %250; % km
minC     = 200; % m/s
maxC     = 360;
duration = 2000; % Signal duration to fetch, in seconds?

subnet = ''; % Pick a specific network, see "group_select.m". 
             % This will overwrite any station selection above
customstr = ''; % append this is a custom modifier to saved data and figs

network   = {'*'};
station   = {'*'}; %{'OK*','KO*'}; %{'OKWR','OKWE','OKTU','OKRE','OKER'}; %
location  = {'*'};
channel   = {'EH*','BH*'}; %{'B*Z','E*Z'}; %{'EH*','BH*'};
stationdb = '/aerun/sum/db/dbmaster/master_stations';
wavsource = 'uaf_continuous';

evfile  = fullfile(homedir,'data-2017/event_inventory.xls');
evsheet = 'ActiveEvents';
latlonfile = fullfile(homedir,'data-2017/gis/AKvolclatlong.xls');

ostr = '%s_%i_r%i_c%i%s%s'; % volc, event, radius, minC, sn_str, customstr
odir = fullfile(homedir,'data-2017/raw-waveforms');

% -------- JUST LIKE A WAVING FLAG -----------
% Flags for doing the thing
forceDLch    = false; % Force download and rewrite of channel inventory?
wPreProcess  = true; % Apply pre-processing
savchans     = true; % Save channel response info (only if downloaded)


%% DO THE THING

% Get event set
[~, ~, evraw] = xlsread(evfile,evsheet);
% Parse excel events
evraw = evraw(2:end,:);

% Run through each event to do the thing
fprintf('Fetching bulk data...\n\n')
for ev = 1:size(evraw,1);
    evrow = evraw(ev,:);
    E.volcano = evrow{1};
    E.enum    = evrow{2};
    t0vec     = [evrow{3} evrow{4} evrow{5} evrow{6} evrow{7} evrow{8}];
    E.t0      = datenum(t0vec);
    E.tStart  = datestr(E.t0, 'yyyy/mm/dd HH:MM:SS');
    evDur     = evrow{9};
    evDist    = evrow{10};
    E.notes   = evrow{11};
    E.minC    = minC;
    E.maxC    = maxC;
    E.station_params = {network,station,location,channel};
    
%     fprintf('Volcano:\t%s\nEvent:\t\t%s\n',E.volcano,num2str(E.enum))
    fname = sprintf('%s_%i_r%i_c%i',volcano,event,radius,minC);
    oMat = fullfile(homedir,['data-2017/raw-waveforms/' fname '.mat']);
    
    % Get radius, start time, end time, lat/lon 
    if isnan(evDist)
        E.radius = radius;
    else
        E.radius = evDist;
    end
    if isnan(evDur)
        E.tspan = radius*1e3/E.minC + 60;
    else
        E.tspan = evDur;
    end
    E.t1 = E.t0 + time2datenum(E.tspan,'seconds');
    E.tEnd = datestr(E.t1, 'yyyy/mm/dd HH:MM:SS');

    [~,~,volcDat] = xlsread(latlonfile);
    iv = find(strcmp(volcDat(:,2),E.volcano));
    E.lat = volcDat{iv,3};
    E.lon = volcDat{iv,4};
    
    showEventParams(E)
    % Get site structure - no limit on number of stations for now
    sites = dbget_closest_sites(E.lon,E.lat,E.radius,stationdb,999,E.t0,E.t1);%,channel);
    
    chantags = sites.channeltag; %??
    
    
end



