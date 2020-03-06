#!/usr/bin/env python

# Build basemap
from os.path import join as pjoin
import project as pro
import cgmt

view		= True
pdf_convert = True
verb 		= True
dry 		= False

# colour scale params
include = 'high'
zmin    = None #-3000.

# ofiles = [pro.cpt,
# 		  pro.figdir+'Redoubt_basemap2.eps']

cpt_cmds = ['gmt grd2cpt -V {R} {grd} {cpt} -Z -T=  ']#' -G-500/500 {clims} {cstep} -Z']
int_cmds = [
			'gmt grdgradient {allgrd} -G{grdint} {A} -n+bg -Nt',
			# 'gmt grdgradient {grd} -G{grdint} {A} -n+bg -Nt',
			]
set_cmds = ['gmt gmtset --GMT_VERBOSE=n --PS_MEDIA=Custom_{pgx}ix{pgy}i --MAP_FRAME_PEN={frmpen} --MAP_GRID_PEN_PRIMARY={grdpen}'.format(**pro.basemap),]
prm_cmds = [
	# 'gmt psimage {jpg} {J} {R} -Dg+w6i {mapX} {mapY}',
    # 'gmt grdimage {tif} {J} {R} -Dr {mapX} {mapY} ',
    'gmt grdimage {allgrd} {J} {R} -I{grdint} {dpi} {C} {mapX} {mapY} {P}',
    # 'gmt grdimage {grd} {J} {R} -I{grdint} {dpi} {C} {mapX} {mapY} {P}',
    'gmt psxy {vo_xy} {Sv} {Gv} {Wv} {J} {R} {mapX} {mapY}',
    'gmt psxy {st_xyA} {Ss} {Gs} {Ws} {J} {R} {mapX} {mapY}',
    'gmt psxy {sp_xy} -Sc9p -Gdarkorange {Ws} {J} {R} {mapX} {mapY}',
    'gmt pstext {sp_txt} -F+3p {J} {R} {mapX} {mapY}',
    # 'gmt grdimage {jpg} {J} {R} -Dr {mapX} {mapY}',
    # 'gmt pscoast {J} {R} {mapX} {mapY} {lanfil} {cstrez}',
    # 'gmt psxy {volcanoes} {J} {R}',
    'gmt psbasemap {J} {R} {B} {mapX} {mapY} {P}',
	]

basemap_list = [
		# (cpt_cmds, pro.cpt),
		(int_cmds, ''),
		(set_cmds, ''),
		(prm_cmds, pjoin(pro.figdir,'Redoubt_basemap2.ps')),
		]

### END INPUT ###
# cgmt.tif2grdRGB(pro.basemap['tif'],dry=dry)
cgmt.lut2cpt(pro.lut,pro.cpt,include=include,zmin=zmin)
cgmt.runmaps(basemap_list,pro.basemap,pdf=pdf_convert,view=view,verby=verb,dry=dry)
