clear all; close all
%% Load waveforms
% load ~/Nextcloud/data/alaska-gca/waveforms/Cleveland_30_r300_st_ch_prep_MT_flt.mat

% Run initial grabs of background and signal
% plotWrecSec(w,1,0,0.5)
% plotMTspec(w)

% [wall,idx1,cut_times1] = quickgrab(w,{},'spec');

% Run a second grab, to select signal
% [wsig,idx2,cut_times2] = quickgrab(wall,{},'spec');

% Now get the background from remainder
% wb = extractall(wall,cut_times2(:,2),get(wall,'end'));

% Verify cuts
% plotMTspec(wb)
% plotMTspec(wsig)

% Save file to play with
% savfile = '~/Nextcloud/data/alaska-gca/manual-cut-waveforms/Cleveland_30_Aug17.mat';
% save(savfile)

% NEED TO DO A PROPER RESPONSE CORRECTION

%% Setup params
pcview  = []; %[1 2 3];
pcview2 = [1 2 3];
pcview3 = [1 2];
fbands  = {[]};
pcmode  = 'raw';

ifile = '~/Nextcloud/data/alaska-gca/manual-cut-waveforms/Cleveland_30_Aug17.mat';
load(ifile)

figdir = '~/Nextcloud/data/alaska-gca/figures/iavcei-poster-figs/';
ploti_ok  = [1 2 4];
ploti_ko  = [6 7 9];

%% Run initial PCA passes
pcdat = WavPca(wall,fbands,pcmode,pcview2);
pcBdat = WavPca(wb,fbands,pcmode,pcview2);
tMat = pcdat.eVecs; % Get transformation matrix from full waveform PCA
tMu  = pcdat.mu;

%% Basemap
% project
% numKO = [1 2 3 4 5]; %{ss(numGCA).StationCode}
% numOK = [6 7 8 9 10]; % {ss(numsSeis).StationCode}
% grd      = '~/Nextcloud/data/alaska-gca/figures/map_data/ak_basemap_Cleveland.grd';
% mapfile  = '~/Nextcloud/data/alaska-gca/figures/basemaps/Clev_30_basemap_iavcei.ps';
% stationmap(ss,E,true,mapfile,grd,false)

%% Spectrograms
% wp = extractall(w,get(w(1),'Start'),datenum(2013,5,4,13,24,0));
% plotMTspec(wp([ploti_ok ploti_ko]))
% set(get(gcf,'Children'),'FontSize',14)
% printpdf('Clev_MTspecs',[5.5 6.5],figdir,'inches',400)

%% Plot PCA spaces and get background spectra
Nw = numel(w);
% Plot signal/bg elements in PC space
% Get reconstructed bg spectra
okchans = get(w(1:5),'station');

% Set up figs and colormaps
f1 = figure;
hold on
f2 = figure;
hold on
f3 = figure;
hold on

dnpc = subplot(1,1,1);
cmap = colormap(dnpc,jet(numel(w)));
cmok = colormap(f2,autumn(numel(w)-numel(okchans))); % GCA chans
cmko = colormap(f2,winter(numel(okchans)));  % Seischangs

bg_spec_md = zeros([length(pcBdat(1,1).fmt), length(wb)]); % Median spectra
% wb = plot_spectrum(wb);
leg = cell(Nw,1);
sp_plots = zeros(1,Nw);
fband = fbands{1};
if isempty(fbands{1})
    fi = true(size(get(wall(1),'fmt')));
    fband = [min(get(wall(1),'fmt')) ceil(max(get(wall(1),'fmt')))];
else
    fi = logical((get(wall(1),'fmt')>=fband(1)) .* (get(wall(1),'fmt')<=fband(2)));
end

myleg = cell(1,length(wb));
%     myleg2 = myleg;
myhnd = zeros(1,length(wb));
myhnd2 = myhnd;
myhnd3 = myhnd;

for k = 1:Nw
    % Pull out the essential info
    pxB = get(wb(k),'pxxmt');
    nbg = size(pxB,2);
    pxA = get(wsig(k),'pxxmt');
    fmt = get(wb(k),'fmt');
    tmt = get(wb(k),'tmt');

    fi = logical((fmt>=fband(1)) .* (fmt<=fband(2)));
    fmt = fmt(fi);
    pxB = pxB(fi,:);
    pxA = pxA(fi,:);
    
    % Apply full transformation to signal components
    pcB = (pxB'-repmat(tMu,[size(pxB',1),1]))*tMat;
    pcA = (pxA'-repmat(tMu,[size(pxA',1),1]))*tMat;

    % Reconstruct background spectra from center of each station cluster
    apcBG(k).npc = 10; % all PC background
    apcBG(k).pct = sum(pcdat.pcnt_var(1:apcBG(k).npc));
    [apcBG(k).centers,apcBG(k).reconstructed_spec]...
        = get_cluster_centers_and_reconstruct(ones(size(pcB(:,1))),...
        1,pcB,tMat,tMu,...
        fmt,apcBG(k).npc,tmt,pxB,0,'','','n');

    dotsz = 12;
    circsz = 10;

    % PC space fig, coloured by station and highlighting signal elements
    figure(f1)
   
    scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,cmap(k,:),'Marker','.');
    myhnd(k) =scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,cmap(k,:),'filled','Marker','o','MarkerEdgeColor',[0 0 0]);
    myleg{k} = get(wb(k),'station');
    % PC space fig, coloured by network (OK vs KO) and highlighting signal
    % elements
    figure(f2) 
    if k==1 % dummy plot to get legend bits
        extra_hnd(1) = scatter3(pcB(1,pcview2(1)),pcB(1,pcview2(2)),pcB(1,pcview2(3)),dotsz,[0.5 0.5 0.5],'Marker','.');
        extra_hnd(2) = scatter3(pcA(1,pcview2(1)),pcA(1,pcview2(2)),pcA(1,pcview2(3)),circsz,[0.5 0.5 0.5],'filled','Marker','o','MarkerEdgeColor',[0 0 0]);
        extra_leg = {'Background','Signal'};
    end
    if ismember(get(w(k),'station'),okchans)
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,'b','Marker','.')
        myhnd2(k) = scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,'b','filled','Marker','o','MarkerEdgeColor',[0 0 0]);
%         cms_count = cms_count+1;
    else
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,'r','Marker','.')
        myhnd2(k) = scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,'r','filled','Marker','o','MarkerEdgeColor',[0 0 0]);
%         cmg_count = cmg_count+1;
    end
    
    % Plot background specs 
    bg_spec_md(:,k) = median(pxB,2);
    leg{k} = get(wb(k),'station');
    figure(f3)
    
    if k==1 % dummy plot to get legend bits
        extra_hnd2(1) = plot(fmt(1:2),bg_spec_md(1:2,k),'color',[0.8 0.8 0.8],'Linewidth',3);
        extra_hnd2(2) = plot(fmt(1:2),apcBG(k).reconstructed_spec(1:2),'color',[0.4 0.4 0.4],'linewidth',1.5);
        extra_leg2 = {'Median','PCA'};
    end
    
    % Set up colors
    Sfrac = 0.4; Vfrac1 = 1.3; Vfrac2 = 0.75;
    col1 = rgb2hsv(cmap(k,:)); col2 = col1;
    col1(2) = col1(2)*Sfrac; col1(3) = col1(3)*Vfrac1; col2(3) = col2(3)*Vfrac2;
    col1(col1>1) = 1.0; col1 = hsv2rgb(col1); col2 = hsv2rgb(col2);
    
    fk_em(k)=plot(fmt,bg_spec_md(:,k),'color',col1,'Linewidth',3);
    sp_plots(k) = plot(fmt,apcBG(k).reconstructed_spec,'color',col2,'linewidth',1.5);
end

figure(f1)
xlabel(sprintf('PC %i',pcview2(1)))
ylabel(sprintf('PC %i',pcview2(2)))
zlabel(sprintf('PC %i',pcview2(3)))
axis equal tight
grid on
ll=legend(myhnd,myleg,'Position',[0.2 0.6 0.1 0.1]);
ll.FontSize = 9;

figure(f2)
xlabel(sprintf('PC %i',pcview2(1)))
ylabel(sprintf('PC %i',pcview2(2)))
zlabel(sprintf('PC %i',pcview2(3)))
axis equal tight
grid on
uistack(myhnd2,'top')
set(gca,'FontSize',16)
view([1 0.7 0.8])
ll2=legend([extra_hnd myhnd2([1 6])],[extra_leg {'Okmok station','Atka station'}],'Position',[0.2 0.6 0.1 0.1]);
ll2.FontSize = 14;
% printpdf('Clev_30_rawPCA_3D_bySignal',[10 8],figdir,'inches',400)

figure(f3)
title(sprintf('Background Spectra Reconstruction, %i PCs, %.1f%% Variance',apcBG(1).npc,apcBG(1).pct))
spec_no = [3 5 8 10];
spec_i  = [ 1 2 4 6 7 9];
set(gca,'FontSize',12)
h=legend([extra_hnd2 sp_plots(spec_i)],[extra_leg2 myleg(spec_i)],'Location','SouthEast');
h.FontSize = 10;
delete(sp_plots(spec_no))
delete(fk_em(spec_no))
% v = get(h,'title');
% set(v,'string',sprintf('Reconstructed spectra\n%i PCs, %.1f%% variance',apcBG(1).npc,apcBG(1).pct));
grid on
axis tight
xlabel('Frequency (Hz)')
ylabel('Amplitude (dB)')
% printpdf('Clev_30_background_spectra',[7 5],figdir,'inches',400)
% Prob need a plot of actual PCs and/or eigenvectors at some point

%% Subtract backgrounds and plot
waR = wall;
for tr = 1:length(waR)
    spec =  get(waR(tr),'pxxmt');
    spec(fi,:) = spec(fi,:)-repmat(apcBG(tr).reconstructed_spec,[1,size(spec,2)]);
    waR(tr) = set(waR(tr),'pxxmt', spec);
end
% plotMTspec(wall)
% plotMTspec(wb_guinea)
pcmode = 'raw';
pcBG_removed = WavPca(waR,fbands,pcmode);
tMatR = pcBG_removed.eVecs; % Get transformation matrix from full waveform PCA
tMuR  = pcBG_removed.mu;

% Remove background specs from wb
wbR = wb;
for tr = 1:length(wbR)
    spec =  get(wbR(tr),'pxxmt');
    spec(fi,:) = spec(fi,:)-repmat(apcBG(tr).reconstructed_spec,[1,size(spec,2)]);
    wbR(tr) = set(wbR(tr),'pxxmt', spec );
end

% Remove background specs from wsig
wsigR = wsig;
for tr = 1:length(wsigR)
    spec =  get(wsigR(tr),'pxxmt');
    spec(fi,:) = spec(fi,:)-repmat(apcBG(tr).reconstructed_spec,[1,size(spec,2)]);
    wsigR(tr) = set(wsigR(tr),'pxxmt', spec );
end

% Set up figs and colormaps
f1 = figure;
hold on
f2 = figure;
hold on

dnpc = subplot(1,1,1);
cmap = colormap(dnpc,jet(numel(w)));
cmok = colormap(f2,autumn(numel(w)-numel(okchans))); % GCA chans
cmko = colormap(f2,winter(numel(okchans)));  % Seischangs

% PC space fig, coloured by station and highlighting signal elements
% Set up colors
Sfrac = 0.6; Vfrac1 = 1.3; Vfrac2 = 1.0;
r1 = rgb2hsv([1 0 0]); % = col1;
r1(2) = r1(2)*Sfrac; %col1(3) = col1(3)*Vfrac1; col2(3) = col2(3)*Vfrac2;
r1(col1>1) = 1.0; r1 = hsv2rgb(r1); % col2 = hsv2rgb(col2);
b1 = rgb2hsv([0 0 1]); b1(2) = b1(2)*Sfrac; b1(col1>1) = 1.0; b1 = hsv2rgb(b1);

f3fs = 12;
% Require exact aspect ratio
asp_rat = 0.530595877103298;
pads = [0.12 0.1 0.12 0.1];
f3 = figure('position',[100 100 1000 1000*asp_rat]);
ax1 = tightSubplot(2,2,1,0.15,0.25);
plot(pcBG_removed.pcnt_var,'.-k','LineWidth',2,'MarkerSize',14)
xlim([0 20])
xlabel(sprintf('Mode (/%i)',numel(pcBG_removed.pcnt_var)))
ylabel('% Variance Explained')
ax2 = tightSubplot(2,2,2,0,0,pads);
ax3 = tightSubplot(2,2,3,0,0,pads);
ax4 = tightSubplot(2,2,4,0,0,pads);

set([ax1 ax2 ax3 ax4],'FontSize',f3fs)
axview = [1 3; 3 2; 1 2];
pcax   = [ax2 ax3 ax4];
for k = 1:Nw
    % Pull out the essential info
    pxB = get(wbR(k),'pxxmt');
    nbg = size(pxB,2);
    pxA = get(wsigR(k),'pxxmt');
    fmt = get(wbR(k),'fmt');
    tmt = get(wbR(k),'tmt');

    fmt = fmt(fi);
    pxB = pxB(fi,:);
    pxA = pxA(fi,:);

    % Apply full transformation to signal components
    pcB = (pxB'-repmat(tMuR,[size(pxB',1),1]))*tMatR;
    pcA = (pxA'-repmat(tMuR,[size(pxA',1),1]))*tMatR;

    % PC space fig, coloured by station and highlighting signal elements
    % Set up colors
    col1 = rgb2hsv(cmap(k,:)); col2 = col1;
    col1(2) = col1(2)*Sfrac; col1(3) = col1(3)*Vfrac1; col2(3) = col2(3)*Vfrac2;
    col1(col1>1) = 1.0; col1 = hsv2rgb(col1); col2 = hsv2rgb(col2);

    figure(f1)
    scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),6,col1,'Marker','.')
    scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,col2,'filled','Marker','o','MarkerEdgeColor',[0 0 0])

    % PC space fig, coloured by network (OK vs KO) and highlighting signal
    % elements
    figure(f2) 
    if ismember(get(w(k),'station'),okchans)
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),10,b1,'Marker','.')
        scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,[0 0 1],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
%         cms_count = cms_count+1;
    else
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),10,r1,'Marker','.')
        scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,[1 0 0],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
%         cmg_count = cmg_count+1;
    end
    
    figure(f3)
     % PC3 (y) vs PC1 (x)
    axview = [1 3; 3 2; 1 2];

    for ax = 1:3
        axes(pcax(ax))
        hold on
        if ismember(get(w(k),'station'),okchans)
            scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,b1,'Marker','.')
            scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[0 0 1],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
    %         cms_count = cms_count+1;
        else
            scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,r1,'Marker','.')
            scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[1 0 0],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
    %         cmg_count = cmg_count+1;
        end
    end
    
  end

% figure(f1)
% xlabel(sprintf('PC %i',pcview2(1)))
% ylabel(sprintf('PC %i',pcview2(2)))
% zlabel(sprintf('PC %i',pcview2(3)))
% axis equal tight
% grid on
% 
% figure(f2)
% xlabel(sprintf('PC %i',pcview2(1)))
% ylabel(sprintf('PC %i',pcview2(2)))
% zlabel(sprintf('PC %i',pcview2(3)))
% axis equal tight
% grid on

    axvec = -200:50:200;
    figure(f3)
    axes(ax2)
    set(gca,'yaxislocation','right');
    ylabel('PC 3')
    axis equal tight
    grid on
    set(gca,'YTick',axvec,'YTickLabel',axvec)
    set(gca,'XTick',axvec)
    axes(ax3)
    xlabel('PC 3')
    ylabel('PC 2')
%     axis equal tight
    grid on
    set(gca,'YTick',axvec)
    set(gca,'XTick',axvec(1:end-2))
    axes(ax4)
    set(gca,'yaxislocation','right');
    xlabel('PC 1')
    ylabel('PC 2')
    axis equal tight
    grid on
    set(gca,'YTick',axvec)
    set(gca,'XTick',axvec)
%     linkaxes(pcax,'xy')
    linkaxes([ax2 ax4],'xy')
%     linkaxes([ax3 ax4],'y')
%     linkaxes([ax2 ax3 ax4],'y')
    
    % Reduce x size of 3rd axis and %var plot
    cutFrac = 0.7; % Scale down ax3 x-axis
    axes(ax4)
    xl=xlim;
    xlim([xl(1) 200])
    asp_rat = diff(ylim)/diff(xlim) % This must be fed back into above setup
    lenx=diff(xlim)*cutFrac;
    yl = ylim;
    axes(ax2)
    mlim= mean(ylim);
    newxlim = mlim + [-1 1]*lenx/2;
    p1=get(ax1,'position');
    p3=get(ax3,'position');
    p2=get(ax2,'position');
    p4=get(ax4,'position');
    axes(ax3)
    xlim(newxlim)
    ylim(yl)
    set(ax3,'position',[p4(1)-(p4(3)*cutFrac) p4(2) p4(3)*cutFrac p4(4)])
    p3=get(ax3,'position');
    set(ax1,'position',[p3(1) p1(2) p1(3)-(p3(1)-p1(1)) (p2(2)+p2(4)-p1(2))])
 
%     printpdf('Clev_30_PCs_BGremoved',[8 8*asp_rat],figdir,'inches',400)

%% Poster fig with the 2D businass

