% A quick synthetic test for pca signals
clear; %close all
%% SIGNAL PARAMS
Asig   = 900; % Set signal amplitude
SNR    = 900/130; 

fsig   = 4; % Hz - dominant signal frequency
tau    = 6;  % Signal e-folding time in seconds
t0     = 100; % Signal start time in seconds

freq   = 50; % Sampling frequency
sigdur = 100; % Length of time for building signal
env_t  = 90;  % base envelope period)
dur    = 600; % total duration in seconds

%% PROCESSING PARAMS

% Multi-taper Spectrogram properties
MTnw        = 3; % Time-bandwidth product
MTnfft      = 256;
MTwlen      = 256;
MTfoverlap  = 0.9;
MTtlims     = [];
MTfband     = [];%[2 10];

plotMTspecs = 0;

% PCA mode - 'raw', 'norm', 'normshift'
fbands = {[],[2 10],[18 25]};% [2 10];
pca_mode = 'normshift';
pcview   = [1 2 3];

%% DO THE THING

N = dur*freq+1;
% Create time vector
t = linspace(0,dur,N);
tsig = linspace(0,sigdur,sigdur*freq+1);

% Create sinusoid
sinusoid = Asig*sin((2*pi*fsig)*tsig);

% Create decay sinusoid
sin_decay = sin(2*pi*(1/env_t)*tsig);
% Create decay exponential
exp_decay = exp(-tsig/tau);
% Full decay 
decay = sin_decay.*exp_decay;
decay = decay/max(abs(decay));

% Combine for decaying signal 
base_signal = sinusoid.*decay;
signal = zeros([1 N]);
signal(t0*freq:t0*freq+sigdur*freq) = base_signal;

% Create noise
noise = Asig/SNR*randn(1,N);

% Combine signal and noise
data = signal + noise;
% data = noise;

% Create waveform object
wt = waveform('my.foo..bar',freq,0,data,'m/s'); 

% wt = extract(wt,'INDEX',90*50,140*50);

% Run MTspecs
wt = wavMTspec(wt,MTwlen,MTfoverlap,MTnw,MTnfft,MTtlims,MTfband,plotMTspecs,6);



% Run PCA
singleWavPca(wt,fbands,pca_mode,pcview)

%% Helpful plots
figure
% % plot(tsig,sinusoid)
% plot(tsig,decay)
% plot(t,signal)
plot(t,data)
