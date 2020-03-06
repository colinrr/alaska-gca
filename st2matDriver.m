% stream2waveformDriver

homedir = '/Users/crrowell/';

datadir = fullfile(homedir,'data/alaska-gca/redoubt-2-spurr-network/sac/');
st2matpth = '/Users/crrowell/Documents/MATLAB/GISMO/contributed/+obspy/stream2matfile.py';

wfile = 'red2-spurrNW-%s%02i.sac';
wruns = {'raw'}%,'no-response','highp','bandp'};
trN   = 5;

for i = 1:length(wruns)
    wrun = wruns{i};
    for k = 1:trN
        [w,scnl] = stream2waveform('python',st2matpth,sprintf(wfile,wrun,k));
        plot(w)
    end
end
