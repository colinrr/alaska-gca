%% Svpectral analysis of waveforms

%!!!! Prob only works for a single station and channel right now...
%close all

% Extract stations and time windows as needed
sta = 'FOSS';
chan = 'BDF';

ifilt = 0;
pspec =1;
    fmin = 0;
    fmax = 3;
    logplot = 0;
timepad = [500 300];

%wSKN = w([10 31 55]);

% Select which station set to use
wc = w(find(strcmp(get(w,'STATION'),sta)));
wc = wc(find(strcmp(get(wc,'channel'),chan)));

% How to select a start time? 
t0 = get(wc(1),'start');

 twin = [500 700]; %For Fourpeaked 
% twin = [320 360]; % For BGL airwave
% twin = [30 250];  % For DFR airwave


tcuts = t0 + twin/spdy;
datestr(tcuts)

% Plot waveform

wc = demean(wc); 
wc = detrend(wc);

wf = extract(wc,'TIME',tcuts(1)-timepad(1)/spdy,tcuts(2)+timepad(2)/spdy);
yset = [-max(abs(wf)) max(abs(wf))];

figure
set(gcf,'position',[40 200 900 900])
for i = 1:length(wf)
%    subplot(length(wf),1,i)
    subplot(2,1,2)
    set(gca,'position',[0.12 0.1 0.84 0.24])
    plot(wf(i)) 
    axis([0  (twin(2)-twin(1))+sum(timepad) yset(1) yset(2)])
    hold on
    plot(timepad(1)*[1 1], yset,'--r','LineWidth',3)
    plot((timepad(1)+twin(2)-twin(1))*[1 1], yset,'--r','LineWidth',3)
    set(gca,'FontSize',16)
    ylabel('Counts')
    end

wc = extract(wc,'TIME',tcuts(1),tcuts(2));



% figure; plot(wc);



% Filter


if ifilt
% specify bandpass filter
% YOU WILL NEED TO CHANGE THE LIMITS HERE
T1 = .1;   % minimum period
T2 = 1;   % maximum period
f1 = 1/T2;
f2 = 1/T1;
npoles = 2;
f = filterobject('B',[f1 f2],npoles);

wc = fillgaps(wc,'meanAll');
%w = taper(w,0.05);
w0 = wc;               % save a copy for later
wc = filtfilt(f,wc);
figure
for i = 1:length(wc)
    subplot(length(wc),1,i)
    plot(wc(i))
end
end

%% Compute Fourier Transform

if pspec

for i = 1:length(wc);
wd = get(wc(i),'data');
nd = length(wd);
taper = tukeywin(nd,1);     % matlab function
wd = wd.*taper;
wc(i) = set(wc(i),'DATA',wd);
fNyq = get(wc(i),'NYQ');

% fname = 'fftcan3';
% if ~exist([fname '.mat'],'file')
     tic, wc(i) = wf_fft.compute(wc(i)); toc
%     save(fname,'w');
% else
%     load(fname);
% end
f    = get(wc(i),'fft_freq');
wAmp = get(wc(i),'fft_amp');
wPhs = get(wc(i),'fft_phase');

eval(['Fw_' get(wc(i),'channel') '  = [f,wAmp,wPhs];']);
end;

%figure
hold off
for k = 1:length(wc);
%    subplot(ceil(length(wc)),1,k) % Assuming there are 4 or less channels...
    subplot(2,1,1)
    F = eval(['Fw_' get(wc(k),'channel')]);
    set(gca,'position',[0.12 0.46 0.84 0.5])
    if logplot
        loglog(F(:,1),abs(F(:,2)))
    else
        plot(F(:,1),abs(F(:,2)))
    end
%    set(gcf,'position',[40 200 1100 700])
    set(gca,'FontSize',16)
    xlim([fmin fmax]);
    %axis tight
    grid on
    title(['Raw spectrum for ' get(wc(k),'station') ' ' get(wc(k),'channel')])
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
end
end