#!/usr/bin/env python

# Build basemap
from os.path import join as pjoin
import project as pro
import cgmt
import argparse
import numpy as np

# Needed input: lat/lon bounds, oname, volc_plot_flag (coords pre-written)
parser = argparse.ArgumentParser(description='Output station basemap.')
parser.add_argument('-r', help="lon0/lon1/lat0/lat1")
parser.add_argument('-o', help='Output file name')
parser.add_argument('-g', help='Select output grid file')
parser.add_argument('-v', action='store_true', help='Plot volcano location' )
args = parser.parse_args()

view		= True
pdf_convert = True
verb 		= True
dry 		= False

# colour scale params
include = 'high'
zmin    = None #-3000.


int_cmds = [
			'gmt grdgradient {bsmap} -G{grdint} {A} -n+bg -Nt',
			]
set_cmds = [
            'gmt gmtset --GMT_VERBOSE=n --PS_MEDIA=Custom_{pgx}ix{pgy}i --MAP_FRAME_PEN={frmpen} --MAP_GRID_PEN_PRIMARY={grdpen}'.format(**pro.basemap),
            'gmt gmtset --FONT_ANNOT_PRIMARY=20 --MAP_TICK_PEN_PRIMARY=3p --GMT_VERBOSE=n --PS_MEDIA=Custom_{pgx}ix{pgy}i --MAP_FRAME_PEN={frmpen} --MAP_GRID_PEN_PRIMARY={grdpen}'.format(**pro.basemap),            
            ]
prm_cmds1 = [
    # Map grid
    # 'gmt psclip {oce_poly} {J} {R} -N',
    'gmt pscoast -Df -Gc {J} {R} {mapX} {mapY} {P}',
    'gmt grdimage {bsmap} {J} {R} -I{grdint} {dpi} {C} {mapX} {mapY} {P}',
    'gmt pscoast -Df -Q {J} {R} {mapX} {mapY} {P}',
    'gmt pscoast -Df {cstpen} {ocefil} {J} {R} {mapX} {mapY} {P}',
    # 'gmt pscoast -Df {cstpen} {cstfil} {ocefil} {J} {R} {mapX} {mapY} {P}',
    # 'gmt psclip {J} {R} -C',

    # Map vectors 
    'gmt psxy {riv_poly} {rivpen} {J} {R}',
    'gmt psxy {lak_poly} {lakpen} {lakfil} {J} {R}',
    # 'gmt pscoast {J} {R} -S115/156/191 -Df',
    # 'gmt psxy {oce_poly} {lakpen} {J} {R}',
    ]

ev_cmd = ['gmt psxy {vo_xyT} {Sv} {Gv} {Wv} {J} {R} {mapX} {mapY}']

prm_cmds2 = [# volc_cmd,
    # 'gmt psxy {st_xyT} {Ss} {Gs} {Ws} {J} {R} {mapX} {mapY}',
    'gmt psxy {st_xyT_R2} {Ss} -Gnavy {Ws} {J} {R} {mapX} {mapY}', # Redoubt seis stato   
    'gmt psxy {st_xyT_R1} {Ss} {Gs} {Ws} {J} {R} {mapX} {mapY}', # Redoubt GCA stations
    # 'gmt psxy {sp_xy} -Sc9p -Gdarkorange {Ws} {J} {R} {mapX} {mapY}',
    # 'gmt pstext {sp_txt} -F+3p {J} {R} {mapX} {mapY}',
    # 'gmt psbasemap {J} {R} {B} {mapX} {mapY} {P}',
    'gmt psbasemap {J} {R} {BbmY} {sc_bar} {mapX} {mapY} {P}',
	]

# Special requests, as it were

if args.v:
    pro.basemap['vo_xy'] = ''
    prm_cmds = prm_cmds1 + ev_cmd + prm_cmds2
else:
    prm_cmds = prm_cmds1 + prm_cmds2

basemap_list = [
		(int_cmds, ''),
		(set_cmds, ''),
		(prm_cmds, pjoin(args.o)),
		]

### END INPUT ###
# Fix up lat/lon/scale
coords = args.r.strip('R').split('/')
lon_bounds  = [coords[0], coords[1]] #[-157.0, -142.0]
lat_bounds  = [coords[2], coords[3]] #[56.0, 64.5]
lons = [float(i) for i in lon_bounds]
lats = [float(i) for i in lat_bounds]
lon0 = sum(lons)/2.
lat0 = sum(lats)/2.

# flargh
# scalei  = np.squeeze(np.round(pro.pgx*0.5/np.diff(lons),4))
scalei = '6'
# scalei  = np.round(np.max((pro.pgx*0.9/np.diff(lons), pro.pgy*0.9/np.diff(lats))),4)
print scalei #, 'inches/degree'

pro.basemap['J'] = '-JL{}/{}/{}/{}/{}i'.format(lon0,lat0,lat_bounds[0],lat_bounds[1],scalei)
pro.basemap['R'] = '-R{}/{}/{}/{}'.format(lon_bounds[0],lon_bounds[1],lat_bounds[0],lat_bounds[1])

if args.g:
    pro.basemap['bsmap'] = args.g

# cgmt.tif2grdRGB(pro.basemap['tif'],dry=dry)
cgmt.lut2cpt(pro.lut,pro.cpt,include=include,zmin=zmin,background=pro.basemap['lakfil'].strip('-G'))
cgmt.runmaps(basemap_list,pro.basemap,pdf=pdf_convert,view=view,verby=verb,dry=dry)
