% Redoubt waveform work


% Broad first swath of stations

% In getwaveform_input !!!!!!!!!!!!!1

% if iex==0
    Redoubt_events
    originTime = t0;
    %originTime = datenum('2009/03/023 07:01:52');
    elat = 60.4888278;
    elon = -152.7643722;
    edep_km = 0;
    eid = [];
    mag = [];       % plotting only
    
    % see list of channel options below
    chan = {'EHZ','BHZ','BHN','BDF','BDL'};
    %chan = {'LHZ','LHE','LHN','LH1','LH2'};
    
    duration_s = 25*60;      % does NOT include time shift
    tshift = 0;
    axb = [0 300];    % lon-lat bounding box for stations (or [] or [dmin dmax])
    cutoff = [];                % cutoff frequencies for bandpass [low high]
    samplerate = [];            % in Hz
    % for plotting only:
    T1 = []; T2 = [];          % bandpass for plotting
    
% GIT 'ER GOIN'

run_getwaveform

% database:       [1 4]
% origin time:       0
% instuemnt resp:    1
% plot:              1

  tshift1 = get(w,'DIST')/.3;
plotw_rs(w,isort,iabs,tshift1,tmark,[1/5],[1/20],pmax,iintp,inorm,tlims,nfac,azcen,iunit,0);

  
%% Whittling shit down or whatever

%w2 = w([6 8 10 12 18 27 28 31 42 51 52 55]);

%  SPURR NETWK
%w2 = w([11 14 17 18 19 20 21 22 51 86 101 66 67 68 70]);
%w2 = w([14 18 20 67 19]);
%w2 = w([68 86 101 11 21]);
w2 = w([22 66 17 51 68 70]);
%w2 = w(find(get(w,'DIST')>275&get(w,'DIST')<300));%&get(w,'AZ')>0&get(w,'AZ')<45));

% ILIAMNA
%w2 = w([30:34]);

% OTHER PICKS
%pic = [53 54 55 123 126 139 142];  % 75<r<100 excluding SPURR
%w2 = w(pic);

plotwavspec