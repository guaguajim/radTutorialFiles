#!/usr/bin/env bash

#Commands for running a Three Phase Image-based simulation using a view that faces east.


#Lines beginning with # are comments.
#Set the current working directory to "room" before running the commands below.
#Commands are separated by empty line-breaks.


#Create octree
oconv -f materials.rad room.rad > octrees/room3ph.oct

#V matrix for Images.
vwrays -vf views/eastBlinds.vf -x 400 -y 400 -pj 0.7 -c 9 -ff | rfluxmtx -v -ffc `vwrays -vf views/eastBlinds.vf -x 400 -y 400 -d` -o matrices/vmtx/hdr/eastBlinds%03d.hdr -ab 4 -ad 1000 -lw 1e-4 -c 9 -n 16 - objects/GlazingVmtx.rad -i octrees/room3ph.oct

#D matrix
rfluxmtx -v -ff  -ab 4 -ad 1000 -lw 0.001 -c 1000 -n 16 objects/GlazingVmtx.rad skyDomes/skyglow.rad -i octrees/room3ph.oct > matrices/dmtx/daylight.dmx


#Create sky-vectors
##Point-in-time sky vector
gendaylit 3 20 10:30EDT -m 75 -o 73.96 -a 40.78 -W 706 162 | genskyvec -m 1 > skyVectors/NYC_Per.vec


##Annual sky-matrix
epw2wea assets/USA_NY_New.York-Central.Park.725033_TMY3m.epw assets/NYC.wea

gendaymtx -m 1 assets/NYC.wea > skyVectors/NYC.smx


#RESULTS
#Images
##For a point-in-time simulation.
dctimestep -h matrices/vmtx/hdr/eastBlinds%03d.hdr matrices/tmtx/clear.xml matrices/dmtx/daylight.dmx skyVectors/NYC_Per.vec > results/3ph/3phEast.hdr

##For an annual simulation
dctimestep -o results/3ph/hdr/eastBlinds%04d.hdr matrices/vmtx/hdr/eastBlinds%03d.hdr matrices/tmtx/clear.xml matrices/dmtx/daylight.dmx skyVectors/NYC.smx
