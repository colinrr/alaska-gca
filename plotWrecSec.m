function hf = plotWrecSec(w,ampnorm,timecut,shiftFrac,evT,ctype,cmap)
%        hf = plotWrecSec(w,ampnorm,timecut)
%           % Ampnorm = 0: keep raw amplitudes [defualt]
%                       1: normalize amplitudes to 1
%             timecut = 0/1: cut plotted time series to window around arrival
%                           range
%             shiftfrac = fraction
%             evT       = optional event time to plot
%             ctype     = field in waveform to color plotted waveforms by
%             cmap      = colormap to use
% Plot distance-spaced record section of waveforms
%
% C Rowell Jun 2017

if nargin<2
    ampnorm = 0;
end
if nargin<3
    timecut = 0;
end
if nargin<4
    shiftFrac = 0.5;
end
if nargin<5
    evT = [];
end
if nargin<6
    ctype = [];
end
if nargin<7
    cmap = 'hsv';
end

%% Pre-calc spacings
% fractional spacings
D = get(w,'EventDistance');
Dn = (D - min(D))/(max(D) - min(D));

% Grab only unique stations for now, see what comes up
if numel(w)~=numel(unique(D))
    [D,ia,~] = unique(D);
    Dn = Dn(ia);
    w = w(ia);
end
Nw = numel(w);

% Get colors if ctype
if ~isempty(ctype)
    cparam = get(w,ctype);
    [my_cmap,clims] = get_colours(ctype,cparam,cmap);
end

% Set min separation equal to max data value, for now
% Get/set t limits, normalization, trace spacing
% dat = get(w,'data');
dmax = zeros([Nw,1]);
tgate0 = dmax;
tgate1 = dmax;
for k = 1:Nw
    % Arrival window
    if isfield(w,'EventArrivalRange')
        tgate = get(w(k),'EventArrivalRange'); 
        tgate0(k) = tgate(1); tgate1(k) = tgate(2);
        
        % Extract time window
        if timecut
            dt = (tgate1(k) - tgate0(k))*0.06;
%             tcut0 = datestr()
            w(k) = extract(w(k),'TIME',tgate0(k)-dt,tgate1(k)+dt);
        end
    end
    
    dat{k} = get(w(k),'data');
    % Normalize amplitudes
    if ampnorm
        dat{k} = dat{k}/max(abs(dat{k}));
    end
    
    % Get data max
    dmax(k) = max(abs(dat{k}));
    
end

% delDmin = max(dmax)*shiftFrac;
% dDn = diff(Dn);
% Dadjusted = Dn*(delDmin/min(dDn(dDn>0)));

% New adjustment
delDmin = max(dmax)*shiftFrac;
dD = diff(D);
dDmin = min(dD(dD>0));
conversionFac = dDmin/delDmin;


figure('position',[100 100 1050 800])
ax = tightSubplot(1,1,1,[],[],[0.065 0.01 0.01 0.12]);
hold on
labels_st = cell([Nw 1]);
labels_ch = labels_st;
labels_D  = labels_st;
for k = 1:Nw
    t0   = get(w(k),'start');
    t1   = get(w(k),'end');
    freq = get(w(k),'freq');
    nd   = numel(dat{k});
    st   = get(w(k),'ChannelTag');
%     st   = strjoin({st.network,st.station,st.location,st.channel},'.');
%     labels_st{k} = sprintf('%s.%s\newline%s',st.network,st.station,st.channel);
    labels_D{k} = sprintf('%.1f',D(k));
%     labels_st{k} = {sprintf('%s.%s',st.network,st.station),st.channel};
    labels_st{k} = sprintf('%s.%s',st.station,st.channel);
%     labels_ch{k} = st.channel;
    % Timestep in datenum format
    dtd  = datenum(0,0,0,0,0,1/freq);
    
   % Create time vector
    tw       = linspace(t0,t1,nd);
    
    % Adjust data amplitude to fit with distance plot
    
    
    % Default distance across x
%     plot(dat{k}+Dadjusted(k),tw,'k')
    dd = dat{k}*conversionFac + D(k);
    if ~isempty(ctype)
        plot(dd,tw,'color',my_cmap(k,:))
    else
        plot(dd,tw); hold on;
    end
    
    % Now plot detections if they exist
    if isfield(w(k),'detection')
        dobj = get(w(k),'detection');
        for l = 1:numel(dobj.cobj)
            dtime = gettimerange(dobj.cobj);

            if ~isempty(dtime)
                ti = logical((tw>dtime(1)) .* (tw<dtime(2)));
                plot(dd(ti),tw(ti),'r');
            end
        end
    end
end
% Plot arrival window
% plot(Dadjusted,tgate0,'--','color',[0.5 0.5 0.5])
% plot(Dadjusted,tgate1,'--','color',[0.5 0.5 0.5])
plot(D,tgate0,'--','color',[0.5 0.5 0.5])
plot(D,tgate1,'--','color',[0.5 0.5 0.5])
if ~isempty(evT)
    plot(0,evT,'+','color',[0.5 0.5 0.5])
end

if ~isempty(ctype)
    c = colorbar;
    colormap(cmap)
    caxis(clims)
    ylabel(c,ctype);
end

Dt = D;
% Temporary fuck around to fix Redoubt labels -----
% Dt(5) = mean(Dt(5:6));
% Dt = Dt([1:5 7:end]);
% labels_st{5} = ''; %sprintf('%s, %s',labels_st{5},labels_st{6});
% labels_st = labels_st([1:5 7:end]);
% labels_D(5:8) = {''};
% -----

xl = xlim; dx = diff(xl)*0.04;
xlim([xl(1)-dx xl(2)+dx]); xl = xlim;
set(gca,'YDir','reverse')
set(gca,'XAxisLocation','top')
set(gca,'Color',[0.9 0.9 0.9]) % Color adjust to avoid yellow/white
datetick('y','HH:MM:SS')
set(gca,'Xtick',D); %unique(Dadjusted))
% X labels
Dnf = get(gca,'XTick');
Dnf = (Dnf-xl(1))/(xl(2)-xl(1)); % Normalized positioning
fs = 8;
set(gca,'XTickLabel',labels_D,'fontsize',fs)

axis tight
xlim(xlim+[-0.03 0.03]*diff(xlim))
ylim(ylim+[-0.01 0]*diff(ylim))
yl = ylim;

text(Dt,ones(size(Dt))*(yl(1)-diff(ylim)*0.04),labels_st,'Rotation',90,...'Units','normalized',...
    'HorizontalAlignment','left','VerticalAlignment','middle','fontsize',fs)
end

function [my_cmap,clims] = get_colours(ctype,param,cmap);
    if strcmp(ctype,'EventAzimuth')
        clims = [0 360];
    else
        clims = [min(param) max(param)];
    end

    cmap = eval([cmap '(100)']); % Get initial colours
%     cmap = [cmap flipud(cmap)];  % Double and wrap around?
    pline = linspace(min(clims),max(clims),size(cmap,1));
    
    my_cmap = interp1(pline,cmap,param);
end
