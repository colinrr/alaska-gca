#!/usr/local/bin/python
import map_key as mk
import subprocess as sub

# GMT world map files conversions
verb_test = False # Run verbose test run to show commands without execution

odir    = mk.lay_path

tif_ipath = mk.lay_path
tif_opath = mk.conv_path # mk.conv_path
tiff_layers = [
    'GMRTv3_3_20170419topo.tif',  # 1/2 Downsampled version
    'dsamp_4_land_N4_geo.tif',  # 1/4
    # 'dsamp_ocean_geo.tif', # Downsampled version   
    # 'land_N4_geo.tif',       # FULL version
    # lay_path+'wrld_ocean_geo.tif', # FULL version   
    ]

shp_ipath = mk.wpath
shp_opath = mk.lay_path
shapefiles = [
	   # ('ne_10m_coastline/ne_10m_coastline.shp', 'coast.gmt'),
	   # ('ne_10m_rivers/ne_10m_rivers_lake_centerlines_scale_rank.shp', 'rivers.gmt'),
	   # ('ne_10m_lakes/ne_10m_lakes.shp', 'lakes.gmt'),
    #    ('ne_10m_minor_islands/ne_10m_minor_islands.shp', 'island.gmt'),
    #    ('ne_10m_land_poly/ne_10m_land.shp', 'land.gmt'),
    #    ('ne_10m_ocean_scale_rank/ne_10m_ocean_scale_rank.shp', 'ocean.gmt'),
    #    ('ne_10m_playas/ne_10m_playas.shp', 'playa.gmt'),
    #    ('ne_10m_antarctic_ice_shelves_polys/ne_10m_antarctic_ice_shelves_polys.shp', 'ice_shelves.gmt'),
    #    ('ne_10m_glaciers/ne_10m_glaciated_areas.shp', 'glacier.gmt'),
    #    ('ne_10m_reefs/ne_10m_reefs.shp','reefs.gmt'),
       
	   ]

# using lbl_path
lbl_ipath = mk.lbl_path
lbl_opath = mk.lbl_path
lbl_shpfiles = [
    # ('ne_10m_geography_regions_polys/ne_10m_geography_regions_polys.shp', 'label_regions.gmt'),
    # ('ne_10m_geography_regions_points/ne_10m_geography_regions_points.shp', 'label_points.gmt'),
    # ('ne_10m_geography_regions_elevation_points/ne_10m_geography_regions_elevation_points.shp', 'label_elevs.gmt'),
    # ('ne_10m_geography_marine_polys/ne_10m_geography_marine_polys.shp', 'label_marine.gmt'),
    ]

## ----- Run some conversions ------ #
def cmd_out(cmd,vt=False):
  if verb_test:
    print cmd
  else:
    sub.call(cmd, shell=True)

# Tiffs
cmd_line = 'gdal_translate -of GMT -b {n} {i} {o}'
for layer in tiff_layers:
    for num,col in [(1,'r'),(2,'g'),(3,'b')]:
        ifile = tif_ipath+layer
        ofile = layer.split('.')
        ofile = tif_opath + ofile[0] + '_{}.'.format(col) + 'nc' #ofile[1]
        cmd = cmd_line.format(n=num,i=ifile,o=ofile)
        cmd_out(cmd,vt=verb_test)

# Polygon shapefiles
cmd_line = 'ogr2ogr -f "GMT" {o} {i}'
for shp,poly in shapefiles:
    cmd = cmd_line.format(o=shp_opath+poly,i=shp_ipath+shp)
    # print cmd # Or, like I said...run it

# Label shapefiles
cmd_line = 'ogr2ogr -f "GMT" {o} {i}'
for shp,poly in shapefiles:
    cmd = cmd_line.format(o=shp_opath+poly,i=shp_ipath+shp)
    # print cmd # Or, ya...whatever
