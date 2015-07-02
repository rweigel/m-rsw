Remarks of Geoelectric Field Observation

Remarks Data Files (ekYYYYMM.xxx) include remarks on Geoelectric Field Observation for 
each observatory for each month. Here YYYY, MM, and xxx shows year, month, and station 
code (written in lowercase letters) respectively. Sample data record is given below with 
line numbers, which is followed by some notices

1. Sample

*1:    Remarks of Geoelectric Field Observation
*2:    KAKIOKA April 2001
*3:    Base-line Length[km]                      EW(0.190)  NS(0.180)
*4:    Input alternative current voltage for Calibration - 
*5:      start     end      class comp.   code  Remarks
*6:   ..##.##.##..##.##.##..###..##..#..##################################
*7:     03 05 38     05 39  ds       N  Electric noise due to atmospherics
*8:     03 05 38     06 53    m      M  By operation
*9:     03 05 40     06 42  d        M  By operation
*10:    03 05 40     06 53   s       M  By operation
*11:    13 00 00              m  NS  G  NS -3.0mv/km (Unknown origin)
*12:    13 01 39            d    NS  N  Noise of Unknown origin
*13:    15 02 25     03 12   s   EW  N  Noise of Unknown origin
*14:    19 08 09     08 19    m  NS  M  Input an artificial signal for calibration
 .
 .
 .

Notice:
*1: Title
*2: Station Month Year
*3: Base-line Length[km]
*4: Input alternative current voltage for Calibration 
*5-*6:   *a *b *c  *d *e *f  *g   *h *i  *j
       ..##.##.##..##.##.##..###..##..#..##################################
   *a/*b/*c: Begin(DD/hh/mm),
   *d/*e/*f: End(DD/hh/mm), If *d is blank then *d=*a. ,
   *g: Class(d=0.1second-vakue,s=1second-vakue,m=1minute-value),
   *h: Component(NS,EW),blank:both-component
   *i: Code(M:missing,N:noise,G:gap)
   *j: Remarks
*7- : (The entering example),
DD:date, hh:hour, mm:minute

