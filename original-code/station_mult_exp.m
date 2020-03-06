                                                                                                                                                                                                              %  Uvse this code to pull a single station for each of the major events

% Event times
    
    t0 = [datenum(2009,03,23,07,01,52); % Explosion 2
        datenum(2009,03,23,09,38,52);   % Explosion 4
        datenum(2009,03,23,09,48,20);   % Explosion 4a
        datenum(2009,03,23,12,30,21);   % Explosion 5
        datenum(2009,03,26,17,24,14);   % Explosion 8
        datenum(2009,03,28,01,34,43);  % Explosion 12
        datenum(2009,03,28,03,24,18);]; % Explosion 13
   
    spdy = 86400;
    
    
    
    % User input
    ds = datasource('uaf_continuous');
    
    station = 'TRAP';
    channel = '*';
    
    dur = 20*60/spdy;
    
    elat = 60.4888278;
    elon = -152.7643722;
    edep_km = 0;
    eid = [];
    mag = [];       % plotting only
    netwk = [];
    
    
    % For plotting
   isort = 2;
   iabs  = 0;
   iintp = 0;
   pmax  = 50;
   inorm = 1;
   tlims = [];
   nfac  = 1;
   axcen = [];
   iunit = 1;
   tmark = [];
    
    % Aaaaaaaand go
    

    
    scnl = scnlobject(station,channel,'','');
    
     wS = waveform(ds,scnl,t0,t0+dur);
%      figure
%      plot(wS)
     
        % Pull stations data for wset
     load AK_stations % Should have stuffs for the stations I need.    
    gps_ind = find(strcmp(raw,station));
    rlat = repmat(raw{gps_ind,2},1,length(wS));
    rlon = repmat(raw{gps_ind,3},1,length(wS));
    relev = repmat(raw{gps_ind,4},1,length(wS));
    
wS = wset(wS,rlat,rlon,elat,elon,eid,edep_km,relev,mag,netwk);
    % Plot raw
    
  %  figure
tmk = t0(end)+863/spdy;
tnorm = (get(wS(1),'start')-get(wS,'start'))*spdy;
plotw_rs(wS,isort,iabs,-tnorm,tmk,[1/5],[1/20],pmax,iintp,inorm,tlims,nfac,azcen,iunit,0);

%     set(gcf,'position',[40 200 1100 700])
%     step = 0.8/length(wS);
%     for kk = 1:length(wS);
%         axes('position',[0.1 0.9-(kk-1)*step 0.85 step])
%         plot(wS(kk))
%         if kk>1
%             title = ('');
%         end
%  %       ylabel([get(wS(kk),'station') ' ' get(wS(kk),'channel')])
%     end