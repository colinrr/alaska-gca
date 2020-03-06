#!/usr/bin/env python

from obspy import read


# ifile = 'http://examples.obspy.org/RJOB_061005_072159.ehz.new'
# ifile1 = 'https://examples.obspy.org/COP.BHZ.DK.2009.050'
# ifiles = ['https://examples.obspy.org/COP.BHE.DK.2009.050',
# 		  'https://examples.obspy.org/COP.BHN.DK.2009.050',
# 		  'https://examples.obspy.org/COP.BHZ.DK.2009.050']
		  
ifile = 'https://examples.obspy.org/GR.BFO..LHZ.2012.108'

st = read(ifile)

# print st
# len(st)
# tr=st[0]
# print(tr.stats)

# sing_chan = read(ifile1)

# three_chan = read(ifiles[0])
# print(three_chan)