#!/usr/bin/env bash

#This simulation demonstrates a Radiance-based implementation of the Daysim DDS Model. 

#Lines beginning with # are comments.
#Set the current working directory to "room" before running the commands below.
#Commands are separated by empty line-breaks.


#STEP 1: Perform an annual daylight coefficient simulation.
#Create octree
oconv materials.rad room.rad objects/Glazing.rad > octrees/roomDC.oct

#Generate daylight coefficients
rfluxmtx -I+ -y 100 -lw 0.0001 -ab 5 -ad 10000 -n 16 - skyDomes/skyglow.rad -i octrees/roomDC.oct < points.txt > matrices/dc/illum.mtx

##Annual sky-matrix
epw2wea assets/USA_NY_New.York-Central.Park.725033_TMY3m.epw assets/NYC.wea
gendaymtx -m 1 assets/NYC.wea > skyVectors/NYC.smx

#RESULTS
dctimestep matrices/dc/illum.mtx skyVectors/NYC.smx | rmtxop -fa -t -c 47.4 119.9 11.6 - > results/dcDDS/dc/annualR.ill


#STEP 2: Perform an annual direct-only daylight coefficients simulation.

#Create black octree for direct sun calculations.
oconv materialBlack.rad roomBlack.rad materials.rad objects/Glazing.rad > octrees/roomDCBlack.oct

#Generate daylight coefficients
rfluxmtx -I+ -y 100 -lw 0.0001 -ab 1 -ad 10000 -n 16 - skyDomes/skyglow.rad -i octrees/roomDCBlack.oct < points.txt > matrices/dcd/illum.mtx

##Annual sky-matrix
gendaymtx -m 1 -d assets/NYC.wea > skyVectors/NYCd.smx

#RESULTS
dctimestep matrices/dcd/illum.mtx skyVectors/NYCd.smx | rmtxop -fa -t -c 47.4 119.9 11.6 - > results/dcDDS/dcd/annualR.ill


#STEP 3: Perform an annual sun-coefficients simulation.
#(The number of suns considered in this case are the same as that propsed in the DDS Model from 2008).
#Create sun primitive definition for solar calculations.
echo "void light solar 0 0 3 1e6 1e6 1e6" > skies/suns.rad

##Create solar discs and corresponding modifiers for 5185 suns corresponding to a Reinhart MF:6 subdivision.
cnt 2305 | rcalc -e MF:4 -f reinsrc.cal -e Rbin=recno -o 'solar source sun 0 0 4 ${Dx} ${Dy} ${Dz} 0.533' >> skies/suns.rad

#Create an octree black octree, shading device with proxy BSDFs and solar discs.
oconv -f materialBlack.rad roomBlack.rad skies/suns.rad materials.rad objects/Glazing.rad > octrees/sunCoefficientsDDS.oct

#Calculate illuminance sun coefficients for illuminance calculations.
rcontrib -I+ -ab 1 -y 100 -n 16 -ad 256 -lw 1.0e-3 -dc 1 -dt 0 -dj 0 -faf -e MF:4 -f reinhart.cal -b rbin -bn Nrbins -m solar octrees/sunCoefficientsDDS.oct < points.txt > matrices/cds/cdsDDS.mtx
gendaymtx -5 0.533 -d -m 4 assets/NYC.wea > skyVectors/NYCsunM4.smx

#RESULTS
dctimestep matrices/cds/cdsDDS.mtx skyVectors/NYCsunM4.smx | rmtxop -fa -t -c 47.4 119.9 11.6 - > results/dcDDS/cds/annualR.ill


#Final Step: Combine results 
rmtxop results/dcDDS/dc/annualR.ill + -s -1 results/dcDDS/dcd/annualR.ill + results/dcDDS/cds/annualR.ill > results/dcDDS/annualR.ill


