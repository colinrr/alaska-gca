%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Driver to get bulk volcano event data
% ------------------------------------------
%% Remember to copy over station inventories

clear; close all;
global homedir
homedir = '/home/crowell/';

%% USER INPUT

% Channels to compare against for dirty edits
chancomp = {'BHZ','BHN','BHE','EHZ','EHN','EHE'};

% MATLABSAURUS PARAMS ------
% wavsource = 'irisdmcws';
% idir = '/home/crowell/Nextcloud/data/alaska-gca/station_inventories/';
% ostr = '%s_%i_r%i_c%i%s%s'; % volc, event, radius, minC, sn_str, customstr
% odir = fullfile(homedir,'Nextcloud/data/alaska-gca/raw-waveforms/');

% BADGER PARAMS ------------
wavsource = 'uaf_continuous';
idir = '/home/crowell/data-2017/station_inventories/';
ostr = '%s_%i_r%i_c%i%s%s'; % volc, event, radius, minC, sn_str, customstr
odir = fullfile(homedir,'data-2017/raw-waveforms/');

% -------- JUST LIKE A WAVING FLAG -----------
% Flags for doing the thing
forceDLch    = false; % Force download and rewrite of channel inventory?
% wPreProcess  = true; % Apply pre-processing
savchans     = true; % Save channel response info (only if downloaded)


%% DO THE THING

% Get file list
Dlist = dir(idir);

% Run through each event to do the thing
fprintf('Fetching bulk data...\n\n')
for ev = 1:length(Dlist)
    if strfind(Dlist(ev).name, '.mat')
        load(fullfile(idir,Dlist(ev).name))
        
        showEventParams(E)
        ds = datasource(wavsource);
        
        %% ---- Dirty edits... --------------------------------------------
        % to see what comes up for other BHZ/EHZ in uaf database
        % Get stations to start
%         keepi = ismember({chantags.channel}, chancomp);
%         keepers = chantags(keepi);
%         
%         changers = chantags(~keepi);
%         changers = changers(~ismember({changers.station}, unique({keepers.station})));
%         [~,IA,~] = unique( {changers.station} );
%         changers = changers(IA);
%         
%         changers1 = changers;
%         changers2 = changers;
%         [changers1.channel] = deal('BHZ');
%         [changers2.channel] = deal('EHZ');
%         chantags = [keepers changers1 changers2];
        
        % Update event params
        % -----------------------------------------------------------------
        %% Get THE STUFF
        w_raw = waveform(ds,chantags,E.tStart,E.tEnd);
        
        oMat = fullfile(odir, sprintf(ostr,E.volcano,E.enum,E.radius,E.minC) );
        fprintf('\nSaving Raw Waveform data to mat:\n\t%s\n',oMat);
        save(oMat,'w_raw','E','ss');
    end
end



