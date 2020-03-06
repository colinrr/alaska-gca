% ----------------------------------------------------------------------
%       GET REDOUBT WAVEFORMS
% ----------------------------------------------------------------------

% Code for pulling up waveforms from uaf_continuous database
% Currently adapted specifically for events froom Redoubt, 2009

% Borrowed some code from waveform stuff
% CRowell


clear all; close all;

spdy = 86400;

% Get event start time
Redoubt_events

%Database: 1 for uaf_continuous
idb = 1;

% Stations



% Set channels to recover
chan = {'TRAP_EHZ'};

% Additional inputs
duration = 3600*1;
tshift = -60;   %Start record 60 s before explosion onset
axb = [];
cutoff = [];
samprate = [];
sacdir = [];
iint = 0;

iprocess = 2;
% Plot? 1 = Y, 0 = N
irs = 1;

% ----------------------------------------------------
Tstart = t0 - tshift/spdy;
Tend   = Tstart + duration/spdy;


%[w,s,site,sitechan] = getwaveform(idb,Tstart,Tend,chan,iint,iprocess,cutoff,samprate,axb,sacdir,t0,elat,elon,edep,emag,eid);

whos w s site sitechan