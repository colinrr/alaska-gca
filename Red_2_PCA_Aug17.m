clear all; close all;

%################################################
% THIS IS THE MOST DISGUSTING CODE OF ALL TIME
%################################################

% Load up the manually selected Redoubt waveforms, containing both air
% waves and over-printed seismic signals
load ('~/Nextcloud/data/alaska-gca/waveforms/Redoubt_2_r300_st_ch_prep_MT_flt.mat')

% VERIFY POSITIONING AND TIMING OF SIGNALS, ESP SPURR NETWORK - BE
% CONVINCED THESE AREN'T AIRWAVES

%% Run an initial grab of tremor background plus signals of interest
% tcut0 = get(w(1),'start');
% tcut1 = datenum([2009 03 23 07 15 00]);
% w = extractall(w,tcut0,tcut1);
% [wall,idx1,cut_times1] = quickgrab(w,{},'spec');

% Run a second grab, chopping out just the signals of interest
% [wb,idx2,cut_times2] = quickgrab(w,{},'spec');

%%
pcview  = []; %[1 2 3];
pcview2 = [1 2 3];
pcview3 = [1 2];
fbands  = {[0 25]};

Red2_file = '~/Nextcloud/data/alaska-gca/manual-cut-waveforms/Redoubt_2_Aug17.mat';
% save(Red2_file)
load(Red2_file)

figdir = '~/Nextcloud/data/alaska-gca/figures/iavcei-poster-figs/';
%% Basemap
% project
% numGCA = [2 7 8 12 13]; %{ss(numGCA).StationCode}
% numSeis = [1 3 4 5 6 9 10 11]; % {ss(numsSeis).StationCode}
% grd      = '~/Nextcloud/data/alaska-gca/figures/map_data/cook_inlet.grd';
% mapfile  = '~/Nextcloud/data/alaska-gca/figures/basemaps/Red_2_basemap_iavcei.ps';
% stationmap(ss,E,true,mapfile,grd)

%% Red 2 Record section
% Activate commented code in plotWrecSec...
% plotWrecSec(w,1,0,0.3)
% [C1,T1,c1,d1,t1] = quickpick(3); % Show Acoustic vel
% [C2,T2,c2,d2,t2] = quickpick(3); % Show seismic vel
% v = zeros(4,2);
% v(1,:) = ginput(1); % Grab locations to plot velocities
% v(2,:) = ginput(1);
% v(3,:) = ginput(1); % Acoustic
% % v(4,:) = ginput(4); % Seismic
% angles = [-20 -30 -22];
% vels = [360 200 C1*1e3];
% for vv = 1:size(v,1)
%     vt(vv) = text(v(vv,1),v(vv,2),sprintf('%.0f m/s',vels(vv)),'Rotation',angles(vv),...
%        'HorizontalAlignment','left','VerticalAlignment','middle','fontsize',8 );
% end
% printpdf('Red_2_recSec',[10.5 8],figdir,'inches',400)
%% Spectrograms
spec_i = [1 11 13 4 7 10];
% % wp = extractall(w,get(w(1),'Start'),datenum(2013,5,4,13,24,0));
% wp = w;
% plotMTspec(wp(spec_i))
% set(get(gcf,'Children'),'FontSize',14)
% printpdf('Red_2_MTspecs',[7 7],figdir,'inches',400)

%% Run PCA on total original signal - get out PCA struct -------------
% wall = wsig; clear wsig;
pcdat = WavPca(wall,fbands,'raw',pcview);

%Run PCA on background signal to show independent estimate
pcdatB = WavPca(wb,fbands,'raw',pcview);

% Run PCA on only signal components
% wsig = extractall(wall,cut_times2(:,2),get(wall,'end'));
pcdatA = WavPca(wsig,fbands,'raw',pcview);

tMat = pcdat.eVecs; % Get transformation matrix from full waveform PCA
tMu  = pcdat.mu;
%% Comparitive PCA TEST ------------------------
% datasubset*eVecs to perform transformation
% Apply PCA transformation to just background set, and just signal part,
% then plot together. Doing this trace by trace will give further clarity

pctest = (pcdat.pxx - repmat(tMu,[size(pcdat.pxx,1),1]))*tMat; % Test transformation
figure
plot(pctest(:,1:3),'Linewidth',4)
hold
plot(pcdat.PCs(:,1:3))

%% Comparitive PCA ------------------------

% pcB    = pcdatB.pxx*tMat; % Manually transformed background specs

% pxxA = []; % Pxx for signal
% for k = 1:length(w);
%     p = get(w(k),'pxxmt');
%     pxxA = [pxxA p(:,size(get(wb(k),'pxxmt'),2)+1:size(get(wall(k),'pxxmt'),2))];
% end
% pxxA = pxxA';
% pcA  = pxxA*tMat; % Manually transformed signal

if ~isempty(pcview2)
    % Plot to show signal elements against background by station
    seischans = {'CKL','CKN','SPWE','SPBG','BGL','CP2','CRP','SPNW'};
    f1 = figure('position',[100 100 1000 800]);
    hold on
    f2 = figure('position',[100 100 1000 800]);
    hold on
    
    f3 = figure('position',[100 100 850 650]);
    hold on
    
    dnpc = subplot(1,1,1);
    cmap = colormap(dnpc,jet(numel(w)));
    cmgca = colormap(f2,autumn(numel(w)-numel(seischans))); % GCA chans
    cmseis= colormap(f2,winter(numel(seischans)));  % Seischangs
    cmg_count = 1;
    cms_count = 1;
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
    for k = 1:length(w)
        pxB = get(wb(k),'pxxmt');
        nbg = size(pxB,2);
        pxA = get(wsig(k),'pxxmt');
        fmt = get(wb(k),'fmt');
        tmt = get(wb(k),'tmt');
    %     pxA = pxA(:,nbg+1:end);

        % Filter frequencies
        fi = logical((fmt>=fband(1)) .* (fmt<=fband(2)));
        fmt = fmt(fi);
        pxB = pxB(fi,:);
        pxA = pxA(fi,:);
    
        pcB = (pxB'-repmat(tMu,[size(pxB',1),1]))*tMat;
        pcA = (pxA'-repmat(tMu,[size(pxA',1),1]))*tMat;
%         pcB = (pxB')*tMat;
%         pcA = (pxA')*tMat;

        % Reconstruct background spectra from center of each station cluster
        apcBG(k).npc = 10; % all PC background
        apcBG(k).pct = sum(pcdat.pcnt_var(1:apcBG(k).npc));
        [apcBG(k).centers,apcBG(k).reconstructed_spec]...
            = get_cluster_centers_and_reconstruct(ones(size(pcB(:,1))),...
            1,pcB,tMat,tMu,...
            fmt,apcBG(k).npc,tmt,pxB,0,'','','n');

        figure(f1)
        
        dotsz = 12;
        circsz = 10;
        
        % Plot coloured by station
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,cmap(k,:),'Marker','.');
        myhnd(k) = scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,cmap(k,:),'filled','Marker','o','MarkerEdgeColor',[0 0 0]);
        myleg{k} = get(wb(k),'station');
        
        
        figure(f2) % similar plot to highlight apparent seismic channels
        if k==1 % dummy plot to get legend bits
            extra_hnd(1) = scatter3(pcB(1,pcview2(1)),pcB(1,pcview2(2)),pcB(1,pcview2(3)),dotsz,[0.5 0.5 0.5],'Marker','.');
            extra_hnd(2) = scatter3(pcA(1,pcview2(1)),pcA(1,pcview2(2)),pcA(1,pcview2(3)),circsz,[0.5 0.5 0.5],'filled','Marker','o','MarkerEdgeColor',[0 0 0]);
            extra_leg = {'Background','Signal'};
        end
        if ismember(get(w(k),'station'),seischans)
%             scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,cmseis(cms_count,:),'filled','Marker','o')
            scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,'b','Marker','.');
            myhnd2(k) = scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,'b','filled','Marker','o','MarkerEdgeColor',[0 0 0]);
            cms_count = cms_count+1;
        else
%             scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,cmgca(cmg_count,:),'filled','Marker','o')
            scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),dotsz,'r','Marker','.');
            myhnd2(k) = scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),circsz,'r','filled','Marker','o','MarkerEdgeColor',[0 0 0]);
            cmg_count = cmg_count+1;
        end

     % Plot background specs 
    bg_spec_md(:,k) = median(pxB,2);
    leg{k} = get(wb(k),'station');
    figure(f3)
    if k==1 % dummy plot to get legend bits
        extra_hnd2(1) = plot(fmt(1:2),bg_spec_md(1:2,k),'color',[0.8 0.8 0.8],'Linewidth',3);
        extra_hnd2(2) = plot(fmt(1:2),apcBG(k).reconstructed_spec(1:2),'color',[0.4 0.4 0.4],'linewidth',1.5);
        extra_leg2 = {'Median spectra','PCA reconstruction'};
    end
    
    % Set up colors
    Sfrac = 0.4; Vfrac1 = 1.3; Vfrac2 = 0.75;
    col1 = rgb2hsv(cmap(k,:)); col2 = col1;
    col1(2) = col1(2)*Sfrac; col1(3) = col1(3)*Vfrac1; col2(3) = col2(3)*Vfrac2;
    col1(col1>1) = 1.0; col1 = hsv2rgb(col1); col2 = hsv2rgb(col2);
    
    
    fk_em(k) = plot(fmt,bg_spec_md(:,k),'color',col1,'Linewidth',3);
    sp_plots(k) = plot(fmt,apcBG(k).reconstructed_spec,'color',col2,'linewidth',1.5);
       
        
    end
    figure(f1)
    xlabel(sprintf('PC %i',pcview2(1)))
    ylabel(sprintf('PC %i',pcview2(2)))
    zlabel(sprintf('PC %i',pcview2(3)))
    axis equal tight
    grid on
    set(gca,'FontSize',16)
    view([1.3 0.7 0.9])
    ll=legend([extra_hnd myhnd],[extra_leg myleg],'Position',[0.2 0.6 0.1 0.1]);
    ll.FontSize = 9;
%     printpdf('Red_2_rawPCA_3D_byStation',[10 8],figdir,'inches',400)

    figure(f2)
    xlabel(sprintf('PC %i',pcview2(1)))
    ylabel(sprintf('PC %i',pcview2(2)))
    zlabel(sprintf('PC %i',pcview2(3)))
    axis equal tight
    grid on
    set(gca,'FontSize',16)
    view([1.3 0.7 0.9])
    ll2=legend([extra_hnd myhnd2([1 4])],[extra_leg {'GCA channel','EQ channel'}],'Position',[0.2 0.6 0.1 0.1]);
    ll2.FontSize = 14;
%     printpdf('Red_2_rawPCA_3D_bySignal',[10 8],figdir,'inches',400)

    figure(f3)
    title(sprintf('Background Spectra Reconstruction, %i PCs, %.1f%% Variance',apcBG(1).npc,apcBG(1).pct))
    spec_no = [2 3 5 6 8 9 12];
    delete(sp_plots(spec_no))
    delete(fk_em(spec_no))
    set(gca,'FontSize',12)
    axis tight
    grid on
    xlabel('Frequency (Hz)')
    ylabel('Reconstructed Amplitude (dB)')
    ll3 = legend([extra_hnd2 sp_plots(spec_i)],[extra_leg2 myleg(spec_i)],'Location','SouthWest');
    ll3.FontSize = 10;
%     printpdf('Red_2_background_spectra',[7 5],figdir,'inches',400)
end

%% Now get background clusters for each trace 
% pcBdat = [];
% for k = 1:3 %length(wb)
%     pcBdat = [pcBdat; WavPca(wb(k),{[]},'raw',[1 2 3])];
% end
% wbcut = wb;
% for k = 1:length(wb)
%     spec =  get(wbcut,'pxxmt');
%     spec(fi,:) = spec(fi,:)-repmat(apcBG(tr).reconstructed_spec,[1,size(spec,2)]);
%     wbcut(k) =   set(wb_guinea(tr),'pxxmt', spec );
% end
% pcBdat = singleWavPca(wb,fbands,'raw',[1 2]);
% 
% 
% 
% 
% % Compare this with just stacking and removing background
% bg_spec_av = zeros([length(pcBdat(1,1).fmt), length(wb)]);
% bg_spec_md = bg_spec_av;
% leg = cell(size(wb));
% ax  = zeros(size(wb));
% figure
% nr = 3; nc = 5;
% for tr = 1:13
%     % Have a look at the distributions
%     sp = get(wb(tr),'pxxmt');
%     fmt = get(wb(tr),'fmt');
% %     fmt = fmt(1:10:end-10); sp = sp(1:10:end-10,:);
% %     figure
% %     for f = 1:length(fmt)
% %         tightSubplot(5,5,f,0,0);
% %         histogram(sp(f,:));
% %     end
% 
%     fmt = fmt(fi);
%     sp = sp(fi,:);
% 
%     % Get averaged specs from raw waveforms
%     bg_spec_av(:,tr) = mean(sp,2);
%     bg_spec_md(:,tr) = median(sp,2);
%     leg{tr} = get(wb(tr),'station');
%     
%     ax(tr) = tightSubplot(nr,nc,tr,0,0);
%     plot(fmt,pcBdat(tr).reconstructed_spec,'k','linewidth',2)
%     hold on
%     plot(fmt,apcBG(tr).reconstructed_spec,'g','linewidth',1.2)
%     plot(fmt,bg_spec_av(:,tr),'b')
%     plot(fmt,bg_spec_md(:,tr),'r')
%     if tr==1
%         legend({'single PCA',sprintf('full PCA, %i PCs, %.1f%%',apcBG(tr).npc,apcBG(tr).pct),'Mean','Median'},'Location','southwest')
%     end
%     grid on
%     axis tight
% end
% linkaxes(ax,'xy')
% % figure
% % tightSubplot(1,2,1,0)
% % plot(repmat(fmt,[1,size(bg_spec_av,2)]),bg_spec_av)
% % ylabel('Amplitude (dB)')
% % xlabel('Freq (Hz)')
% % title('Average spectra')
% % axis tight
% % grid on
% % legend(leg)
% % tightSubplot(1,2,2,0)
% % plot(repmat(fmt,[1,size(bg_spec_md,2)]),bg_spec_md)
% % xlabel('Freq (Hz)')
% % title('Median spectra')
% % set(gca,'YTickLabel',[])
% % axis tight
% % grid on

%% Subtract chosen background specs, then run PCA on the remaining set
% Try the full signal first
wb_guinea = wall;
for tr = 1:length(wb_guinea)
    spec =  get(wb_guinea(tr),'pxxmt');
    spec(fi,:) = spec(fi,:)-repmat(apcBG(tr).reconstructed_spec,[1,size(spec,2)]);
    wb_guinea(tr) = set(wb_guinea(tr),'pxxmt', spec );
end
% plotMTspec(wall)
% plotMTspec(wb_guinea)
pcmode = 'raw';
pcBG_removed = WavPca(wb_guinea,fbands,pcmode);
tMat = pcBG_removed.eVecs; % Get transformation matrix from full waveform PCA
tMu  = pcBG_removed.mu;

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

if ~isempty(pcview2)
    % Plot to show signal elements against background by station
    seischans = {'CKL','CKN','SPWE','SPBG','BGL','CP2','CRP','SPNW'};
    f1 = figure;
    hold on
    
    
%     f2 = figure;
%     hold on

    dnpc = subplot(1,1,1);
    cmap = colormap(dnpc,jet(numel(w)));
%     cmgca = colormap(f2,autumn(numel(w)-numel(seischans))); % GCA chans
%     cmseis= colormap(f2,winter(numel(seischans)));  % Seischangs
%     cmg_count = 1;
%     cms_count = 1;

% PC space fig, coloured by station and highlighting signal elements
% Set up colors
Sfrac = 0.6; Vfrac1 = 1.3; Vfrac2 = 1.0;
r1 = rgb2hsv([1 0 0]); % = col1;
r1(2) = r1(2)*Sfrac; %col1(3) = col1(3)*Vfrac1; col2(3) = col2(3)*Vfrac2;
r1(col1>1) = 1.0; r1 = hsv2rgb(r1); % col2 = hsv2rgb(col2);
b1 = rgb2hsv([0 0 1]); b1(2) = b1(2)*Sfrac; b1(col1>1) = 1.0; b1 = hsv2rgb(b1);

f3fs = 12;
% Require exact aspect ratio
asp_rat = 0.54945783;
pads = [0.12 0.1 0.12 0.1];
f3 = figure('position',[100 100 1000 1000*asp_rat]);
ax1 = tightSubplot(2,2,1,0.15,0.22);
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

    for k = 1:length(w)
        pxB = get(wbR(k),'pxxmt');
        nbg = size(pxB,2);
        pxA = get(wsigR(k),'pxxmt');
        fmt = get(wbR(k),'fmt');
        tmt = get(wbR(k),'tmt');

        fmt = fmt(fi);
        pxB = pxB(fi,:);
        pxA = pxA(fi,:);

        %     pxA = pxA(:,nbg+1:end);
        Npb = size(pxB,1);
        Npa = size(pxA,1);
    
    if strcmp(pcmode,'norm')
        pxBSum = sum(abs(pxB),1); 
        pxB   = pxB./repmat(pxBSum,[Npb,1]);
        pxASum = sum(abs(pxA),1); 
        pxA   = pxA./repmat(pxASum,[Npa,1]);
    elseif strcmp(pcmode,'normshift')
        pxBSum = sum(abs(pxB),1); 
        pxB   = pxB./repmat(pxBSum,[Npb,1]);
        pxB  = pxB - repmat(median(pxB,1),[Npb,1]);
        pxASum = sum(abs(pxA),1); 
        pxA   = pxA./repmat(pxASum,[Npa,1]);
        pxA  = pxA - repmat(median(pxA,1),[Npa,1]);
    %         pxx  = pxdbN - repmat(median(pxdbN,1),[pn,1]);        
    end

        pcB = (pxB'-repmat(tMu,[size(pxB',1),1]))*tMat;
        pcA = (pxA'-repmat(tMu,[size(pxA',1),1]))*tMat;
%         pcB = (pxB')*tMat;
%         pcA = (pxA')*tMat;

        % Reconstruct background spectra from center of each station cluster
%         apcBG(k).npc = 10; % all PC background
%         apcBG(k).pct = sum(pcdat.pcnt_var(1:apcBG(k).npc));
%         [apcBG(k).centers,apcBG(k).reconstructed_spec]...
%             = get_cluster_centers_and_reconstruct(ones(size(pcB(:,1))),...
%             1,pcB,tMat,tMu,...
%             fmt,apcBG(k).npc,tmt,pxB,0,'','','n');

        figure(f1)
%         scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),15,cmap(k,:),'Marker','.')
        scatter3(pcB(:,pcview2(1)),pcB(:,pcview2(2)),pcB(:,pcview2(3)),15,[0.5 0.5 0.5],'Marker','.')
%         scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),10,cmap(k,:),'filled','Marker','o','MarkerEdgeColor',[0 0 0])

%         figure(f2) % similar plot to highlight apparent seismic channels
        if ismember(get(w(k),'station'),seischans)
%             scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),12,cmap(k,:),'filled','Marker','^','MarkerEdgeColor',[0 0 0])
            scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),12,'b','filled','Marker','^','MarkerEdgeColor',[0 0 0])
        else
%             scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),12,cmap(k,:),'filled','Marker','o','MarkerEdgeColor',[0 0 0])
            scatter3(pcA(:,pcview2(1)),pcA(:,pcview2(2)),pcA(:,pcview2(3)),12,'r','filled','Marker','o','MarkerEdgeColor',[0 0 0])
        end

        % 2D poster version
%         figure(f3)
         % PC3 (y) vs PC1 (x)
        axview = [1 3; 3 2; 1 2];

        for ax = 1:3
            axes(pcax(ax))
            hold on
            if ismember(get(w(k),'station'),seischans)
                scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,b1,'Marker','.')
%                 scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[0 0 1],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
        %         cms_count = cms_count+1;
            else
                scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,r1,'Marker','.')
%                 scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[1 0 0],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
        %         cmg_count = cmg_count+1;
            end
        end
       
    end
    
for k = 1:length(w)
    pxB = get(wbR(k),'pxxmt');
    nbg = size(pxB,2);
    pxA = get(wsigR(k),'pxxmt');
    fmt = get(wbR(k),'fmt');
    tmt = get(wbR(k),'tmt');

    fmt = fmt(fi);
    pxB = pxB(fi,:);
    pxA = pxA(fi,:);

    %     pxA = pxA(:,nbg+1:end);
    Npb = size(pxB,1);
    Npa = size(pxA,1);
    
    if strcmp(pcmode,'norm')
        pxBSum = sum(abs(pxB),1); 
        pxB   = pxB./repmat(pxBSum,[Npb,1]);
        pxASum = sum(abs(pxA),1); 
        pxA   = pxA./repmat(pxASum,[Npa,1]);
    elseif strcmp(pcmode,'normshift')
        pxBSum = sum(abs(pxB),1); 
        pxB   = pxB./repmat(pxBSum,[Npb,1]);
        pxB  = pxB - repmat(median(pxB,1),[Npb,1]);
        pxASum = sum(abs(pxA),1); 
        pxA   = pxA./repmat(pxASum,[Npa,1]);
        pxA  = pxA - repmat(median(pxA,1),[Npa,1]);
    %         pxx  = pxdbN - repmat(median(pxdbN,1),[pn,1]);        
    end

        pcB = (pxB'-repmat(tMu,[size(pxB',1),1]))*tMat;
        pcA = (pxA'-repmat(tMu,[size(pxA',1),1]))*tMat;
       for ax = 1:3
            axes(pcax(ax))
            hold on
            if ismember(get(w(k),'station'),seischans)
%                 scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,b1,'Marker','.')
                scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[0 0 1],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
        %         cms_count = cms_count+1;
            else
%                 scatter(pcB(:,axview(ax,1)),pcB(:,axview(ax,2)),10,r1,'Marker','.')
                scatter(pcA(:,axview(ax,1)),pcA(:,axview(ax,2)),10,[1 0 0],'filled','Marker','o','MarkerEdgeColor',[0 0 0])
        %         cmg_count = cmg_count+1;
            end
       end
       
end
%     figure(f1)
%     xlabel(sprintf('PC %i',pcview2(1)))
%     ylabel(sprintf('PC %i',pcview2(2)))
%     zlabel(sprintf('PC %i',pcview2(3)))
%     axis equal tight
%     grid on

%     figure(f2)
%     xlabel(sprintf('PC %i',pcview2(1)))
%     ylabel(sprintf('PC %i',pcview2(2)))
%     zlabel(sprintf('PC %i',pcview2(3)))
%     axis equal tight
%     grid on
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
    mlim= mean(xlim);
    lenx=diff(xlim)*cutFrac;
    yl = ylim;
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
    
%     printpdf('Red_2_PCs_BGremoved',[8 8*asp_rat],figdir,'inches',400)
end


%% The classic approach
% Filter/stack/convolve/x-corr known signals to get difference between gca and
% seismic signals. Comparison of the techniques.