%% Adding a section to look at the response removal with multitape spec

% Extract arrival range, plot up spectra
we = w;
% for l = 1:numel(w)
%     tt = get(w,'EventArrivalRange');
%     we(l) = extract(w(l), 'TIME', tt(1), tt(2));
% end
% plot_spectrum(we);



%% function[pxx,f,t] = wavMTspec(w,nfft,foverlap,nw)
% Grab BGL and run some PCA

% Running direct off GISMOgetData for Spurr network

d  = get(w(1),'data');
t0 = get(w(1),'start');
freq = get(w(1),'freq');

nfft = 512;
foverlap = 0.9;
nw = 4;
flims = [0 20];
fband = [8 20];

% STA/LTA
sta_win    = 2.0;
lta_win    = 20.0;
thresh_on  = 3;
thresh_off = 1.5;
min_dur    = 2.0;
plotflag   = 1;

detection_params = [sta_win lta_win thresh_on thresh_off min_dur];

%%
dtd = datenum(0,0,0,0,0,1/freq); % Time step in datenum format
n   = numel(d);


% Pull signal apart and put into matrix form for a crude multitaper
step  = round(nfft*(1-foverlap));
i0    = 1:step:(n-nfft);
i1    = nfft:step:n;
nwins = numel(i0);
% nwins = floor((n-nfft)/step);
% i0   = 1:step:(nwins-1)*nfft; % Window start indices
% i1   = nfft:step:nwins*nfft;  % Window stop indices

% Window-centered time
t  = (i0-1 + nfft/2)*dtd + t0;
% t   = t0:dtd:t0+dtd*n-1;

m    = zeros(nfft,nwins);
for k = 1:nwins
    m(:,k) = d(i0(k):i1(k));
end

% Get multitaper spectra
[pxx,f] = pmtm(m,nw,nfft,freq,flims);

% Modified spectrogram
pxs = (log10(pxx(:,2:end)) - log10(pxx(:,1:end-1))).*log10(pxx(:,2:end));
ts  = t(2:end);

% Convert to dB?
pxdb = 10*log10(abs(pxx+eps))+94;   %convert to Pa2/Hz*db

% Scalar function
fi  = logical((f>fband(1)).*(f<fband(2)));
Nf  = numel(fi);
Sft = exp(1/Nf*sum(pxs(fi,:),1));
wS  = set(w(1),'data',Sft,'freq',freq/step,'units','');

% STA/LTA --------
% Filtered data
[cobj,sta,lta,sta_to_lta] = Detection.sta_lta(wf(1), 'edp', detection_params, ...
    'lta_mode', 'frozen');
% Scalar function
[cobjS,staS,ltaS,sta_to_ltaS] = Detection.sta_lta(wS, 'edp', detection_params, ...
    'lta_mode', 'frozen');


figure()
imagesc(t,f,pxdb)
% ttic = round
colormap('hot')
set(gca,'YDir','normal')
datetick('x','HH:MM:SS','keeplimits','keepticks')
caxis([80 140])

%% PCA
pn = size(pxx,1); pm = size(pxx,2);
% Normalized raw pxx
pxxSum = sum(abs(pxx),1);
pxxN   = pxx./repmat(pxxSum,[pn,1]);
% Normalized dB pxx
pxdBSum = sum(abs(pxdb),1); 
pxdbN   = pxdb./repmat(pxdBSum,[pn,1]);
% Median shifted
pxxNM   = pxxN -  repmat(median(pxxN,1), [pn,1]);
pxdbNM  = pxdbN - repmat(median(pxdbN,1),[pn,1]);

% Check spectral shapes
% Ground-wave index; airwave index;
%%
% PCA on PSD (db)
t_ind1 = 550:650; % Stuff on either side of airwave
% t_ind1 = 572:600; % Airwave only
f_ind  = f<=20;
p_ins = {pxdb, pxdbN, pxdbNM};
p_tit = {'Raw Spec','Normalized','Normalized and shifted'};
% [Eigvecs, PC's, eigvals, tsq, % explained, mean_est] = 
% [cDB, scoreDB, latDB, tsqDB, expDB, muDB] = pca(pxdb);
% PCA on normalized PSD (db)
figure('Position',[100 100 1200 700]);
nn = numel(p_ins);
for k = 1:nn
    p_in = p_ins{k};
    p_in = p_in(f_ind,t_ind1)';
    t_in = t(t_ind1);
    f_in = f(f_ind);
    [eVecs, PCs, eVals, tsq, pcnt_var, mu] = pca(p_in);
    
    subplot(nn,3,k)
    imagesc(t_in,f_in,p_in'); set(gca,'YDir','Normal')
    colormap('hot')
    datetick('x','HH:MM:SS','keeplimits')
    xlabel('Time')
    ylabel('Freq')
    title(p_tit{k})
    caxis(caxis*1.05)
    caxis(caxis*1.1)
    
    p90 = min(find(cumsum(pcnt_var)>=90));
    subplot(3,nn,k+nn)
    plot(pcnt_var,'.-')
    xlabel('mode')
    ylabel('% variance')
    title(sprintf('p90 = %i',p90))
    xlim([0 20])
    
    subplot(3,nn,k+2*nn)
    plot(PCs(:,1),PCs(:,2),'.')
    xlabel('PC 1')
    ylabel('PC 2')
    title('PCs? Idunfuckinknow')
    
    % This will be the one
end
%%
% p_in = pxdbNM(:,550:650);
% % p_in = pxdbNM(:,572:600);
% [cN, scoreN, latN, tsqN, expN, muN] = pca(p_in');
% figure
% subplot(2,1,1)
% imagesc(p_in); set(gca,'YDir','Normal')
% subplot(2,1,2)
% plot(expN,'.-k')
% xlim([0 30])

% PCA on normalized and shifted (db)

% figure
% subplot(6,1,1)
% plot(f,pxx(:,speci))
% title('Original spectra')
% subplot(6,1,2)
% plot(f,pxdb(:,speci))
% title('Original spectra (dB)')
% subplot(6,1,3)
% plot(f,pxxN(:,speci))
% title('Normalized Spectra')
% subplot(6,1,4)
% plot(f,pxdbN(:,speci))
% title('Normalized Spectra (dB)')
% subplot(6,1,5)
% plot(f,pxxNM(:,speci))
% title('Normalized Spectra, shifted')
% subplot(6,1,6)
% plot(f,pxdbNM(:,speci))
% title('Normalized Spectra (dB), shifted')
