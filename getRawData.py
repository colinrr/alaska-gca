#!/usr/bin/env python

# GET RAW DATA

from obspy import UTCDateTime as utc
from obspy.clients.fdsn import Client
import obspy
from geographiclib.geodesic import Geodesic
import itertools
import project as pro
from scipy.io import savemat
from os.path import join as pjoin
import os
import sys
import cPickle as pkl
sys.path.append(pjoin(pro.homedir,'MATLAB/GISMO/contributed/+obspy'))
from stream2matfile2 import stream2matfile as st2mat

		  # Volcano   [Events]
myvolcs = {'Redoubt': ['2']}
myvolcs = [('Redoubt','2')]

wavdir   = pjoin(pro.datadir,'redoubt-2-spurr-network/')
wavfile = pjoin(wavdir,'red2-spurrNW-{}') # No extension in st2mat for now
wtype   = ('sac','SAC')

inv_file = pjoin(pro.invendir,'{v}_{ev}_station_inventory.pkl')

# BGL.AV.EHZ, NKA.AK.EHZ
networks    = ''#AV'
sub_nws 	= [
				# pro.av_redoubt,
				pro.av_spur,
				# pro.yv,
				]
stations    = ''#BGL' #'BGL,NCG,STLK'
channels    = 'EHZ'#,ACE,BHE,BHZ'
locations   = ''

# Test params
# networks  = 'IU'
# stations  = 'ANMO'
# locations = '00'
# channels  = 'LHZ'

# Flat signal duration
tspan = 500	# s
# tspan = 60*60
do_the_thing = True
writemat 	 = False

##############################################################################

if do_the_thing:  # Download data
# Parse networks and channels
	if sub_nws:
		# Get all networks
		nws = [nw['nw'] for nw in sub_nws]
		if networks:
			nws.append(networks)
		networks = ','.join(list(set(nws)))

		# Get all stations
		sub_sts = [stlist['stations'] for stlist in sub_nws]
		sub_sts = list(itertools.chain.from_iterable(sub_sts))
		if stations:
			sub_sts.append(stations)
		stations = ','.join(list(set(sub_sts)))

	print networks
	print stations
	# flargh

	client = Client('IRIS')
	for volc,ev in myvolcs:
		# for event in myvolcs[volc]:
		t0 = utc(*pro.volcanoes[volc]['events'][ev])
		print t0
		
		args = [networks,stations,locations,channels,t0,t0+tspan]
		st = client.get_waveforms(attach_response=True,*args)
		ev_coords = (pro.volcanoes[volc]['lat'],pro.volcanoes[volc]['lon'])

		# Get Station inventory - WILL WANT TO ADD CHECK AND OBTAIN IF NOT FOUND
		ifile = inv_file.format(v=volc,ev=ev)
		with open(ifile,'r') as ifl:
			st_inv = pkl.load(ifl)

########### Temp thing just for BGL ##############
# Force the coordinates, the fuckers
geod = Geodesic.WGS84
for i,tr in enumerate(st):
	nw  = tr.stats.network
	stn = tr.stats.station
	loc = tr.stats.location
	ch  = tr.stats.channel
	sid = '{}.{}.{}.{}'.format(nw,stn,loc,ch)
	st[i].stats.coordinates = {}
	lat = st_inv.get_coordinates(sid)['latitude']
	lon = st_inv.get_coordinates(sid)['longitude']
	st[i].stats.coordinates.latitude  = lat
	st[i].stats.coordinates.longitude = lon
	# st[i].stats.distance,_,_ = obspy.gps2dist_azimuth(ev_coords[0],ev_coords[1],lat,lon)
	st[i].stats.distance = geod.Inverse(ev_coords[0],ev_coords[1],lat,lon)['s12']

# Remove response
pre_filt = (0.005,0.006,30.,35.)
st_rr = st.copy() #.merge(method=1)
st_rr.remove_response(output='DISP',pre_filt=pre_filt)

# # Filter
st_flt1 = st_rr.copy()
st_flt1.filter('highpass',freq=0.5,corners=2,zerophase=True)
st_flt2 = st_rr.copy()
st_flt2.filter('bandpass',freqmin=10.,freqmax=20.,corners=2,zerophase=True)
# st_flt2.merge(method=1)



# st_flt2.plot(equal_scale=False,type='relative')
# st_flt2.plot(type='section')


# st_flt2.plot(type='section',ev_coord=ev_coords,dist_degree=True)

# # st_rr.plot()
# dicts = [st,st_rr,st_flt1,st_flt2]
# names = ['raw','rr','flt1','flt2']

# for nm,stream in zip(names,dicts):
# 	for tr in stream:
# 		mdict = {k: str(v) for k,v in tr.stats.iteritems()}
# 		mdict['data'] = tr.data
# 		savemat(BGL_file.format(nm),mdict)

# Test STA/LTA
# Save to .mat file
if writemat:
	st2mat(st,wavfile.format('raw'))
	st2mat(st_rr,wavfile.format('no-response'))
	st2mat(st_flt1,wavfile.format('highp'))
	st2mat(st_flt2,wavfile.format('bandp'))

# Save to readable file for conversion to .mat
# st.write(wavfile.format('raw',wtype[0]),format=wtype[1])
# st_rr.write(wavfile.format('no-response',wtype[0]),format=wtype[1])
# st_flt1.write(wavfile.format('highp',wtype[0]),format=wtype[1])
# st_flt2.write(wavfile.format('bandp',wtype[0]),format=wtype[1])

