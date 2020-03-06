% Grab mat files kicked out by obspy, load em up as waveforms

homedir = '/Users/crrowell/';
datadir = fullfile(homedir,'data/alaska-gca/redoubt-2-spurr-network/');

% wfile = 'red2-spurrNW-%s%02i.sac';
wfile = 'red2-spurrNW-%s.*.mat';
wruns = {'raw'};%,'no-response','highp','bandp'};

for i = 1:length(wruns)
    wrun = fullfile(datadir,sprintf(wfile,wruns{i}));
    d = dir(wrun);
    disp(sprintf('%d trace matfiles found\n',length(d))) 
    
    for c=1:length(d)
        tr=load(fullfile(datadir,d(c).name));
        disp(sprintf('Loaded trace %d',c))
        scnl(c)=scnlobject(tr.station, tr.channel, tr.network, tr.location);
        snum = datetime(strrep(tr.starttime,'T',' '),'TimeZone','UTC','InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSSZ');
%         snum=(tr.starttime.timestamp/86400)+datenum(1970,1,1);
        w(c)=waveform(scnl, tr.sampling_rate, snum, tr.data);
%         delete(d(c).name);
    end
    eval(sprintf('w_%s = w;',wruns{i}))
    clear w
end