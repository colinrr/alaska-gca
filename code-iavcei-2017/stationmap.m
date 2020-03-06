    function stationmap(ss,E,Eloc,ofile,grd,map_empty);
% stationmap(ss,ofile);
%   Generate GMT basemap for channel array and event
%       ss    = channel structure or waveform
%       E     = event struct
%       Eloc  = true/false - OPTIONAL plot event location
%       ofile = name of output map (overrides default naming)
%       grd   = specify alternate grid to default
%       map_empty = coord list of map stations with empty data
global files homedir paths
addpath(fullfile(homedir,'code/python/mypackages/'))

if nargin<3
    Eloc = false;
end
if nargin<4
    ofile = '';
end
if nargin<5
    grd = [];
end
if nargin<6
    map_empty = false;
end

% Assemble x,y matrix
if isstruct(ss)
    ll = unique([ss.Latitude; ss.Longitude]','rows');
elseif strcmp(class(ss),'waveform')
    ll = unique([get(ss,'latitude') get(ss,'longitude')], 'rows');
end
llR =ll; % lat/lon array for calculating plotlims (optionally including event)

% Set event location?
if Eloc
    vFlag = '-v';
    fid = fopen(files.volc_temp,'w');
    fwrite(fid,sprintf('%.4f %.4f\n',E.lon,E.lat));
    fclose(fid);
    llR = [llR;  E.lat E.lon];
%     vCmd  = sprintf('echo "%.4f %.4f" > %s',Eloc(2),Eloc(1),files.volc_temp);
%     system(vCmd)
else
    vFlag = '';
end

pad = 0.3;
% Get R limits
latlim = [min(llR(:,1)) max(llR(:,1))];
lonlim = [min(llR(:,2)) max(llR(:,2))];
latlim = latlim+[-1 1]*diff(latlim)*pad;
lonlim = lonlim+[-1 1]*diff(lonlim)*pad;
R = sprintf('R%.2f/%.2f/%.2f/%.2f',lonlim(1),lonlim(2),latlim(1),latlim(2));

% Write coord file
fid = fopen(files.stat_temp,'w');
for k = 1:size(ll,1)
    fwrite(fid,sprintf('%.4f %.4f\n',ll(k,2),ll(k,1)));
end
fclose(fid);

% Choose basemap?
if ~isempty(grd)
    bsFlag = sprintf(' -g %s',grd);
else
    bsFlag = '';
end

if isempty(ofile)
    ofile = fullfile(paths.maps,sprintf('%s_%i%s.ps',E.volcano,E.enum,E.tstring));
end
% Map empty?
% if map_empty
%     eFlag = ' -e';
% else
%     eFlag = '';
% end
% Send system command
fprintf('\nMap command:\n\n')
fprintf('python station_basemap.py -r %s -o %s %s%s%s',R,ofile,vFlag,bsFlag)
fprintf('\n')
% system(cmd,'-echo')

% Alternatively, output kml for google earth