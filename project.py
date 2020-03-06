#!/usr/bin/env python

from os.path import join as pjoin
import numpy as np
# project parameters

name = 'Alaska Ground-Coupled-Airwaves'

# Home directory
homedir     = '/home/crowell/'  	# Matlabsaurus
# homedir		= '/Users/crrowell/'	# Calculon

# Set files and folders
datadir 	= pjoin(homedir,'Nextcloud/data/alaska-gca/')
invendir    = pjoin(datadir,'station_inventories')
figdir  	= pjoin(datadir,'figures/')
mapDatPath  = pjoin(figdir,'map_data/') 
mapImgPath 	= pjoin(figdir,'map_images/')
lay_path    = pjoin(mapDatPath,'basemap_vectors/')
# Volcanoes, events, networks


volcanoes = {
			'Redoubt': {'lat'   : 60.4852,
						'lon'   : -152.7438,
						'elev'  : 3100,
						'events': { '1' : [2009,03,23,06,35,16],
									'2' : [2009,03,23,07,01,52],
									# '3' : [2009,03,23,08,14,05],
									# '4' : [2009,03,23,09,38,52],
									# '4a': [2009,03,23,09,48,20],
									'5' : [2009,03,23,12,30,21],
									'8' : [2009,03,26,17,24,14],
									'12': [2009,03,28,01,34,43],
									'13': [2009,03,28,03,24,18],
									'18': [2009,03,29,03,23,31],
									},
						},
			'test':	   {'events' : {}
						},

			'Spurr'	:  {'lat'   : 61.2989, 
						'lon'   : -152.2539,
						'elev'  : 1900,
						'events': { 
									},
						},

			'Cleveland':{'lat'   : 52.8222, 
						'lon'   : -169.945,
						'elev'  : 1730,
						'events': { 
									},
						},

			'Bogoslof':  {'lat'   : 53.9272, 
						'lon'   : -168.0344,
						'elev'  : 0,
						'events': { 
									},
						},

			'Pavlof':  {'lat'   : 55.4173, 
						'lon'   : -161.8937,
						'elev'  : 2519,
						'events': { 
									},
						},
			'Okmok':   {'lat'   : 53.419, 
						'lon'   : -168.132,
						'elev'  : 2519,
						'events': { 
									},
						},
			}

## NETWORKS and SUB-NETWORKS
av_redoubt 	= { 'nw': 'AV',
			'stations':[
			'BGR',
			'DFR',
			'NCT',
			'RED',
			'REF',
			'RDN',
			'RSO',
			],}

av_spur 	= { 'nw': 'AV',
			'stations':[
			'BGL',
			'BKG',
			'CGL',
			'CKL',
			'CKN',
			'CKT',
			'CP2',
			'CRP',
			'SPBG',
			'SPCG',
			'SPNW',
			'SPU',
			'SPWE',
			'SPCR',
			],}

yv 		 	= { 'nw': 'YV',
			'stations':[
			'NSKI',
			'MPEN',
			'SOLD',
			'LSKI',
			'RUSS',
			],}

# Manually list some stations for now, hopefully can mine them later
station_radius = 5 # Degrees
stations = ['']

# Mapping params
# ALL AK
lon_bounds 	= [-172, -148] #[-157.0, -142.0]
lat_bounds 	= [52, 63] #[56.0, 64.5]

# COOK INLET
# lon_bounds 	= [-154, -148] #[-157.0, -142.0]
# lat_bounds 	= [59, 62] 

pgx			= 24.
pgy 		= 24.
# scale		= '1:20000000'
scalei		= np.max((pgx/np.diff(lon_bounds), pgy/np.diff(lat_bounds)))
# scale       = '{}i'.format(scalei)
scale 		= '9i'
# scale 		= '4i'

lon0 = sum(lon_bounds)/2.
lat0 = sum(lat_bounds)/2.
# cpt	 = 'globe'
# cpt  = pjoin(mapDatPath,'ak.cpt')
cpt  = pjoin(mapDatPath,'GMA_ak.cpt')
# cpt  = '/home/crowell/data/gmt-sandbox/flaghahaga.cpt'
lut  = pjoin(homedir,'.GMA/lut/GMA_land_sea_ak_ed.lut')

basemap = {
# General map and page params
	'J'		: '-JL{}/{}/{}/{}/{}'.format(lon0,lat0,lat_bounds[0],lat_bounds[1],scale),
	'R' 	: '-R{}/{}/{}/{}'.format(lon_bounds[0],lon_bounds[1],lat_bounds[0],lat_bounds[1]),
	'Rint'  : '-R{}/{}/{}/{}'.format(lon_bounds[0]+1,lon_bounds[1]-1,lat_bounds[0]+1,lat_bounds[1]-1),
	'B' 	: '-Ba', #f5/5/5',
	'mapX'	: '-Xc',
	'mapY'	: '-Yc',
	'P'	    : '-P', #'-P',

	'pgx'	: str(pgx),	#inches
	'pgy'	: str(pgy),#inches
	'frmpen': '0.05c',
	'grdpen': '0.02c,64/53/40',
	# 'sc_bar': '-L-168.5/52.2/52.2/100', # Cleveland
	'sc_bar': '-L-150.75/60.6/60.6/50',   # Redoubt
	# 'sc_pen': '-Wthicker',
	# 'BbmY'  : '-Bpy1.0 -Bx2.0', # Cleveland
	'BbmY'  : '-Bpy0.5 -Bx1.0', # Redoubt
# Data files for grid
	'tif'	: pjoin(mapImgPath,'ak_basemap.tif'),
	# 'grd'	: pjoin(mapDatPath,'ak_basemap.grd'),
	'grd'	: pjoin(mapDatPath,'cook_inlet.grd'),
	'jpg'	: pjoin(mapImgPath,'Redoubt_basemap.jpg'),
	'allgrd': pjoin(mapDatPath,'all_volcs.grd'),
	'bsmap'	: pjoin(mapDatPath,'ak_basemap_174W_145W_51-5N_66N.grd'),
	# 'r_grd'	: pjoin(mapImgPath,'ak_basemap_RGBgrid/r.grd'),
	# 'g_grd'	: pjoin(mapImgPath,'ak_basemap_RGBgrid/g.grd'),
	# 'b_grd'	: pjoin(mapImgPath,'ak_basemap_RGBgrid/b.grd'),
# Vector layers
	'cst_poly' : pjoin(lay_path, 'coast.gmt'),
	'riv_poly' : pjoin(lay_path, 'rivers_ed_2.gmt'),
	'lak_poly' : pjoin(lay_path, 'lakes.gmt'),
	'oce_poly' : pjoin(lay_path, 'ocean.gmt'),
# coast and poly params
	'cstpen' : '-W0.0065c,45/110/55', #75/66/55'
	'rivpen' : '-W0.01c,51/133/204', #75/66/55'
	'lakpen' : '-W0.0065c,51/133/204', #53/59/71'
	'cstfil' : '-G0/155/45',
	'ocefil' : '-S115/156/191',
	'lakfil' : '-G115/156/191', #163/192/217',
# Color map info
	'cpt'	: '-Cglobe', 			 # Grad default color map
	'clims' : '-L-100/800',
	'cstep' : '-S-1000/1000/10',
	'C'		: '-C{}'.format(cpt),	 # Grab color palette file
# Shader gradient info
	'grdint': pjoin(mapDatPath,'ak_basemap_int.grd'),
	'A'		: '-A315', # Shader azimuth
	'jpgref': '-Dg',
	'E'		: '-Ep',
	# stations file
	# volcanoes file/pull from volcanoes list
	'st_xy' : pjoin(mapDatPath,'station_coords.txt'),
	'st_xyA': pjoin(mapDatPath,'station_coords_all_AK.txt'),
	'vo_xy' : pjoin(mapDatPath,'volc_coords.txt'),
	'sp_xy' : pjoin(mapDatPath,'spurr_fig_coords.txt'),
	'sp_txt': pjoin(mapDatPath,'spurr_fig_labels.txt'),
	# Temp coord files for plotting coord outputs
	'st_xyT': pjoin(mapDatPath,'temp_station_coords.xy'),
	'st_xyT_R1': pjoin(mapDatPath,'temp_station_coords_R2-D1.xy'), # Redoubt 2 GCA stations
	'st_xyT_R2': pjoin(mapDatPath,'temp_station_coords_R2-D2.xy'), # Redoubt 2 seis stations
	# 'st_xyT_R1': pjoin(mapDatPath,'temp_station_coords_C30_KO.xy'), # Cleveland 30 GCA stations
	# 'st_xyT_R2': pjoin(mapDatPath,'temp_station_coords_C30_OK.xy'), # Cleveland 30 seis stations
	'vo_xyT': pjoin(mapDatPath,'temp_volc.xy'),
	'Ss'	: '-Sc9p', #-Sc4p',
	'Gs'	: '-Gred', # Station fill
	'Ws'	: '-Wthin,black',		# Station pen
	'cstrez': '-Dh',
	# volcano symbols
	'Sv'	: '-St20p', #-St15p',
	'Gv'	: '-Ggold',
	'Wv'	: '-Wthick,black',
	'dpi'	: '-E400',
	'lanfil': '-Gblack',
}

