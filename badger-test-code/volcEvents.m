function [EvCat,t0,lat,lon] = volcEvents(volc,event,update)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Volcano location and event data
%---------------------------------------
% INPUT (OPTIONAL): volc  = string containing volcano name
%                   event = string (eg 'E2') or number (eg 2)
%                   update = true/false -> true reads xls file to add lat
%                       lon to any newly entered volcano, or add new events,
%                       then saves data file
%
% OUTPUT          : t0    = datenum time of event (returns [] if no input)
%                 : EvCat = the full event catalog (structure)
global homedir paths

if nargin<1
    volc = [];
end
if nargin<2
    event = [];
end
if nargin<3
    update = false;
end

if isnumeric(event)
    event = sprintf('E%i',event);
elseif ~ischar(event)
    disp('volcEvent: Event code not recognized!')
    return
end
    
% activate_base;
% Volcano location file
volc_latlon_file = fullfile(paths.data,'gis/AKvolclatlong.xls');
datfile          = fullfile(paths.data,'volcEvents.mat');

if or(update,~exist(datfile,'file'))
    [~,~,volcDat] = xlsread(volc_latlon_file);
% * If no input is entered, will just output catalog structure

    EvCat = struct(...
            'Redoubt', struct(...
                            'grd', [], ...
                            'E1' , [2009,03,23,06,35,16], ...
                            'E2' , [2009,03,23,07,01,52], ...
                            'E3' , [2009,03,23,08,14,05], ...
                            'E4' , [2009,03,23,09,38,52], ...
                            'E4a', [2009,03,23,09,48,20], ...
                            'E5' , [2009,03,23,12,30,21], ...
                            'E8' , [2009,03,26,17,24,14], ...
                            'E12', [2009,03,28,01,34,43], ...
                            'E13', [2009,03,28,03,24,18], ...
                            'E18', [2009,03,29,03,23,31] ...
                                ), ...
                            ...    
            'Cleveland', struct(...  % Basemap: [49N 58N -180E -160E]
                            'grd', [], ...
                            'E1' , [2011,12,29,13,11,51], ...  % Approxmated from DeAngelis 2012 Fig 1
                            ...'E2' , [2013,05,04,12,58,58] ...   % Approximated from Fee et al 2015 Fig 3
                            'E2' , [2013,05,04,12,58,54], ...    % Estimated from travel times across okmok array - if stratospheric bounce this is prob too early
                            'E3' , [2013,05,04,17,16,00], ...     % Estimated from DFee AVO log email, Oct 24 2016
                            'E4' , [2016,10,24,21,05,00], ...
                            'E5' , [2011,12,25,12,08,00], ...
                            'E6' , [2011,12,29,13,07,00] ...
                                ), ...
                            ...
            'Kasatochi', struct(...  % Basemap: 
                            'grd', [], ...
                            'E1' , [2008,08,07,21,59,04], ...  % all from Fee et al 2010
                            'E2' , [2008,08,09,01,34,44], ...    
                            'E3' , [2008,08,09,04,20,34], ...     
                            'E4' , [2008,08,09,19,41,54] ...
                                ), ...
                             ...
            'Okmok', struct(...  % Basemap: 
                            'grd', [], ...
                            'E1' , [2008,07,12,19,41,54] ...  % all from Fee et al 2010
                                ) ...                
             );


     % Attach lat/lon info

    volcs = fieldnames(EvCat);

    for k = 1:numel(volcs)
        name = volcs{k};
        iv = find(strcmp(volcDat(:,2),name));
        lat = volcDat{iv,3};
        lon = volcDat{iv,4};
        eval(['EvCat.' name '.lat = lat;'])
        eval(['EvCat.' name '.lon = lon;'])
    end
    save(datfile,'EvCat');
else
    load(datfile)
end

if and(~isempty(volc),~isempty(event))
   t0 = datenum(eval(['EvCat.' volc '.' event]));
   lat = eval(['EvCat.' volc '.lat;']);
   lon = eval(['EvCat.' volc '.lon;']);
else
    t0 = [];
end