function wavspec(nfft,overlap,fmax,dblims,w,plotpos);

% Rockin the spectrogram
%       nfft    = length of fft window in samples
%       overlap = amount of window overlap in samples
%       fmax    = max frequency for plotting, ya get it?
%       dblims  = decibel amplitude limits for plotting eg [40 80]
%       w       = waveform
%       plotpos = vector of graph position [xmin ymin xwidth yheight]
% setup



%  spectral object

speck = spectralobject(nfft,overlap,fmax,dblims);

figure
set(gcf,'position',plotpos)
specgram(speck,w);


end