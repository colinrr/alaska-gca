#!/usr/bin/env python

# GET STATION INVENTORY IN A RADIUS AROUND A SPECIFIC LOCATION
 # Optionally plot?

from obspy import UTCDateTime as utc
from obspy.clients.fdsn import Client
import project as pro
import numpy as np

		  # Volcano   [Events]
myvolcs = {'Redoubt': ['2']}

tspan = 3600;

kwargs = {
	'network'  : '*',
	'location' : '*',
	'channel'  : '*',
	'maxradius': '12',  # degrees
	'level'	   : 'response',
	'matchtimeseries' : True,
	} 

write_coords = False # Write lat/lon text file for GMT plotting
coord_file   = pro.mapDatPath + 'station_coords_all_AK.txt'

# Write station names file
write_names = False
text_file   = pro.mapDatPath + 'station_names_all.txt'
mappad 	   = 0.05 # Extra coord space with this fraction of smallest axis
# plot_map = True # output map
# netcdf   = True	# Output data to netcdf?

#######
client = Client('IRIS')
inventory = {}

for volc in myvolcs:
	for event in myvolcs[volc]:
		t0 = utc(*pro.volcanoes[volc]['events'][event])
		print t0
		kwargs['starttime'] = t0
		kwargs['endtime']   = t0+tspan
		kwargs['latitude']  = 57.5 #pro.volcanoes[volc]['lat']
		kwargs['longitude'] = -160 #pro.volcanoes[volc]['lon']
		iname = '{}-{}'.format(volc,event)
		inventory[iname] = client.get_stations(**kwargs)
		# print(inventory[iname])
		# inventory[iname].plot()

	st_list = inventory[iname].get_contents()
	nst = len(st_list[u'channels'])
	ch_list = []
	ch_xy	= []

	if write_coords:
		print "Writing: {}".format(coord_file)
		with open(coord_file,'w') as cf:
			for chan in st_list[u'channels']:
				coords = inventory[iname].get_coordinates(chan)
				trow    = (str(coords[u'longitude']),str(coords[u'latitude']),str(coords[u'elevation']),chan)
				row    = (coords[u'longitude'],coords[u'latitude'],coords[u'elevation'])

				ch_list.append(trow)
				ch_xy.append(row)
				cf.write('\t'.join(trow[0:3])+'\n')

stLocs = np.array(ch_xy)
lonlims = (np.min(stLocs[:,0]), np.max(stLocs[:,0]))
latlims = (np.min(stLocs[:,1]), np.max(stLocs[:,1]))

pad = np.min((np.diff(lonlims), np.diff(latlims)))*mappad

print "Lon range: {} - {}\nLat range: {} - {}".format(lonlims[0],lonlims[1],latlims[0],latlims[1])
print "Bbox:  [ {}  {}  ;  {}  {} ]".format(lonlims[0]-pad,lonlims[1]+pad,latlims[0]-pad,latlims[1]+pad)