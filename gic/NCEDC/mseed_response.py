#http://service.ncedc.org/fdsnws/station/1/query?net=BK&sta=PKD&cha=LT1&level=response

import obspy

'''
Read response file, e.g,
http://service.ncedc.org/fdsnws/station/1/query?net=BK&sta=PKD&cha=LT1&level=response
then remove instrument response using
https://docs.obspy.org/packages/autogen/obspy.core.trace.Trace.remove_response.html#obspy.core.trace.Trace.remove_response
 
channeldict = {'LT1': 'B_{East}',  Variable
               'LT2': 'B_{South}', Variable
               'LT3': 'B_{Down}',  Variable
               'LQ2': 'E_{East}',  1.35331994E9 (V/m)
               'LQ3': 'E_{South}', 1.34095002E9 (V/m)
               'LQ4': 'E_{East}',  8.27072E8 (V/m)
               'LQ5': 'E_{South}', 8.4317197E8 (V/m)
               }
'''


rfile = downloadresponse(net, sta, channels)

net = 'BK'
sta = 'PKD'
datadir = 'data/' + net + '/' + sta
fname = datadir + "/" + net + "-" + sta + "-" + "LT1" + "-20020801.mseed"
print(fname)
st = obspy.read(fname)

inv = obspy.read_inventory("LT1.xml")
st[0].remove_response(inventory=inv, plot=True)