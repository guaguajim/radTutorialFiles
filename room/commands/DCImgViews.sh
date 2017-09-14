#!/usr/bin/env bash

#Commands for Daylight Coefficients simulation.


#Lines beginning with # are comments.
#Set the current working directory to "room" before running the commands below.
#Commands are separated by empty line-breaks.


#Create octree
oconv materials.rad room.rad objects/Glazing.rad > octrees/roomDC.oct


#Create sky-vectors
##Point-in-time sky vector
gendaylit 3 20 10:30EDT -m 75 -o 73.96 -a 40.78 -W 706 162 | genskyvec -m 1 > skyVectors/NYC_Per.vec



#Steps for creating daylight coefficients for images
##views/south.vf
vwrays -vf views/south.vf -x 250 -y 250 -pj 0.7 -c 9 -ff | rfluxmtx -ffc -v -n 16 `vwrays -vf views/south.vf -x 250 -y 250 -d` -c 9  -ab 4 -ad 10000 -lw 0.0001 -o matrices/dc/hdr/southV%03d.hdr - skyDomes/skyglow.rad -i octrees/roomDC.oct

##views/in.vf
vwrays -vf views/in.vf -x 250 -y 250 -pj 0.7 -c 9 -ff | rfluxmtx -ffc -v -n 16 `vwrays -vf views/in.vf -x 250 -y 250 -d` -c 9  -ab 4 -ad 10000 -lw 0.0001 -o matrices/dc/hdr/inV%03d.hdr - skyDomes/skyglow.rad -i octrees/roomDC.oct

##views/eastBlinds.vf
vwrays -vf views/eastBlinds.vf -x 250 -y 250 -pj 0.7 -c 9 -ff | rfluxmtx -ffc -v -n 16 `vwrays -vf views/eastBlinds.vf -x 250 -y 250 -d` -c 9  -ab 4 -ad 10000 -lw 0.0001 -o matrices/dc/hdr/eastBlindsV%03d.hdr - skyDomes/skyglow.rad -i octrees/roomDC.oct

##views/external.vf
vwrays -vf views/external.vf -x 250 -y 250 -pj 0.7 -c 9 -ff | rfluxmtx -ffc -v -n 16 `vwrays -vf views/external.vf -x 250 -y 250 -d` -c 9  -ab 4 -ad 10000 -lw 0.0001 -o matrices/dc/hdr/externalV%03d.hdr - skyDomes/skyglow.rad -i octrees/roomDC.oct


#RESULTS
##For a point-in-time calculation using a skyvector
##views/south.vf
dctimestep matrices/dc/hdr/southV%03d.hdr skyVectors/NYC_Per.vec > results/dc/views/south.hdr

##views/in.vf
dctimestep matrices/dc/hdr/inV%03d.hdr skyVectors/NYC_Per.vec > results/dc/views/in.hdr

##views/eastBlinds.vf
dctimestep matrices/dc/hdr/eastBlindsV%03d.hdr skyVectors/NYC_Per.vec > results/dc/views/eastBlinds.hdr

##views/in.vf
dctimestep matrices/dc/hdr/externalV%03d.hdr skyVectors/NYC_Per.vec > results/dc/views/external.hdr