function[w_new,idx,times] = quickgrab(w,station_list,pickmode)
% [w_new,idx,times] = quickgrab(w,station_list,pickmode)
    % Mode = 'wav'/'spec'
    %
    % OUT: w_new - grabbed waveforms
    %      idx - index of grabbed forms in original waveforms
    %      times - extraction times

if or(nargin<2,isempty(station_list))
    ch = get(w,'ChannelTag');
    station_list = {ch.station};
end
if nargin<3
    pickmode = 'wav';
end


Nw = numel(w);
Ns = numel(station_list);
w_new = w;
delk = [];%zeros(Nw-Ns,1);
disp('Manual pick of signals to extract...')

idx = [];
times = [];
if strcmp(pickmode,'spec')
    f1 = figure;
end
for k = 1:Nw
    ch = get(w_new(k),'channeltag');
    
    if any(strcmp(station_list,ch.station))
        pxx = get(w_new(k),'pxxmt');
        fmt = get(w_new(k),'fmt');
        tmt = get(w_new(k),'tmt');

        %% Plot  in wav or spec mode
        if strcmp(pickmode,'wav')        
            plot_panels(w_new(k))
            if isfield(w(k),'EventArrivalRange')
                trange = get(w_new(k),'eventarrivalrange');
                trange = datenum2time(trange - get(w_new(k),'Start'),'seconds');
            end
            hold on
            plot([1; 1]*trange',[1 1].*ylim','--','color',[0.5 0.5 0.5])
        elseif strcmp(pickmode,'spec')
%             figure(f1)
            clf
            imagesc(tmt,fmt,pxx)
            if isfield(w(k),'EventArrivalRange')
                trange = get(w_new(k),'eventarrivalrange');
            end
            hold on
            plot([1; 1]*trange',[1 1].*ylim','--','color',[0.5 0.5 0.5])
            set(gca,'YDir','normal')
            datetick('x','HH:MM:SS')
        else
            flargh
        end
        set(gcf,'position',[100 100 1000 200])
        
        %% Pick em
        [tt,~] = ginput(2);
        if strcmp(pickmode,'wav')
            tt = get(w_new(k),'start') + time2datenum(tt,'seconds');
        end
        
        
        %% Extract waveform
        w_new(k) = extract(w_new(k),'TIME',tt(1), tt(2));
        % Extract spectrogram
        ti  = logical((tmt>=tt(1)) .* (tmt<=tt(2)));
        pxx = pxx(:,ti);
        tmt = tmt(ti);
        w_new(k) = set(w_new(k),'pxxmt',pxx,'tmt',tmt);

        idx = [idx k];
        times = [times; tt'];
    else
        delk = [delk; k];
    end
    close
end

w_new(delk) = [];