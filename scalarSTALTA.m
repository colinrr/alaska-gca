function w = scalarSTALTA(w,fband,det_params);
% Function that runs STA/LTA assuming waveform contains pre-processed
% fields from multi-taper spectrogram
%       w          = waveform object
%       fband      = frequency band of interest for computing scalar function
%       det_params = sta/lta detection params

Nw = numel(w);
wS = w;
def_pad = 30; % seconds
scalar_mode = true;
lta_mode = 'frozen';

pad = time2datenum(def_pad,'seconds');
% Extract arrival range + pad

fprintf('\nRunning STA/LTA detection on %i waveforms...\n',Nw)
for k = 1:Nw
    ch = get(w(k),'channeltag');
    fprintf('\t%s\n',ch)
    mt = get(w(k),'multiTaperParams');
    f  = get(w(k),'fmt');     % Multitaper frequency vector
    freq = get(w(k),'freq');  % Waveform sampling freq
    pxx  = get(w(k),'pxxmt'); % Power spectra
    tmt  = get(w(k),'tmt');   % time, multitaper

    tlim = get(w(k),'eventarrivalrange');
    t0 = tlim(1) - pad;
    t1 = tlim(2) + pad;
    
    wS(k) = extract(wS(k), 'TIME', t0, t1);
    
%     if scalar_mode
        fi  = logical((f>fband(1)).*(f<fband(2)));
        ti  = logical((tmt>t0) .* (tmt<t1));
        Nf  = numel(fi);
        Sft = exp(1/Nf*sum(pxx(fi,ti),1));
    if scalar_mode
        wS(k)  = set(wS(1),'data',Sft,'freq',freq/mt.dt,'units','');
    end

        [cobj,sta,lta,sta_to_lta] = Detection.sta_lta(wS(k), 'edp', det_params, ...
    'lta_mode', 'frozen');
    set(gcf,'name',string(ch))

    det.params = det_params;
    det.fi = fi;
    det.Nf = Nf;
    det.scalar = Sft; % Scalar function
    det.cobj = cobj; % Catalog object
    det.sta  = sta;  % sta valu
    det.lta  = lta;  % lta value
    det.sta2lta = sta_to_lta; % sta-lta ratio
    det.ScalarUnits = freq/mt.dt;
    
    w(k) = addfield(w(k),'Detection',det);
%     w(k) = addfield(w(k),'detScalar',Sft);
%     w(k) = addfield(w(k),'detScalarUnits',freq/step);
    
    
%     w(k) = addfield(
end