% Let's run a spectral comparison to vet my shit
clear; close all
% homedir = activate_base;
project

ofile    = 'Cleveland_2_brutal-PCA.mat';
oMat = fullfile(paths.wav,ofile);

% Chosen waveform
wi = 3; % IKER

% Time extract?
t0 = 7.353585459444994e05;
tlen = 512;
% Background time
tbg = 7.353585451911065e05;
bglen = 512;

% PWelch properties
p.wintype = 'hamming';
p.spmode = 'psd';
p.wlen   = 256;
p.nover  = 230;
p.foverlap = 0.5;
p.nfft = 256;

% Spectrogram properties
s.wintype = 'hamming';
s.spmode  = 'psd';
s.wlen    = 512;
s.nover   = 400;
s.nfft    = 512;

% Multi-taper Spectrogram properties
m.nw        = 4; % Time-bandwidth product
m.nfft      = 512;
m.wlen      = 512;
m.foverlap  = 0.9;
m.tlims     = [];
m.fband     = []; %[2 10];


%% load em up
load(oMat)

% Select the right waveform
w = w(3);
wf = w;
if ~isempty(t0)

    w = extract(wf,'TIME&SAMPLES', t0, tlen);
end
if ~isempty(tbg)
    wb = extract(wf,'TIME&SAMPLES',tbg,bglen);
    datb = get(wb,'data');
    tdatb = linspace(get(wb,'Start'), get(wb,'End'), numel(datb));
end

datf = get(wf,'data');
tdatf = linspace(get(wf,'Start'), get(wf,'End'), numel(datf));
dat = get(w,'data');
freq = get(w,'freq');
N = numel(dat);
tdat = linspace(get(w,'Start'), get(w,'End'), N);


%% Pre-filtering?

%% PWelch

% Single signal
p.f = linspace(0,freq/2,p.nfft/2+1);
p.win = window(p.wintype,p.wlen);
% p.nover = fix(length(p.win)/2);
% [p.pxx,p.f] = pwelch(dat,p.wlen,p.nover,p.f,freq,p.spmode); % Default windowing
[p.pxx,p.f] = pwelch(dat,p.win,p.nover,p.nfft,freq,p.spmode);
% p.f   = linspace(0,freq/2,length(p.pxx));

[p.pbg,p.fbg] = pwelch(datb,p.win,p.nover,p.nfft,freq,p.spmode); % Default windowing

% Spectrogram


%% MATLAB Spectrogram
[s.s,s.f,s.t] = spectrogram(datf,s.wlen,s.nover,s.nfft,freq);

%% Multitaper

% Single signal
% m.f = linspace(0,freq/2,m.nfft/2+1);
[m.pxx,m.f] = pmtm(dat,m.nw,m.nfft,freq);
[m.pbg,m.fbg] = pmtm(datb,m.nw,m.nfft,freq);

% Spectrogram
wmt = wavMTspec(wf,m.wlen,m.foverlap,m.nw,m.nfft,m.tlims,m.fband,true);
%% Plot
hndls = [];
lbls  = {};

n = 2;
figure

tightSubplot(n,1,1,[],[],[],[],[0.5 ones(1,n-1)]);
plot(tdatf,datf,'color',[0.5 0.5 0.5])
hold on
plot(tdatb,datb,'k')
plot(tdat,dat,'r');
datetick('x','HH:MM:SS')
axis tight

tightSubplot(n,1,2,[],[],[],[],[0.5 ones(1,n-1)]);
semilogy(p.fbg,p.pbg,'--b')
hold on
semilogy(m.fbg,m.pbg,'--r')
% plot(f,pxw)
hndls(1) =semilogy(p.f,p.pxx,'b');
lbls{1}  = 'PWelch';
hndls(2) = semilogy(m.f,m.pxx,'r');
lbls{2}  = 'PMTM';
xlabel('Hz')
ylabel(p.spmode)
legend(hndls,lbls)

% Spectrogram plots
figure
spectrogram(datf,s.wlen,s.nover,s.nfft,freq,s.spmode,'yaxis');