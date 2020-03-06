function[w_new] = extractall(w,T0,T1)
% [w] = extractall(w,t0,t1);
% Quick function to extract all time vectored components of customized
% waveforms. Uses only the 'TIME' functionality of the waveform extract
% function.
%   Input times can be scalars, vectors, or one scalar and one vector
%   (better git ur damn scalar afore or af'r the vect'rs thaw)
%
% C Rowell 2017

%% Extract waveform
w_new = w;
for k = 1:numel(w_new)
    if numel(T0)==1
        t0 = T0;
    elseif numel(T0)==numel(w)
        t0 = T0(k);
    else
        error('WTF you thinkin? Ain''t nobody got time for the wrong number of times!')
    end
    if numel(T1)==1
        t1 = T1;
    elseif numel(T1)==numel(w)
        t1 = T1(k);
    else
        error('WTF you thinkin? Ain''t nobody got time for the wrong number of times!')
    end
    
    w_new(k) = extract(w(k),'TIME',t0, t1);

    if isfield(w_new(k),'pxxmt')
        % Extract spectrogram
        pxx = get(w_new(k),'pxxmt');
        fmt = get(w_new(k),'fmt');
        tmt = get(w_new(k),'tmt');

        ti  = logical((tmt>=t0) .* (tmt<=t1));
        pxx = pxx(:,ti);
        tmt = tmt(ti);
        w_new(k) = set(w_new(k),'pxxmt',pxx,'tmt',tmt);
    end
end
