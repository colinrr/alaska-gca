#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import obspy

# # Merge seismogram stream
# def merge_stream(st,plotter=True):
st.sort(['starttime'])

# start time in plot equals 0
dt = st[0].stats.starttime.timestamp

# Go through the stream object, determine time range in julian seconds
# and plot the data with a shared x axis
ax = plt.subplot(3, 1, 1)  # dummy for tying axis
for i in range(2):
    plt.subplot(3, 1, i + 1, sharex=ax)
    t = np.linspace(st[i].stats.starttime.timestamp - dt,
                    st[i].stats.endtime.timestamp - dt,
                    st[i].stats.npts)
    plt.plot(t, st[i].data)

# Merge the data together and show plot in a similar way
st.merge(method=1)		

plt.subplot(3, 1, 3, sharex=ax)
t = np.linspace(st[0].stats.starttime.timestamp - dt,
            st[0].stats.endtime.timestamp - dt,
            st[0].stats.npts)
plt.plot(t, st[0].data, 'r')
plt.show()
	
