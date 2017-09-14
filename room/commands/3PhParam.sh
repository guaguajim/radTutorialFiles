#!/usr/bin/env bash


#Commands for running parametric simulations using the Three Phase Method. 
#The commands listed in 3Ph.sh should be run prior to running commands in this file.
#Results from previous simulations can thus be used to save computational effort.


#Lines beginning with # are comments.
#Set the current working directory to "room" before running the commands below.
#Commands are separated by empty line-breaks.


#SIMULATION WITH VENETIAN BLINDS AT 0 DEG.
##Results for illuminance.
dctimestep matrices/vmtx/v.mtx matrices/tmtx/ven0.xml matrices/dmtx/daylight.dmx skyVectors/NYC_Per.vec | rmtxop -fa -c 47.4 119.9 11.6 - > results/3ph/3phVen0.ill

##Results for image.
dctimestep matrices/vmtx/hdr/south%03d.hdr matrices/tmtx/ven0.xml matrices/dmtx/daylight.dmx skyVectors/NYC_Per.vec > results/3ph/3phVen0.hdr


#SIMULATION WITH VENETIAN BLINDS AT 45 DEG.
#Results for illuminance.
dctimestep matrices/vmtx/v.mtx matrices/tmtx/ven45.xml matrices/dmtx/daylight.dmx skyVectors/NYC_Per.vec | rmtxop -fa -c 47.4 119.9 11.6 - > results/3ph/3phVen45.ill

#Results for image.
dctimestep -h matrices/vmtx/hdr/south%03d.hdr matrices/tmtx/ven45.xml matrices/dmtx/daylight.dmx skyVectors/NYC_Per.vec > results/3ph/3phVen45.hdr
