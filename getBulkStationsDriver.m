%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Driver to get bulk volcano event meta data
% ------------------------------------------

clear; close all;
global homedir
homedir = activate_base;
project

% USER INPUT
% Waveform fetching and detection
radius   = 500; %250; % km
minC     = 200; % m/s
maxC     = 360;

network   = '*';
station   = '*'; %{'OK*','KO*'}; %{'OKWR','OKWE','OKTU','OKRE','OKER'}; %
location  = '*';
% channel   = '*';
channel   = {'EH*','BH*'}; %{'B*Z','E*Z'}; %{'EH*','BH*'};
custom_str = ''; %_nADK';
% stationdb = '/aerun/sum/db/dbmaster/master_stations';
% wavsource = 'uaf_continuous';

evfile  = fullfile(paths.data,'event_inventory.xlsx');
% evsheet = 'AllEvents'; 
evsheet = 'ActiveEvents';
latlonfile = fullfile(paths.gis,'AKvolc_latlon/AKvolclatlong.xls');

ostr = '%s_%i_r%i_c%i%s'; % volc, event, radius, minC, sn_str, customstr
odir = fullfile(paths.data,'station_inventories');

% -------- JUST LIKE A WAVING FLAG -----------
% Flags for doing the thing
forceDLch    = true; % Force download and rewrite of channel inventory?
cut_redundant = true; % Cut stations with redundant station name, channel, and lat/lon
% savchans     = true; % Save channel response info (only if downloaded)


%% DO THE THING

% Get event set
[~, ~, evraw] = xlsread(evfile,evsheet);
% Parse excel events
evraw = evraw(2:end,:);

% Run through each event to do the thing
fprintf('Fetching bulk data...\n\n')
for ev = 1:size(evraw,1)
    
    % Initialize event metadata
    evrow   = evraw(ev,:);
    t0vec   = [evrow{3} evrow{4} evrow{5} evrow{6} evrow{7} evrow{8}];    
    evDur   = evrow{9};
    evDist  = evrow{10};

    E.volcano = evrow{1};
    E.enum    = evrow{2};
    E.t0      = datenum(t0vec);
    E.tStart  = datestr(E.t0, 'yyyy-mm-dd HH:MM:SS');
    E.notes   = evrow{11};
    E.minC    = minC;
    E.maxC    = maxC;
    E.station_params = {network,station,location,channel};
    E.notes   = evrow{11};

    % Get optional radius/duration override
    if isnan(evDist) % Radius override
        E.radius = radius;
    else
        E.radius = evDist;
    end
    if isnan(evDur) % Duration override
        E.tspan = radius*1e3/E.minC + 60;
    else
        E.tspan = evDur;
    end
    
    fprintf('Volcano:\t%s\nEvent:\t\t%s\n',E.volcano,num2str(E.enum))
    fname = sprintf(ostr,E.volcano,E.enum,E.radius,E.minC,custom_str);
    oMat = fullfile(paths.inven, [fname '.mat']);
    
    %     station_params = {{network},{station},{location},{channel}};
    station_params = {network,station,location,channel};
    [chantags,E,ss] = getBulkStations(E,latlonfile);

    %% ##### Scan through station structure and remove any reduntant stations
if cut_redundant
    disp('Removing redundant stations.')
    % v----> remove anything with identical lat/lon and channel name
    latlon    = [[ss.Latitude]; [ss.Longitude]]';
    stats     = {ss.StationCode};
    chans     = {ss.ChannelCode};
    locs      = {ss.LocationCode};
    [idtab,isort]     = sortrows(table(stats',chans',latlon(:,1),latlon(:,2),locs'),[1 5]);
    
    % Cut out location code
    idtab = idtab(:,1:4);
    [~,IA,IC] = unique( idtab , 'rows', 'stable' );
    
    % First sort ss and and chantags, then cut out extras
    ss = ss(isort); chantags = chantags(isort);
    ss = ss(IA); chantags = chantags(IA);
    
    % Resort chantags
    chantags = chantags.sort;
    E = updateE(E,ss);
end
    %% ###########

    if or(~exist(oMat,'file'),forceDLch)
       fprintf('\nSaving Channel Inventory to mat:\n\t%s\n',oMat);
       save(oMat,'chantags','E','ss')
    end    
    
end



