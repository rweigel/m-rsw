import os
from datetime import timedelta, datetime

import numpy as np
import xmltodict
import obspy
import urllib.request

def downloadresponse(net, sta, channel, updateresponse=False, datadir='.'):
        
    url = 'http://service.ncedc.org/fdsnws/station/1/query?'
    url = url + 'net=' + net + '&sta=' + sta + '&cha=' + channel + '&level=response'

    fname = datadir + "/" + net + "/" + sta + "/" + net + "-" + sta + "-" + channel + "-response.xml"

    if updateresponse or not os.path.isfile(fname):
        print('Downloadng ' + url)
        urllib.request.urlretrieve(url, fname)
        print("Wrote: " + fname)

    return fname

def str2datetime(datestr):
    from dateutil import parser
    return parser.parse(datestr)


def daterange(date1, date2):
    
    if type(date1) == str:
        date1 = datetime.strptime(date1, '%Y-%m-%d')
    if type(date2) == str:
        date2 = datetime.strptime(date2, '%Y-%m-%d')
        
    for n in range(int ((date2 - date1).days)+1):
        yield date1 + timedelta(n)

            
def readmetadata(net, sta, datadir='.', updatemetadata=False):

    base  = "http://service.ncedc.org/fdsnws/station/1/query?"
    query = "net=" + net + \
            "&station=" + sta + \
            "&cha=*&level=channel"
    
    xmlfile = datadir + "/" + net + "/" + sta + "/" + net + "-" + sta + ".xml"
    
    if updatemetadata or not os.path.isfile(xmlfile):
        print('Reading ' + base + query)
        res = urllib.request.urlopen(base + query)
        xml = res.read()
        with open(xmlfile, "w") as f:
            f.write(xml.decode("utf-8"))
            print('Wrote ' + xmlfile)
    else:  
        with open(xmlfile, "r") as f:
            print('Reading ' + xmlfile)
            xml = f.read()
    
    xmld = xmltodict.parse(xml)

    return xmld


def xmlinfo(xmld):
    channels = []
    starts = []
    stops = []
    for cha in xmld['FDSNStationXML']['Network']['Station']['Channel']:
        code = cha['@code'][0:2]
        n = cha['@code'][2]
        if (code == 'LQ' or code == 'LT') and n.isdigit():
            channels.append(cha['@code'])
            starts.append(cha['@startDate'])
            stops.append(cha['@endDate'])
            print(cha['@code'] + " " +
                  cha['@startDate'] + " " + 
                  cha['@endDate'] + " " +
                  cha['Latitude'] + " " +
                  cha['Longitude'] + " " +
                  cha['Azimuth'] + " " + 
                  cha['Dip'])
    return channels, starts, stops


def downloaddata(net, sta, channels, starts, stops, datadir='.', tryagain=False):
          
    queryo = 'http://service.ncedc.org/fdsnws/dataselect/1/query?nodata=404&'
    
    for i in range(0,len(channels)):
        startdt = datetime.strptime(starts[i][0:10], '%Y-%m-%d')        
        stopdt = datetime.strptime(stops[i][0:10], '%Y-%m-%d')        
        query = queryo + 'net=' + net + '&sta=' + sta + '&cha=' + channels[i]
        print("Checking " + str(startdt) + "-" + str(stopdt))
        for dt in daterange(startdt, stopdt):
            fname = datadir + "/" + net + "/" + sta + "/" + net + "-" + sta + "-" + channels[i] + "-" + dt.strftime("%Y%m%d") + ".mseed"
            if os.path.isfile(fname):
                print("Found %s. Not downloading" % fname)
                continue
            if not tryagain and os.path.isfile(fname + ".failed"):
                print("Found %s. Not downloading. " % (fname + ".failed"))
                continue
            url = query + '&starttime=' + dt.strftime("%Y-%m-%d") + "T00:00:00"
            url = url + '&endtime=' + (dt + timedelta(days=1)).strftime("%Y-%m-%d") + "T00:00:00"
            print("Requesting " + url)
            try:
                urllib.request.urlretrieve(url, fname)
                print("Wrote: " + fname)
            except:
                with open(fname + ".failed", "w") as f: f.write("")
                print("Failed: " + fname)
                

def readdata(net, sta, uchannels, start, stop, remove_response=True, datadir='data', output='data'):

    updateresponse = False
    
    startdt = datetime.strptime(start, '%Y-%m-%d')        
    stopdt = datetime.strptime(stop, '%Y-%m-%d')
    Nt = len(list(daterange(startdt, stopdt)))

    print("Allocating arrays.")
    if output is 'data':
        data = np.ones((86400*Nt,len(uchannels)))
        data = data*np.nan 
    else:
        avail = np.zeros((Nt, len(uchannels)))  # Daily file available
        #favail = np.zeros((Nt, len(uchannels))) # Fraction available

    if remove_response:
        invs = []
        for i in range(0,len(uchannels)):
            rfile = downloadresponse(net, sta, uchannels[i],
                                           updateresponse=updateresponse,
                                           datadir=datadir)
            invs.append(obspy.read_inventory(rfile))


    print("Reading files in range " + start + " - " + stop)
    t = 0
    for dt in daterange(startdt, stopdt):
        a = 86400*t
        b = 86400*(t+1)
        for i in range(0,len(uchannels)):
            fname = datadir + "/" + net + "/" + sta + "/" + net + "-" + sta + "-" + \
                    uchannels[i] + "-" + dt.strftime("%Y%m%d") + ".mseed"
            if os.path.isfile(fname):
                print('Reading ' + fname)
                if output is 'data':
                    st = obspy.read(fname)
                    if remove_response:
                        st[0].remove_response(inventory=invs[i], water_level=1000)
                    #favail[t,i] = np.float(st[0].stats.npts)/86400.0
                    if st[0].stats.npts == 86400:
                        data[a:b,i] = st[0].data              
                    else:
                        #import pdb;pdb.set_trace()
                        pass
                else:
                    avail[t,i] = 1
            else:
                print('Not found: ' + fname)
        t = t+1
    if output is 'data':
        return data
    else:
        return avail