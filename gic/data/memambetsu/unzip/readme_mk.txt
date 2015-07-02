Remarks of Geomagnetic Field Observation

Remarks Data Files (mkYYYYMM.xxx) include remarks on Geomagnetic Field Observation for each 
observatory for each month. Here YYYY, MM, and xxx shows year, month, and station code 
(written in lowercase letters) respectively. Sample data record is given below with line 
numbers, which is followed by some notices.  

1. Sample

*1:    Remarks of Geomagnetic Field Observation 
*2:    KAKIOKA April 2001
*3:     start     end      class comp.   code  Remarks
*4:   ..##.##.##..##.##.##..###..########..#..##################################
*5:     03 05 36     05 40  d              N  Atmospherics
*6:     03 05 40     05 44   s   HZD       N  Atmospherics
*7:     03 05 41     06 42  d              M  By operation (Stop of recording system)
*8:     24 07 33     07 33  d    Z'        N  Maintenance of measurement equipment
*9:     25 01 29     01 29   s   F         N  Trouble of magnetometer
*10:    25 02 10     02 39  d    X'Y'      N  Maintenance of measurement equipment
 .
 .
 .

Notice:
*1: Title
*2: Station  Month Year
*3-*4:   *a *b *c  *d *e *f  *g   *h       *i  *j
       ..##.##.##..##.##.##..###..########..#..##################################
   *a/*b/*c: Begin(DD/hh/mm),
   *d/*e/*f: End(DD/hh/mm), If *d is blank then *d=*a. ,
   *g: Class(d=0.1second-value,s=1second-value,m=1minute-value),
   *h: Component(0.1second-vakue=X'Y'Z', 1second-vakue=XYZF, 1minute-value=HDZF),blank:all-comp
   *i: Code(M:missing,N:noise)
   *j: Remarks
*5- (The entering example),
DD:date, hh:hour, mm:minute
