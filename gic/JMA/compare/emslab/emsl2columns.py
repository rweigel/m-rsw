import re
import numpy as np
from matplotlib import pyplot as plt

lst = []
with open("emsl01.asc", "r") as ins:
    for line in ins:
        if not re.match(r"^EMSL",line):
            lst.append(re.sub(r'(.....)',r'\1,',line.rstrip('\n')).split(',')[0:-1])

d = np.array(lst,dtype='int')
d = d.reshape(d.size).reshape((int(d.size/5),5))
np.savetxt("emsl01.csv", d, delimiter=",", fmt="%d")
print('Wrote emsl01.csv')

d = d.astype('f')
d[d==-9999] = np.nan
d[:,0:3] = d[:,0:3]/10.0
d[:,3:5] = d[:,3:5]/10.0

print(d)

plt.plot(d[:,0])
plt.plot(d[:,1])
plt.plot(d[:,2])
plt.plot(d[:,3])
plt.plot(d[:,4])
