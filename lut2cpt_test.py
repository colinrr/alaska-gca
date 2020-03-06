#!/usr/bin/env python

# Testing script for converting lut to cpt
import numpy as np
import mathtricks as mt

ifile  = '/home/crowell/.GMA/lut/GMA_land_sea_ak_ed.lut'
ofile  = '/home/crowell/data/gmt-sandbox/flaghahaga.cpt'

cut0    = 0.0   # Cut point for original data, can also be 'high','low'
cut1    = None   # Cut point for new data
# zmin,zmax 	= 10.,1000.
zmin,zmax = None,None
# include = 'low'  # 'high', 'low'
include = 'all'
background = None
foreground = None
Nan		   = '128'

# MAY 8 - doubling 0.0 bug
    #   - odd round-up of rgb values bug

bg_lo = '163/192/217'
fg_hi = '90/140/100'

# ----- Parse some input
if include=='all':
    # keep = [0,1]
    hi,lo = False,False
elif include=='high':
    # keep = [1]
    hi,lo = True,False
    if background is None:
        background = bg_lo
elif include=='low':
    # keep = [0]
    hi,lo = False,True
    if foreground is None:
        foreground = fg_hi
        
if foreground is None:
    foreground = 'white'
if background is None:
    background = 'black' 

#----- Open up files and do the thing
print 'Reading file:\t{}'.format(ifile)
with open(ifile,'r') as lut:
    line = lut.readline()
    prev_line = ''
    data = []

#----- Gather data from ifile
    while line !="":
        dat = line.strip('\n').split('\t')
        if len(dat)>1:
            data.append(dat)
        line = lut.readline()

#----- Parse and manipulate data as needed
D = np.array(data)
Z = np.array(data)[:,0].astype(np.float)
C = np.squeeze(D[:,1::])

# Check if we need to reset or shift colour scale
if zmin or zmax or (cut0!=cut1) or (include in ('high','low')):

    # find original cutoff crossing (eg 1st land color)
    if cut0>=Z.min() and cut0<=Z.max():
        _,icut = mt.nearest(Z,cut0,'ceil')
    elif cut0<Z.min():
        icut = 0
    elif cut0>Z.max():
        icut = len[Z]

    # Define NEW zmin and zmax
    if zmin is None:
        zmin=Z.min()
    if zmax is None:
        zmax=Z.max()
    if cut1 is None:
        cut1 = mt.normalize(cut0,min0=Z.min(),max0=Z.max(),min1=zmin,max1=zmax)

    # Alt set colour ranges
    if cut1<zmin:
        if lo:
            cut1=zmax
        else:
            cut1 = zmin
            hi   = True
    elif cut1>zmax:
        if hi:
            cut1=zmin
        else:
            cut1 = zmax
            lo   = True

    if hi and lo:
        print "Warning! Incompatible z-limits and cutoff will result in null colour scale!"
        flargh

    Cr = [C[0:icut],C[icut::]]
    ZN = [mt.normalize(Z[0:icut],max0=Z[icut]),mt.normalize(Z[icut::])]
    Zl = [(zmin,cut1),(cut1,zmax)]
    
    Z1,C1 = [],[]
    for c,zn,zl in zip(Cr,ZN,Zl):
        Z1.append(mt.normalize(zn,min0=0.0,max0=1.0,min1=zl[0],max1=zl[1]))
        C1.append(c)

    Z1,C1 = np.hstack(Z1),np.hstack(C1)

    # Now if hi or lo and cut in range, cut out extra colours
    if hi:
        Z1,C1 = Z1[icut::],C1[icut::]
    if lo:
        Z1,C1 = Z1[0:icut],C1[0:icut]
else:
    Z1 = Z
    C1 = C

# # Print modified list in lut format
for z,c in zip(Z1,C1):
    print '{0:.3f}\t{1}'.format(z,c)

# ---- WRITE OUTPUT
print 'Writing: {}'.format(ofile)
with open(ofile,'w') as cpt:
    print 'derp\n'

    for i,(z,c) in enumerate(zip(Z1[1::],C1[1::]),1):
        new_line = '{}\t{}\t{}\t{}\n'.format(Z1[i-1],C1[i-1],z,c)
        print new_line.strip('\n')
        # cpt.write(new_line)
    print 'B\t{}'.format(background)
    print 'F\t{}'.format(foreground)
    print 'N\t{}'.format(Nan)
    # cpt.write('B\t{}\n'.format(background))
    # cpt.write('F\t{}\n'.format(foreground))
    # cpt.write('N\t{}\n'.format(Nan))