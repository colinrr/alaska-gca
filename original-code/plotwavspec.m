% --------------------------------------------------
%  Plot waveforms and spectrograms
% --------------------------------------------------
%!!!!! Requires full waveform data set !!!!!!

% Also minor warning: Plot options are generally meant for a big screen! 
%      >>>>> ie 2560x1440

close all

% Startup params

% GROUP OPTIONS:
%   spurr
%   redoubt
%   iliamna
%   fourpeaked
%   augustine
%   avoSW
%   kenai
%   NE
%   moos
%   mygroup
%   initial
%   all
%   quick

% ADDITIONAL OPTIONS FOR REDOUBT EXPLOSIONS (Red Squadron, report)
%   red2
%   red5
%   red12
%   red13


group = 'NE';

%--------
cutt     = 1; 
    twin = [0 1500];
%--------
plotwav  = 1;
    isrtby = 2;
    shift_t = 1;
        tshift2 = 1;
    timemarks = 0;
        tmk = []; 
    Ta = [1/5];
    Tb = [1/20];
    anorm = 1;
    vel  = 0.3;
    mapit = 0;
%--------
plotspec = 1;
    nfft = 512;
    overlap = 480;
    fmax = 30;
    dblims = [30 80];
    tile = 2;  %  1 = tile, 2 = cascade large, else = static = safe for small screen
%--------
plotpsd  = 0;

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

ind = group_select(w,group);
w2 = w(ind);


% sort w2 for plotting specs
if isrtby == 1
    srtby = 'AZ';
elseif isrtby == 2;
    srtby = 'DIST';
end
ord = get(w2,srtby)';
nums = find(get(w2,srtby))';
ord = [ord nums];
ord = sortrows(ord,1);
w2 = w2(ord(:,2)');

if cutt
    tstart = get(w2,'start');
    
    tcuts = t0 + twin/spdy;
    w2 = extract(w2,'TIME',tcuts(1),tcuts(2));
end

if plotwav
    if shift_t
        tshift2 = get(w2,'DIST')/vel;
    end
    if timemarks
        tmk = t0 + 92/vel/spdy;
    end
        tmark2 = ([(t0-0/spdy):300/spdy:(t0+60*20/spdy)]);
    plotw_rs(w2,isrtby,iabs,tshift2,tmk,Ta,Tb,pmax,iintp,anorm,tlims,nfac,azcen,iunit,mapit);
end

if plotspec
    % Spectrogram
    mxpfig = 6;
    if length(w2) > mxpfig
        for jj = 1:ceil(length(w2)/mxpfig);
            numwins = ceil(length(w2)/mxpfig);
            if tile == 1 % tile
                xmin = (ceil(jj/2)-1)*850+10;
                if mod(jj,2) == 0;
                    ymin = 100;
                else
                    ymin = 750;
                end
                plotpos = [xmin ymin 850 575];
            elseif tile == 2 % cascade
                xmin = 850 + jj*20;
                ymin = 300 - jj*20;
                plotpos = [xmin ymin 1000 1000];
            else
                plotpos = [50 400 850 575];
            end
            if length(w2)<jj*mxpfig
                wavspec(nfft,overlap,fmax,dblims,w2((jj-1)*mxpfig+1:end),plotpos);
            else 
                wavspec(nfft,overlap,fmax,dblims,w2((jj-1)*mxpfig+1:jj*mxpfig),plotpos);
            end
        end

    else
    wavspec(nfft,overlap,fmax,dblims,w2,plotpos);
    end
end

if plotpsd
end