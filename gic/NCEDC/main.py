import os
import numpy as np
from datetime import timedelta

import ncedc

# Pretty printed contents of output:
# http://ds.iris.edu/mda/BK/PKD/

net = 'BK'
sta = 'PKD'

# Try to download files for which there was a previous error or no data.
tryagain = False 

# Re-download metadata files
updatemetadata = False

# Relative path to save data in
datadir = 'data'
if not os.path.exists(datadir): os.makedirs(datadir)

# Read metadata for station into a dict
xmld = ncedc.readmetadata(net, sta, datadir=datadir, updatemetadata=updatemetadata)

# Extract channels and start & stop dates
channels, starts, stops = ncedc.xmlinfo(xmld)

#ncedc.downloaddata(net, sta, channels, starts, stops, datadir=datadir, tryagain=tryagain)

uchannels = list(set(channels)) # Unique channels
uchannels.sort()

channeldict = {'LT1': 'B_{East}',
               'LT2': 'B_{South}',
               'LT3': 'B_{Down}',
               'LQ2': 'E_{East}',
               'LQ3': 'E_{South}',
               'LQ4': 'E_{East}',
               'LQ5': 'E_{South}',
               }

net = 'BK'
sta = 'PKD'
datadir = 'data'
updateresponse = False

if False:
    start = '1999-01-01'
    #stop = '1999-12-31'
    stop = '2008-12-31'
    avail = ncedc.readdata(net, sta, uchannels, start, stop, datadir='data', output='availability')
    time = list(ncedc.daterange(start, stop))
    
    # Add bin boundaries for time
    #time = np.concatenate((time, [time[-1] + timedelta(days=1)]))
    #avail = np.vstack([np.nan*np.ones((1,7)), avail])
    
    from hapiclient.plot.heatmap import heatmap
    opts = {'cmap.name': 'gray','nan.legend': False, 'nan.hatch':'x'}
    fig, cb = heatmap(time, uchannels, np.transpose(avail), **opts)

if False:
    import obspy
    channel = 'LQ2'
    rfile = ncedc.downloadresponse(net, sta, channel,
                                   updateresponse=updateresponse,
                                   datadir=datadir)
    
    fname = datadir + "/" + net + "/" + sta + "/" + net + "-" + sta + "-"
    fname = fname + channel + "-20020802.mseed"

    st = obspy.read(fname)    
    inv = obspy.read_inventory(rfile)
    st[0].remove_response(inventory=inv, water_level=1000, plot=False)    

if True:
    start = '2002-08-01'
    stop = '2002-08-31'
    data = ncedc.readdata(net, sta, uchannels, start, stop)
    
    time = []
    startdt = ncedc.str2datetime(start)
    for i in range(0, data.shape[0]):
        time.append(startdt + timedelta(seconds=i))
    
    from hapiclient.plot.timeseries import timeseries
    for i in range(0, data.shape[1]):
        fig = timeseries(time, data[:,i], ylabel='Counts', title=channeldict[uchannels[i]] + ' (' + uchannels[i] + ')')
        
    fname = net + "-" + sta + ".txt.gz"        
    print("Writing " + fname)
    np.savetxt(fname, data)
