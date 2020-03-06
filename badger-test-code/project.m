% Set project directories and params
%  activate_base;
global paths files homedir
% homedir = activate_base;

paths = struct();
paths.data     = fullfile(homedir,'data-2017/');
paths.wav      = fullfile(paths.data,'waveforms');
paths.raw      = fullfile(paths.data,'raw-waveforms');
paths.inven    = fullfile(paths.data,'station_inventories');
paths.fig      = fullfile(paths.data,'figures/');
paths.mapDat   = fullfile(paths.fig,'map_data/');
paths.mapImg   = fullfile(paths.fig,'map_images/');
paths.layer    = fullfile(paths.mapDat,'basemap_vectors/');
paths.catalog  = fullfile(paths.data,'catalogs');


files = struct(...
    'volc_temp' , fullfile(paths.mapDat,'temp_volc.xy'),...
    'stat_temp' , fullfile(paths.mapDat,'temp_station_coords.xy')...
    );