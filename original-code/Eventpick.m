%///////////////////////////////////////
%           TIME PICKER
%   Part 2 to plotwavspec
%   Pick arrival times for events and calculate celerity

% Want to be able to select whole waveform or just single station etc

% Single station, group, or whole waveform?
statselect = 1;  % stations = 1, waveform = 0 (else);



if statselect
    % Which stations?
%     seismos = {'BKG','CKT','SPU'};
    seismos = input('Enter station name: ','s');
    
    indic = [];
%    for nn = 1:length(seismos);
        ii = find(strcmp(get(w2,'station'),seismos));
      indic = [indic ii];
%    end
    if isempty(indic)
        disp('Station not found')
    end
    w3 = w2(indic);
else
    w3 = w2;
end

% Data array - INTIALIZE THIS THE FIRST TIME ONLY
Picks = cell(length(w3),5);

% Set a default filter
Tlow_def = 1/8;   % By low, I mean frequency... :|
Thigh_def = 1/20;


for ii = 1:length(w3)
    disp(['Station and Channel: ' get(w3(ii),'station') '_' get(w3(ii),'channel')])
    filtselect = input('Filter? d = default, c = custom, n = no , q = quit, else = skip channel : ','s');
    if strcmp(filtselect, 'd')
        Tlow = Tlow_def;
        Thigh = Thigh_def;
    elseif strcmp(filtselect,'c')
        Tlow = input('Low cut? ');
        Thigh = input('High cut? ');
    elseif strcmp(filtselect, 'n');
        Tlow = [];
        Thigh = [];
    elseif strcmp(filtselect, 'q')
        break
    else
        disp('Skipping channel')
        continue
    end
    
    zoomwin = input('Enter time window for zoom ([min max]) : ');
    % Will see if this bit works...
    plotw_rs(w3(ii),isrtby,iabs,0,tmk,Tlow,Thigh,pmax,iintp,inorm,tlims,nfac,azcen,iunit,0);
    xlim(zoomwin);
    [tpic,~] = ginput();
    cel = get(w3(ii),'DIST')/tpic;
    
    % Output as Struct
    eval(['Pickss.' get(w3(ii),'station') '_' get(w3(ii),'channel') '= [get(w3(ii),''DIST'') tpic cel];']);
    % Ouput as Cell array
    Picks{ii,1} = ([get(w3(ii),'station') '_' get(w3(ii),'channel')]);
    Picks{ii,2} = (get(w3(ii),'DIST'));
    Picks{ii,3} = (get(w3(ii),'AZ'));
    Picks{ii,4} = (tpic);
    Picks{ii,5} = (cel);
    % -------
    close(gcf)
end

clear w3 Tlow_def Thigh_def Tlow Thigh filtselect indic statselect seismos...
    tpic cel
    