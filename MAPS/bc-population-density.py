#!/usr/local/bin/bython -k

import sys
import os
import xarray
from bclib import *

# TODO: create a library (done) and canonize bclib(home) and stuff

fname = "/home/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_population_count_rev11_2020_30_sec.tif"

# this is the tiny one for easy testing

fname = "/home/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_population_count_rev11_2020_1_deg.tif"

# uncomment this to test that I am not reading thee entire file

# fname = "/home/user/NOBACKUP/EARTHDATA/ELEVATION/SRTM1/srtm1.tif"

pt = xarray.open_rasterio(fname)

print("X", pt.x[7])

nodataval = pt.nodatavals[0]

# TODO: comment out next line, it wont work in general

# with the line below commented out: 49.878u 1.795s 0:50.39 102.5%   0+0k 0+8io 0pf+0w

# with it left in: 1.671u 1.694s 0:04.09 82.1%     0+0k 0+8io 0pf+0w

# pt = pt.values

for i in range(len(pt[0])):
    for j in range(len(pt[0][i])):
        print(i,j,float(pt[0][i][j]))
    


die("TESTING")

# test to see if reading in the whole thing is faster (doesn't appear to be)
# pt[0] = list(pt[0])

for i in range(len(pt[0])):
    for j in range(len(pt[0][i])):
        
        val = pt[0][i][j]
        data = float(val.data)
        
        if (data == nodataval or data == 0):
            print(i,j,"BORING")
            continue
        
        
        x = float(val.x)
        y = float(val.y)
        print(i,j,x,y,data)
    


die("TESTING")

print(len(pt[0]))

# print(pt[0][500][500].data)

# print(debug0(object=pt[0], exclude="_"))

# for i in range(len(pt[0]))) {
#  for j in range(pt[0][i].length) {
#    print(pt[0][i][j])
# }


#  for j in range(pt.width) {
#
#    print(`I: {i}, J: {j}`)
#  }
# }

print(pt.xy(23, 34))

die("TESTING")

# since our data is 43200x21600 we start with level 8 tiles -- this
# will be imperfect

x = list(pt.x)
y = list(pt.y)
vals = list(pt.values)

for i in range(len(x)):
    print(i)
    for j in range(len(y)):
        lat = float(y[j])
        lng = float(x[i])
        pop = float(vals[0][j][i])
    









