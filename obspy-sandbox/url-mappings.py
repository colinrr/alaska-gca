#!/usr/bin/env python

from obspy.clients.fdsn.header import URL_MAPPINGS


for key in sorted(URL_MAPPINGS.keys()):
	print("{0:<7} {1}".format(key,  URL_MAPPINGS[key]))