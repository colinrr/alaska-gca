function plotMTspec(W,tlims,fband,maxrows)
% plotMTspec(W)
%   Plot multi-taper spectrograms, assuming input waveform, W, has been run
%   through "wavMTspec"
%       tlims   = show only times between [tlims(1) tlims(2)]
%       fband   = plot only frequencies within [fband(1) fband(2)]
%       maxrows = max spectrograms per figure (for multi-channel waveforms)
%  C Rowell, Jun 2017

if nargin==1
    tlims = [];
end
if nargin<3
    fband = [];
end
if nargin<4
    maxrows = 6;
end

Nw = numel(W);

Nrows = min([Nw maxrows]);
numfigs = ceil(Nw/maxrows);
hndls=zeros(numfigs,1);
v = 1:maxrows:Nw;

for k = 1:Nw
    
    if ~isfield(W(k),'pxxmt')
        error('Waveform does not appear to have multi-taper spectral information!')
    else
        d    = get(W(k),'data');
        t0   = get(W(k),'start');
        t1   = get(W(k),'end');
        freq = get(W(k),'freq');
        nd   = numel(d);
        st   = get(W(k),'ChannelTag');
        st   = strjoin({st.network,st.station,st.location,st.channel},'.');
        tw   = linspace(t0,t1,nd); % Full signal time vector

        t    = get(W(k),'tmt');
        f    = get(W(k),'fmt');
        pxx  = get(W(k),'pxxmt');
    end
    
    if isempty(tlims)
        tlim = [min(tw) max(tw)];
    else
        tlim = tlims;
    end
    if isempty(fband)
        fband = [min(f) max(f)];
    end
    if any(k==v)
        figure
        figpos = get(gcf,'Position');
        figpos(1) = 100+(find(k==v)-1)*figpos(3);
        figpos(4) = 100+80*Nrows;
        set(gcf,'Position',figpos)
    end
    thisRow = mod(k,maxrows);
    if thisRow==0; thisRow=maxrows; end

    wav2spec = [1 2]; % Plot proportions
    pads = [];%[0.3 0.04 0.1 0.08];
    ax(1)=tightSubplot(Nrows*2,1,2*thisRow-1,[],0,pads,[],wav2spec);
    plot(tw,d,'k')
    hold on
    if isfield(W(k),'EventArrivalRange')
        tmark = get(W(k),'EventArrivalRange');
        plot([tmark tmark]',[ylim' ylim'],'--','color',[0.3 0.3 0.3],'LineWidth',2)
    end
    datetick('x','HH:MM:SS','keeplimits')
    set(gca,'XTickLabel',[],'YTickLabel',[])
    xlim(tlim)
    ax(2)=tightSubplot(Nrows*2,1,2*thisRow,  [],0,pads,[],wav2spec);
    imagesc(t,f,pxx)
    hold on
    ylim(fband)
    if isfield(W(k),'EventArrivalRange')
        plot([tmark tmark]',[ylim' ylim'],'--','color',[0.3 0.3 0.3],'LineWidth',2)
    end
    colormap('jet')
    set(gca,'YDir','normal')
    if k==Nw
        datetick('x','HH:MM:SS','keeplimits')%,'keepticks')
    else
        set(gca,'XTickLabel',[])
    end
    text(0.98,0.95,st,'Units','normalized','HorizontalAlignment','right',...
        'VerticalAlignment','top','FontSize',8,'BackgroundColor','w')
    ylabel('Hz') %,'Rotation',0)
%     caxis(caxis*1.2) 
    linkaxes(ax,'x')
end